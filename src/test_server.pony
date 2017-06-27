use "net"
use "logger"
use "itertools"
use "./native_protocol"

actor TestServer

    let _authenticator: (Authenticator val | None val)
    let _tcp_listener: TCPListener
    let _notify: TestServerNotify ref
    let _logger: (Logger[String] | None)

    var local_address: NetAddress val = recover NetAddress end

    new create(auth: TCPListenerAuth, listener: TestServerNotify iso, authenticator: (Authenticator val | None val) = None, host: String = "", service: String = "0", logger: (Logger[String] | None) = None) =>
        _authenticator = authenticator
        _logger = logger
        _notify = consume listener
        _tcp_listener = TCPListener(auth, TCPListenNotifyServer(this, _authenticator, _logger), host, service)
        match authenticator
        | None => _log(Fine, "no auth")
        end
    
    fun ref _log(level: LogLevel, message: String val, loc: SourceLoc = __loc) =>
        match _logger
        | let l: Logger[String] => l(level) and l.log(message, loc)
        end

    be listening(listener: TCPListener tag, local_address': NetAddress) =>
        local_address = local_address'
        _notify.listening(this)

    be not_listening(listener: TCPListener tag) =>
        _notify.not_listening(this)
        
    be closed(listener: TCPListener tag) =>
        _notify.closed(this)
    
    be accepted(listener: TCPListener tag, conn: TestServerConnection tag) =>
        _notify.accepted(this, conn)

    be dispose() =>
        _tcp_listener.dispose()

interface TestServerNotify

    fun ref listening(server: TestServer ref) =>
        None

    fun ref not_listening(server: TestServer ref) =>
        None

    fun ref closed(server: TestServer ref) =>
        None

    fun ref accepted(server: TestServer ref, serverConnection: TestServerConnection tag) =>
        None

actor TestServerConnection is FrameNotifiee

    let _authenticator: (Authenticator val | None val)
    var _version: U8 val = 4
    var _conn: (TCPConnection tag | None) = None
    var _cql_version: String = "3.0.0"
    var _compression: (String val | None val) = None
    
    let _logger: (Logger[String] | None)
    
    new create(authenticator: (Authenticator val | None val) = None, logger: (Logger[String] | None) = None) =>
        _authenticator = authenticator
        _logger = logger
    
    fun ref _log(level: LogLevel, message: String val, loc: SourceLoc = __loc) =>
        match _logger
        | let l: Logger[String] => l(level) and l.log(message, loc)
        end

    fun ref _startup(frame: Frame val, message: StartupRequest val) =>
        _version = frame.version
        _cql_version = message.cql_version
        _compression = message.compression

        match _authenticator
        | None => _send(frame.stream, recover iso ReadyResponse end)
        | let a: Authenticator val => _send(frame.stream, AuthenticateResponse(a.name()))
        end

    fun ref _options(frame: Frame val, message: OptionsRequest val) =>
        let msg = recover iso
            let compression: Array[String val] ref = Array[String val]()
            let cql_version: Array[String val] ref = ["3.0.0"]
            SupportedResponse(cql_version, compression)
        end
        _send(frame.stream, consume msg)

    fun ref _auth_response(frame: Frame val, message: AuthResponseRequest val) =>
        match _authenticator
        | let a: Authenticator val =>
            match (message.token, a.token())
            | (let t1: Array[U8 val] val, let t2: Array[U8 val] val) =>
                var passed: Bool val = t1.size() == t2.size()
                for (x, y) in Zip2[U8 val, U8 val](t1.values(), t2.values()) do
                    if (x == y) then
                        passed = true and passed
                    else
                        passed = false
                    end
                end
                
                if passed then
                    _send(frame.stream, AuthSuccessResponse())
                else
                    _send(frame.stream, ErrorResponse(0x0100, "authentication failed"))
                end
            else
                _send(frame.stream, ErrorResponse(0x0100, "authentication failed"))
            end
        else
            _send(frame.stream, ErrorResponse(0x0100, "authentication failed"))
        end

    fun ref _send(stream: U16 val, message: Message iso) =>
        let message_string: String val = message.string()
        let frame: Frame val = Frame(_version or 0x80, 0x00, stream, consume message)
        let data = OldVisitor(frame)

        match _conn
        | let c: TCPConnection tag =>
            _log(Info, "-> " + message_string)
            c.write(data)
        else
            _log(Info, "-| " + message_string)
        end

    be accepted(conn: TCPConnection tag) =>
        _conn = conn

    be closed(conn: TCPConnection tag) =>
        None        

    be connecting(conn: TCPConnection tag, count: U32 val) =>
        None

    be connect_failed(conn: TCPConnection tag) =>
        None

    be connected(conn: TCPConnection tag) =>
        None

    be received(conn: TCPConnection tag, frame: Frame val) =>
        _log(Info, "<- " + frame.body.string())
        match frame.body
        | let m: StartupRequest val => _startup(frame, m)
        | let m: OptionsRequest val => _options(frame, m)
        | let m: AuthResponseRequest val => _auth_response(frame, m)
        else _send(frame.stream, ErrorResponse(0, "Unrecognized request"))
        end

    be throttled(conn: TCPConnection tag) =>
        None

    be unthrottled(conn: TCPConnection tag) =>
        None


class TCPListenNotifyServer is TCPListenNotify

    let _authenticator: (Authenticator val | None val)
    let _server: TestServer
    let _logger: (Logger[String] | None)

    new iso create(server: TestServer, authenticator: (Authenticator val | None val), logger: (Logger[String] | None) = None) =>
        _authenticator = authenticator
        _server = server
        _logger = logger
    
    fun ref listening(listener: TCPListener ref) =>
        _server.listening(listener, listener.local_address())

    fun ref not_listening(listener: TCPListener ref) =>
        _server.not_listening(listener)

    fun ref closed(listener: TCPListener ref) =>
        _server.closed(listener)
    
    fun ref connected(listener: TCPListener ref): TCPConnectionNotify iso^ =>
        let server_connection = TestServerConnection.create(_authenticator, _logger)
        _server.accepted(listener, server_connection)
        FrameNotify(server_connection, _logger)
