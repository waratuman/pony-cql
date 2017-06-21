class OptionsRequestParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): OptionsRequest val =>
        OptionsRequest
