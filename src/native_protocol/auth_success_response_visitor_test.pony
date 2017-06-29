use "ponytest"


actor AuthSuccessResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthSuccessResponseVisitorTest)


class iso AuthSuccessResponseVisitorTest is UnitTest
    fun name(): String => "AuthSuccessResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var response: AuthSuccessResponse val = recover AuthSuccessResponse() end
        var result: Array[U8 val] val = recover AuthSuccessResponseVisitor(response) end
        h.assert_eq[String val](
            "FFFFFFFF",
            Bytes.to_hex_string(result)
        )

        response = recover AuthSuccessResponse(recover [as U8: 0xAB; 0xCD] end) end
        result = recover AuthSuccessResponseVisitor(response) end
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(result)
        )
