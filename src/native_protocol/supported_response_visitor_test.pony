use "ponytest"

actor SupportedResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(SupportedResponseVisitorTest)


class iso SupportedResponseVisitorTest is UnitTest

    fun name(): String =>
        "SupportedResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let response: SupportedResponse val = recover iso SupportedResponse(recover ["3.0.0"] end, recover ["snappy"; "lzo"] end) end
        let result: Array[U8 val] val = recover SupportedResponseVisitor(response) end
        h.assert_eq[String val](
            "0002000B434F4D5052455353494F4E00020006736E6170707900036C7A6F000B43514C5F56455253494F4E00010005332E302E30",
            Bytes.to_hex_string(result)
        )
