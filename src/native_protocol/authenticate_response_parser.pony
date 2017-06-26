class AuthenticateResponseParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): AuthenticateResponse iso^ ? =>
        AuthenticateResponse(stack.take_string())
