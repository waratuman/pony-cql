use "format"

type Response is (
    ErrorResponse
    | ReadyResponse
    | AuthenticateResponse
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

    let authenticator: String val

    new val create(authenticator': String) =>
        authenticator = authenticator'

    fun string(): String val =>
        "AUTHENTICATE " + authenticator
