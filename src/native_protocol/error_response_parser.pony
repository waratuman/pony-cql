class ErrorResponseParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): ErrorResponse iso^ ? =>
        ErrorResponse(stack.take_int(), stack.take_string())
