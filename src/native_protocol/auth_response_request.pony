class val AuthResponseRequest is Stringable
    
    let token: (Array[U8 val] val | None val)

    new val create(token': (Array[U8 val] val | None val) = None) =>
        token = token'
    
    fun string(): String iso^ =>
        "AUTH_RESPONSE".string()
