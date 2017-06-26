class AuthResponseRequestParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): AuthResponseRequest iso^ ? =>
        let token = stack.take_bytes()
        AuthResponseRequest(token)
