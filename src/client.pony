use "net"
use "logger"
use "./native_protocol"


actor Client is FrameNotifiee

    let _auth: TCPConnectionAuth
    let _notify: ClientNotify
    let _logger: (Logger[String] | None)

    let cql_version: String val = "3.0.0"
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

    fun ref _createFrame(body: Request iso): Frame iso^ =>
        Frame(4, _flags, _nextStream(), consume body)

    fun ref _nextStream(): U16 =>
        _stream = _stream + 1

    fun ref _authenticate(response: AuthenticateResponse val) =>
        var authenticator: Authenticator iso = match response.authenticator_name
        | "org.apache.cassandra.auth.PasswordAuthenticator" => PasswordAuthenticator.create()
        else
            _authenticate_failed(ErrorResponse(0x0100, "Unkown authenticator: " + response.authenticator_name))
            return
        end
        
        let returnedAuthenticator: Authenticator iso = _notify.authenticate(this, consume authenticator)
        let token = returnedAuthenticator.token()
        _send(AuthResponseRequest(token))


    fun ref _authenticated(response: AuthSuccessResponse val) =>
        _notify.authenticated(this)
        _notify.connected(this)


    fun ref _authenticate_failed(response: ErrorResponse val) =>
        _notify.authenticate_failed(this)


    fun ref _log(level: LogLevel, message: String val, loc: SourceLoc = __loc) =>
        match _logger
        | let l: Logger[String] => l(level) and l.log(message, loc)
        end


    fun ref _ready(response: ReadyResponse val) =>
        _notify.connected(this)


    fun ref _startup() =>
        _send(recover iso StartupRequest.create(cql_version) end)


    fun ref _send(request: Request iso) =>
        let request_string: String val = request.string()
        let frame: Frame val = _createFrame(consume request)
        let data = OldVisitor(frame)
        
        if not _closed then
            _conn.write(data)
            _log(Info, "-> " + request_string)
        else
            _log(Info, "-| " + request_string)
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
        | let m: ReadyResponse val => _ready(m)
        | let m: AuthenticateResponse val => _authenticate(m)
        | let m: AuthSuccessResponse val => _authenticated(m)
        | let m: ErrorResponse val if m.code == 0x0100 => _authenticate_failed(m)
        | let m: Response val => _notify.received(this, m)
        end


    be throttled(conn: TCPConnection tag) =>
        None


    be unthrottled(conn: TCPConnection tag) =>
        None


    be query(q: QueryRequest iso) =>
        _send(consume q)
