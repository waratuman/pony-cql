class StartupRequestParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): StartupRequest iso^ ? =>
        let map = stack.take_string_map()

        if map.contains("COMPRESSION") then
            StartupRequest(map("CQL_VERSION"), map("COMPRESSION"))
        else
            StartupRequest(map("CQL_VERSION"))
        end

