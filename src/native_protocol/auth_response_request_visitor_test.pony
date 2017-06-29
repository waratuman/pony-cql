use "ponytest"

actor AuthResponseRequestVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthResponseRequestVisitorTest)


class iso AuthResponseRequestVisitorTest is UnitTest

    fun name(): String =>
        "AuthResponseRequestVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var request: AuthResponseRequest val = recover AuthResponseRequest() end
        var result: Array[U8 val] val = recover AuthResponseRequestVisitor(request) end
        h.assert_eq[String val](
            "FFFFFFFF",
            Bytes.to_hex_string(result)
        )

        request = recover AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end) end
        result = recover AuthResponseRequestVisitor(request) end
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(result)
        )
