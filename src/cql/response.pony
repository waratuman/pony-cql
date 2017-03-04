type Response is (
    ReadyResponse
)

class val ReadyResponse

    new val apply() =>
        None

    new val create() =>
        None

    fun string(): String val =>
        "READY"
