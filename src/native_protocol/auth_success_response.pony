class iso AuthSuccessResponse is Stringable

    let token: (Array[U8 val] val | None)

    new iso create(token': (Array[U8 val] val | None) = None) =>
        token = token'
    
    fun box string(): String iso^ =>
        "AUTH_SUCCESS".string()
