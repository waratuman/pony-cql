use "ponytest"

actor ReadyResponseTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestReadyResponseString)


class iso _TestReadyResponseString is UnitTest

    fun name(): String =>
        "ReadyResponse.string"
    
    fun tag apply(h: TestHelper) => 
        let response = ReadyResponse()
        h.assert_eq[String val]("READY", response.string())
