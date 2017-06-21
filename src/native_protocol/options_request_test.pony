use "ponytest"

actor OptionsRequestTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestOptionsRequestString)


class iso _TestOptionsRequestString is UnitTest

    fun name(): String =>
        "OptionsRequest.string"

    fun tag apply(h: TestHelper) =>
        let request = OptionsRequest.create()
        h.assert_eq[String val]("OPTIONS", request.string())
