use "net"
use "format"
use collection = "collections" 

actor Client is TCPConnectionNotify

    let env: Env
    let cqlVersion: String = "3.0.0"
    var _stream: U16 = 0

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
        try startup(connection') end
    
    fun ref nextStream(): U16 =>
        _stream = _stream + 1
    
    fun ref startup(connection': TCPConnection) ? =>
        let request = startupRequest()
        env.out.print("-> " + request.string())
        connection'.write(request.encode())
    
    fun ref startupRequest(): Request =>
        let body = recover
            let b: collection.Map[String val, String val] ref = collection.Map[String val, String val]()
            b.update("CQL_VERSION", cqlVersion)
            b
        end
        Request.create(Startup, nextStream(), consume body)



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

    fun ref sent(conn: TCPConnection ref, data': ByteSeq val): Array[U8 val] val =>
        env.out.print("sent")

        let data: Array[U8 val] val = match data'
        | let d: Array[U8 val] val => d
        | let d: String val => d.array()
        else recover Array[U8 val]() end
        end

        for byte in data.values() do
            env.out.print(Format.int[U8](byte, FormatHex, PrefixDefault, 2))
        end
        data

    fun ref sentv(conn: TCPConnection ref, data: ByteSeqIter val): ByteSeqIter val =>
        env.out.print("setv")
        data

    fun ref received(conn: TCPConnection ref, data: Array[U8 val] val): Bool val =>
        env.out.print("received")
        try
            let response = Response.decode(data)
            env.out.print("<- " + response.string())
        end
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