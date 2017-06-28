class AuthSuccessResponseParser is Parser[AuthSuccessResponse]

    fun box apply(data: Seq[U8 val] ref): AuthSuccessResponse iso^ ? =>
        let token: (Array[U8 val] iso | None val) = BytesParser(data)
        recover iso AuthSuccessResponse(consume token) end
