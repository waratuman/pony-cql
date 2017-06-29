use "ponytest"

actor OptionsRequestVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(OptionsRequestVisitorTest)


class iso OptionsRequestVisitorTest is UnitTest
    fun name(): String => "OptionsRequestVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let request: OptionsRequest val = OptionsRequest
        let result: Array[U8 val] val = recover OptionsRequestVisitor(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )
