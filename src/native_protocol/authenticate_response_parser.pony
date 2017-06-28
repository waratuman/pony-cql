class AuthenticateResponseParser is Parser[AuthenticateResponse]

    fun box apply(data: Seq[U8 val] ref): AuthenticateResponse iso^ ? =>
        AuthenticateResponse(StringParser(data))
