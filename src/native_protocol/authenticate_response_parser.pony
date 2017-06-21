class AuthenticateResponseParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): AuthenticateResponse val ? =>
        AuthenticateResponse(stack.string())
