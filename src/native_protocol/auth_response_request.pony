class iso AuthResponseRequest is Stringable
    
    let token: (Array[U8 val] val | None val)

    new iso create(token': (Array[U8 val] val | None val) = None) =>
        token = token'
    
    fun box string(): String iso^ =>
        "AUTH_RESPONSE".string()
