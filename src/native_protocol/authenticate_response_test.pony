use "ponytest"

actor AuthenticateResponseTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestAuthenticateResponseCreate)
        test(_TestAuthenticateResponseString)


class iso _TestAuthenticateResponseCreate is UnitTest

    fun name(): String =>
        "AuthenticateResponse.create"

    fun tag apply(h: TestHelper) =>
        let response = AuthenticateResponse("org.apache.cassandra.auth.PasswordAuthenticator")
        h.assert_eq[String val](
            "org.apache.cassandra.auth.PasswordAuthenticator",
            response.authenticator_name
        )


class iso _TestAuthenticateResponseString is UnitTest

    fun name(): String =>
        "AuthenticateResponse.string"

    fun tag apply(h: TestHelper) =>
        let response = AuthenticateResponse("org.apache.cassandra.auth.PasswordAuthenticator")
        h.assert_eq[String val](
            "AUTHENTICATE org.apache.cassandra.auth.PasswordAuthenticator",
            response.string()
        )
