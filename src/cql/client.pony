use "net"
use "format"
use collection = "collections" 

actor Client // is TCPConnectionNotify

    let env: Env
    let cqlVersion: String = "3.0.0"
    let compression: (String val | None val) = None
    let _flags: U8 = 0x00
    var _stream: U16 = 0x0000

    var connection: (TCPConnection | None) = None

    new create(env': Env) =>
        env = env'

    be connect() =>
        try
            TCPConnection(
                env.root as AmbientAuth,
                recover ClientTCPConnectionNotify(env, this) end,
                "",
                "9042"
            )
        end

    be connected(connection': TCPConnection) =>
        connection = connection'
        startup(connection')
    
    be received(conn: TCPConnection, data: Array[U8 val] val) =>
        try
            let response = Parser(data)
            env.out.print("<- " + response.string())
        end

    fun ref nextStream(): U16 =>
        _stream = _stream + 1
    
    fun ref startup(connection': TCPConnection) =>
        let request: StartupRequest val = StartupRequest.create(cqlVersion)
        let message: Message val = _createMessage(request)  
        env.out.print("-> " + request.string())
        connection'.write(Visitor(message))
    
    fun ref _createMessage(body: Request val): Message val =>
        recover Message(4, _flags, _stream + 1, body) end


class ClientTCPConnectionNotify is TCPConnectionNotify

    let env: Env
    let client: Client tag

    new create(env': Env, client': Client) =>
        env = env'
        client = client'
    
    fun connected(connection: TCPConnection ref): None val =>
        env.out.print("connected")
        client.connected(connection)
    
    fun connecting(connection: TCPConnection ref, count: U32 val): None val =>
        env.out.print("connecting")
    
    fun connect_failed(conn: TCPConnection ref): None val =>
        env.out.print("connect_failed")

    fun ref auth_failed(conn: TCPConnection ref): None val =>
        env.out.print("auth_failed")
        None

    fun ref sentv(conn: TCPConnection ref, data: ByteSeqIter val): ByteSeqIter val =>
        env.out.print("setv")
        data

    fun ref received(conn: TCPConnection ref, data: Array[U8 val] val): Bool val =>
        client.received(conn, data)
        // env.out.print("received")
        // let s = recover
        //     let hexString = String()
        //     for byte in data.values() do
        //         hexString.append(Format.int[U8](byte, FormatHexBare, PrefixDefault, 2))
        //     end
        //     hexString
        // end
        // env.out.print(consume s)
        false

    // fun ref expect(conn: TCPConnection ref, qty: USize val): USize val =>

    fun ref closed(conn: TCPConnection ref): None val =>
        env.out.print("closed")
        None

    fun ref throttled(conn: TCPConnection ref): None val =>
        env.out.print("throttled")
        None

    fun ref unthrottled(conn: TCPConnection ref): None val =>
        env.out.print("unthrottled")
        None