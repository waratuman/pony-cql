use "ponytest"

actor ErrorResponseParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(ErrorResponseParserTest)


class iso ErrorResponseParserTest is UnitTest

    fun name(): String =>
        "ErrorResponseParser.parse"
    
    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover [as U8:
            0x00; 0x00; 0x00; 0x00; 0x00; 0x0C; 0x53; 0x65; 0x72; 0x76; 0x65
            0x72; 0x20; 0x65; 0x72; 0x72; 0x6F; 0x72
        ] end
        var stack = Stack(data)
        var response = ErrorResponseParser.create(stack).parse()
        h.assert_eq[I32 val](0, response.code)
        h.assert_eq[String val]("Server error", response.message)
