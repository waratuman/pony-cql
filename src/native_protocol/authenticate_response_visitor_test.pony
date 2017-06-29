use "ponytest"


actor AuthenticateResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthenticateResponseVisitorTest)


class iso AuthenticateResponseVisitorTest is UnitTest

    fun name(): String =>
        "AuthenticateResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let response: AuthenticateResponse val = recover AuthenticateResponse("org.apache.cassandra.auth.PasswordAuthenticator") end
        let result: Array[U8 val] val = recover AuthenticateResponseVisitor(response) end
        h.assert_eq[String val](
            "002F6F72672E6170616368652E63617373616E6472612E617574682E50617373776F726441757468656E74696361746F72",
            Bytes.to_hex_string(result)
        )
