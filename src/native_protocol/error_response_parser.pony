class ErrorResponseParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): ErrorResponse val ? =>
        ErrorResponse(stack.int(), stack.string())
