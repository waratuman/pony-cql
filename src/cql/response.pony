type Response is (
    ReadyResponse
    | AuthenticateResponse
)

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
