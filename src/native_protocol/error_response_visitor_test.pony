use "ponytest"

actor ErrorResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(ErrorResponseVisitorTest)


class iso ErrorResponseVisitorTest is UnitTest
    fun name(): String => "ErrorResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let request: ErrorResponse val = ErrorResponse(0x0000, "Server error")
        let result: Array[U8 val] val = recover ErrorResponseVisitor(request) end
        h.assert_eq[String val](
            "00000000000C536572766572206572726F72",
            Bytes.to_hex_string(result)
        )
