use "ponytest"

actor OptionsRequestParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(OptionsRequestParserTest)


class iso OptionsRequestParserTest is UnitTest

    fun name(): String =>
        "OptionsRequestParser.parse"
    
    fun tag apply(h: TestHelper) =>
        var data: Array[U8 val] val = recover Array[U8 val]() end
        var stack = ParserStack(data)
        var request: OptionsRequest val = OptionsRequestParser(stack).parse()
        try request as OptionsRequest
            h.complete(true)
        else
            h.fail()
        end
