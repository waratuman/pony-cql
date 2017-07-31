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
        var data: Array[U8 val] ref = Array[U8 val]
        var request: OptionsRequest val = OptionsRequestParser(data)
        try request as OptionsRequest val
            h.complete(true)
        else
            h.fail()
        end
