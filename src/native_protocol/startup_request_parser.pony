class StartupRequestParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): StartupRequest val ? =>
        let map = stack.string_map()

        if map.contains("COMPRESSION") then
            StartupRequest(map("CQL_VERSION"), map("COMPRESSION"))
        else
            StartupRequest(map("CQL_VERSION"))
        end

