class AuthSuccessResponseParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): AuthSuccessResponse iso^ ? =>
        let token = stack.take_bytes()
        AuthSuccessResponse(token)
