use "ponytest"


actor ResultResponseTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestResultResponseString)


class iso _TestResultResponseString is UnitTest

    fun name(): String val =>
        "ResultResponse.string"

    fun tag apply(h: TestHelper) =>
        let response = VoidResultResponse.create()
        h.assert_eq[String val]("RESULT VOID", response.string())
