class ErrorResponseParser is Parser[ErrorResponse]

    fun box apply(data: Seq[U8 val] ref): ErrorResponse iso^ ? =>
        ErrorResponse(IntParser(data), StringParser(data))
