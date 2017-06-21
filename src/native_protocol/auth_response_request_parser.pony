class AuthResponseRequestParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): AuthResponseRequest val ? =>
        let token = stack.bytes()
        AuthResponseRequest(token)
