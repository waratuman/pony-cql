use "ponytest"

actor AuthSuccessResponseTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestAuthSuccessResponseString)


class iso _TestAuthSuccessResponseString is UnitTest

    fun name(): String =>
        "AuthSuccessResponse.string"

    fun tag apply(h: TestHelper) =>
        var response = AuthSuccessResponse()
        h.assert_eq[String val]("AUTH_SUCCESS", response.string())

        response = AuthSuccessResponse(recover [as U8: 0xAB; 0xCD] end)
        h.assert_eq[String val]("AUTH_SUCCESS", response.string())
