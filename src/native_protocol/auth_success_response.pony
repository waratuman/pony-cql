class val AuthSuccessResponse is Stringable

    let token: (Array[U8 val] val | None)

    new val create(token': (Array[U8 val] val | None) = None) =>
        token = token'
    
    fun string(): String iso^ =>
        "AUTH_SUCCESS".string()
