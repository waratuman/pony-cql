class AuthSuccessResponseParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): AuthSuccessResponse val ? =>
        let token = stack.bytes()
        AuthSuccessResponse(token)
