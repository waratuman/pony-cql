use "ponytest"

actor ResultResponseParserTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestResultResponseParser)
        test(_TestVoidResultResponseParser)
        test(_TestRowsResultResponseParser)


class iso _TestResultResponseParser is UnitTest

    fun name(): String val =>
        "ResultResponseParser.apply"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso _TestVoidResultResponseParser is UnitTest

    fun name(): String val =>
        "VoidResultResponseParser.apply"

    fun tag apply(h: TestHelper) =>
        let response = VoidResultResponseParser([as U8: 0])
        match response
        | let x: VoidResultResponse iso! => None
        end


class iso _TestRowsResultResponseParser is UnitTest

    fun name(): String val =>
        "RowResultResponseParser.apply"
    
    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0]
        h.fail()
