use "net"

actor Client

    let _env: Env

    let authenticator: (Authenticator | None)
    let cqlVersion: String = "3.0.0"
    let compression: (String val | None val) = None
    let _flags: U8 = 0x00
    var _stream: U16 = 0x0000

    var conn: (TCPConnection | None) = None

    new create(env': Env, authenticator': (Authenticator iso | None) = None) =>
        _env = env'
        authenticator = consume authenticator'

    fun ref _createFrame(body: Request val): Frame val =>
        recover Frame(4, _flags, _nextStream(), body) end

    fun ref _nextStream(): U16 =>
        _stream = _stream + 1

    be authenticate() =>
        match authenticator
        | let a: PasswordAuthenticator => send(AuthResponseRequest(a.token()))
        end

    be closed(conn': TCPConnection tag) =>
        _env.out.print("- Connection closed")

    be connect() =>
        match _env.root
        | let a: AmbientAuth => TCPConnection(a, TCPConnectionNotifyClient(_env, this), "", "9042", "", 64, 268435456)
        end
    
    be send(request: Request val) =>
        let frame = _createFrame(request)
        let data = Visitor(frame)
        match conn
        | let c: TCPConnection =>
            c.write(data)
            _env.out.print("-> " + request.string())
        else
            _env.out.print("-| " + request.string())
        end

    be connect_failed(conn': TCPConnection tag) =>
        _env.out.print("- connection failed")
        None
    
    be connected(conn': TCPConnection tag) =>
        _env.out.print("- connection established")
        conn = conn'
        startup(conn')

    be received(conn': TCPConnection tag, response: Response val) =>
        _env.out.print("<- " + response.string())

        match response
        | let m: AuthenticateResponse => authenticate()
        end

    be startup(conn': TCPConnection) =>
        send(StartupRequest.create(cqlVersion))

    be throttled(conn': TCPConnection tag) =>
        None

    be unthrottled(conn': TCPConnection tag) =>
        None


class TCPConnectionNotifyClient is TCPConnectionNotify

    let _stderr: StdStream tag
    let client: Client tag
    
    var _header: (Array[U8 val] val | None) = None
    var _version: U8 val = 4
    var _flags: U8 val = 0
    var _stream: U16 val = 0
    var _opcode: U8 val = 0
    var _length: I32 val = 0
    
    new iso create(env: Env, client': Client tag) => 
        _stderr = env.err
        client = client'

    fun ref connected(conn: TCPConnection ref) =>
        conn.expect(9)
        client.connected(conn)

    fun ref connect_failed(conn: TCPConnection ref) =>
        client.connect_failed(conn)

    fun ref received(conn: TCPConnection ref, data: Array[U8 val] val): Bool val =>
        try
            match _header
            | None =>
                _header = data
                
                _version = data(0) and 0b0111
                _flags = data(1)
                _stream = ((data(2).u16() << 8) or data(3).u16())
                _opcode = data(4)
                _length = (data(5).i32() << 24)
                    or (data(6).i32() << 16)
                    or (data(7).i32() << 8)
                    or data(8).i32()

                conn.expect(_length.usize())

                true
            | let h: Array[U8 val] val =>
                let parser = Parser(data)
                let response: Response = match _opcode
                | 0x00 => parser.parseErrorResponse()
                | 0x02 => parser.parseReadyResponse()
                | 0x03 => parser.parseAuthenticateResponse()
                else error
                end
                client.received(conn, response)

                _header = None
                conn.expect(9)
                false
            else error
            end
        else
            match _header
            | None =>
                _stderr.print("Error parsing frame header: " + Bytes.to_hex_string(data))
            | let h: Array[U8 val] val => 
                _stderr.print("Error parsing frame body: " + Bytes.to_hex_string(h) + Bytes.to_hex_string(data))
            end
            false
        end

    fun ref closed(conn: TCPConnection ref) =>
        client.closed(conn)

    fun ref throttled(conn: TCPConnection ref) =>
        client.throttled(conn)

    fun ref unthrottled(conn: TCPConnection ref) =>
        client.unthrottled(conn)
