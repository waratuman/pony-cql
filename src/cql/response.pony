use "format"

type Response is (
    ErrorResponse
    | ReadyResponse
    | AuthenticateResponse
    | AuthSuccessResponse
)

class val ErrorResponse

    let code: I32 val
    let message: String val

    new val create(code': I32 val, message': String val) =>
        code = code'
        message = message'
    
    fun string(): String val =>
        "ERROR " + Format.int[I32](code, FormatHex, PrefixDefault, 8) + " " + message

class val ReadyResponse

    new val apply() =>
        None

    new val create() =>
        None

    fun string(): String val =>
        "READY"

class val AuthenticateResponse

    let authenticator_name: String val

    new val create(authenticator_name': String) =>
        authenticator_name = authenticator_name'

    fun string(): String val =>
        "AUTHENTICATE " + authenticator_name

class val AuthSuccessResponse

    let token: (Array[U8 val] val | None)

    new val create(token': (Array[U8 val] val | None) = None) =>
        token = token'
    
    fun string(): String val =>
        "AUTH_SUCCESS"
