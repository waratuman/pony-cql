use "ponytest"

actor AuthenticatorTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestAuthenticatorCreate)
        test(_TestAuthenticatorToken)
        test(_TestAuthenticatorName)

class iso _TestAuthenticatorCreate is UnitTest
    fun name(): String => "Authenticator.create"

    fun tag apply(h: TestHelper) =>
        let authenticator = PasswordAuthenticator.create("username", "password")
        h.assert_eq[String val]("username", authenticator.username)
        h.assert_eq[String val]("password", authenticator.password)

class iso _TestAuthenticatorToken is UnitTest
    fun name(): String => "Authenticator.token"

    fun tag apply(h: TestHelper) =>
        let authenticator = PasswordAuthenticator.create("username", "password")
        h.assert_eq[String val](
            "00757365726E616D650070617373776F7264",
            Bytes.to_hex_string(authenticator.token())
        )

class iso _TestAuthenticatorName is UnitTest
    fun name(): String => "Authenticator.name"

    fun tag apply(h: TestHelper) =>
        let authenticator = PasswordAuthenticator.create("username", "password")
        h.assert_eq[String val](
            "org.apache.cassandra.auth.PasswordAuthenticator",
            authenticator.name()
        )
