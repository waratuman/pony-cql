interface Parser

    new create(stack: ParserStack ref)

    fun ref parse(): Any ?

