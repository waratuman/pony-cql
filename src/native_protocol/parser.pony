interface Parser

    new ref create(stack: Stack ref)

    fun ref parse(): Any ?
