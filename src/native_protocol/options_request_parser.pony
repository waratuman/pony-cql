class OptionsRequestParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): OptionsRequest iso^ =>
        OptionsRequest
