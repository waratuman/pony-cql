use "net"
use "logger"

actor Client is FrameNotifiee

    let _auth: TCPConnectionAuth
    let _notify: ClientNotify
    let _logger: (Logger[String] | None)

    let cqlVersion: String = "3.0.0"
    let compression: (String val | None val) = None
    let _flags: U8 = 0x00
    var _stream: U16 = 0x0000

    var _closed: Bool val = false
    let _conn: TCPConnection
    
    new create(auth: TCPConnectionAuth, notify: ClientNotify iso, host: String, service: String = "9042", logger: (Logger[String] | None) = None) =>
        _auth = auth
        _notify = consume notify
        _logger = logger
        _conn = TCPConnection(_auth, FrameNotify(this, logger), host, service, "", 64, 268435456)

    fun ref _createFrame(body: Request val): Frame val =>
        recover Frame(4, _flags, _nextStream(), body) end

    fun ref _nextStream(): U16 =>
        _stream = _stream + 1

    fun ref _authenticate(response: AuthenticateResponse val) ? =>
        var authenticator: Authenticator iso = match response.authenticator_name
        | "org.apache.cassandra.auth.PasswordAuthenticator" =>
            PasswordAuthenticator.create()
        else error
        end
        
        let returnedAuthenticator: Authenticator box = _notify.authenticate(this, consume authenticator)
        let token = returnedAuthenticator.token()
        _send(AuthResponseRequest(token))

    fun ref _authenticated(response: AuthSuccessResponse val) =>
        _notify.connected(this)

    fun ref _log(level: LogLevel, message: String val, loc: SourceLoc = __loc) =>
        match _logger
        | let l: Logger[String] => l(level) and l.log(message, loc)
        end
    
    fun ref _ready(response: ReadyResponse val) =>
        _notify.connected(this)

    fun ref _startup() =>
        _send(StartupRequest.create(cqlVersion))

    fun ref _send(request: Request val) =>
        let frame = _createFrame(request)
        let data = Visitor(frame)
        
        if not _closed then
            _conn.write(data)
            _log(Info, "-> " + request.string())
        else
            _log(Info, "-| " + request.string())
        end

    fun ref close() =>
        _closed = true
        _conn.dispose()

    be options() =>
        _send(OptionsRequest)
    
    be accepted(conn: TCPConnection tag) =>
        None

    be closed(conn: TCPConnection tag) =>
        _log(Info, "__ Connection closed")
        _notify.closed(this)
    
    be connecting(conn': TCPConnection, count: U32 val) =>
        _log(Info, ".. connecting")
        _notify.connecting(this, count)

    be connect_failed(conn': TCPConnection tag) =>
        _notify.connect_failed(this)
        _log(Warn, "!! connection failed")
    
    be connected(conn: TCPConnection tag) =>
        _log(Info, "-- connection established")
        _startup()

    be dispose() =>
        close()

    be received(conn: TCPConnection tag, frame: Frame val) =>
        _log(Info, "<- " + frame.body.string())

        match frame.body
        | let m: Response => _notify.received(this, m)
        end

        match frame.body
        | let m: ReadyResponse => _ready(m)
        | let m: AuthenticateResponse =>
            try
                _authenticate(m)
            else
                _notify.authenticate_failed(this)
            end
        | let m: AuthSuccessResponse => _authenticated(m)
        end

    be throttled(conn: TCPConnection tag) =>
        None

    be unthrottled(conn: TCPConnection tag) =>
        None
