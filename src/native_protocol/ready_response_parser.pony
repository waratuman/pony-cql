class ReadyResponseParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): ReadyResponse iso^ =>
        ReadyResponse
