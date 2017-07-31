use "ponytest"

actor AuthResponseRequestTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestAuthResponseRequestCreate)
        test(_TestAuthResponseRequestString)


class iso _TestAuthResponseRequestCreate is UnitTest

    fun name(): String =>
        "AuthResponseRequest.create"
    
    fun tag apply(h: TestHelper) ? =>
        var request = AuthResponseRequest()
        match request.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        request = AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end)
        match request.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0)?)
            h.assert_eq[U8](0xCD, t(1)?)
        else h.fail()
        end


class iso _TestAuthResponseRequestString is UnitTest

    fun name(): String =>
        "AuthResponseRequest.string"
    
    fun tag apply(h: TestHelper) =>
        var request = AuthResponseRequest()
        h.assert_eq[String val](
            "AUTH_RESPONSE",
            request.string()
        )

        request = AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end)
        h.assert_eq[String val](
            "AUTH_RESPONSE",
            request.string()
        )
