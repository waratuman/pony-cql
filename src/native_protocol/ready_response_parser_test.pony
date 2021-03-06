use "ponytest"

actor ReadyResponseParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(ReadyResponseParserTest)


class iso ReadyResponseParserTest is UnitTest

    fun name(): String =>
        "ReadyResponseParser.parse"
    
    fun tag apply(h: TestHelper) =>
        var data: Array[U8 val] ref = [as U8:
            0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF
        ]
        var response: ReadyResponse ref = ReadyResponseParser(data)
        h.assert_eq[USize val](8, data.size())
