use "net"
use "logger"

actor Server

    let _tcp_listener: TCPListener
    var _notify: ServerNotify ref
    let _logger: (Logger[String] | None)

    var local_address: NetAddress val = recover NetAddress end

    new create(auth: TCPListenerAuth, listener: ServerNotify iso, host: String = "", service: String = "0", logger: (Logger[String] | None) = None) =>
        _logger = logger
        _notify = consume listener
        _tcp_listener = TCPListener(auth, TCPListenNotifyServer(this, _logger), host, service)
    
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
    
    be accepted(listener: TCPListener tag, conn: ServerConnection tag) =>
        _notify.accepted(this, conn)

    be dispose() =>
        _tcp_listener.dispose()

interface ServerNotify

    fun ref listening(server: Server ref) =>
        None

    fun ref not_listening(server: Server ref) =>
        None

    fun ref closed(server: Server ref) =>
        None

    fun ref accepted(server: Server ref, serverConnection: ServerConnection tag) =>
        None

actor ServerConnection is FrameNotifiee

    var _version: U8 val = 4
    var _conn: (TCPConnection tag | None) = None
    var _cqlVersion: String = "3.0.0"
    var _compression: (String val | None val) = None
    
    let _logger: (Logger[String] | None)
    
    new create(logger: (Logger[String] | None) = None) =>
        _logger = logger
    
    fun ref _log(level: LogLevel, message: String val, loc: SourceLoc = __loc) =>
        match _logger
        | let l: Logger[String] => l(level) and l.log(message, loc)
        end

    fun ref _startup(frame: Frame val) =>
        _version = frame.version

        match frame.body
        | let m: StartupRequest =>
            _cqlVersion = m.cqlVersion
            _compression = m.compression
        end

        _send(frame.stream, ReadyResponse())
    
    fun ref _options(frame: Frame val) =>
        let compression: Array[String val] val = recover Array[String val]() end
        let cqlVersion: Array[String val] val = recover ["3.0.0"] end 
        _send(frame.stream, SupportedResponse(cqlVersion, compression))

    fun ref _send(stream: U16 val, message: Message val) =>
        let frame = Frame(_version or 0x80, 0x00, stream, message)
        let data = Visitor(frame)

        match _conn
        | let c: TCPConnection tag =>
            _log(Info, "-> " + message.string())
            c.write(data)
        else
            _log(Info, "-| " + message.string())
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
        | let m: StartupRequest => _startup(frame)
        | let m: OptionsRequest => _options(frame)
        else _send(frame.stream, ErrorResponse(0, "Unrecognized request"))
        end

    be throttled(conn: TCPConnection tag) =>
        None

    be unthrottled(conn: TCPConnection tag) =>
        None


class TCPListenNotifyServer is TCPListenNotify

    let _server: Server
    let _logger: (Logger[String] | None)

    new iso create(server: Server, logger: (Logger[String] | None) = None) =>
        _server = server
        _logger = logger
    
    fun ref listening(listener: TCPListener ref) =>
        _server.listening(listener, listener.local_address())

    fun ref not_listening(listener: TCPListener ref) =>
        _server.not_listening(listener)

    fun ref closed(listener: TCPListener ref) =>
        _server.closed(listener)
    
    fun ref connected(listener: TCPListener ref): TCPConnectionNotify iso^ =>
        let server_connection = ServerConnection.create(_logger)
        _server.accepted(listener, server_connection)
        FrameNotify(server_connection, _logger)
