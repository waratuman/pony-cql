primitive AuthenticateResponseVisitor is Visitor[AuthenticateResponse val]

    fun box apply(res: AuthenticateResponse val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        StringVisitor(res.authenticator_name, c)
        c
