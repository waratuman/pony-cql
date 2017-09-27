use "ponytest"
use "itertools"
use "./native_protocol"

actor AuthenticatorTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestAuthenticatorCreate)
        test(_TestAuthenticatorToken)
        test(_TestAuthenticatorName)


class iso _TestAuthenticatorCreate is UnitTest

    fun name(): String =>
        "Authenticator.create"

    fun tag apply(h: TestHelper) =>
        let authenticator = PasswordAuthenticator.create()


class iso _TestAuthenticatorToken is UnitTest

    fun name(): String =>
        "Authenticator.token"

    fun tag apply(h: TestHelper) =>
        let authenticator: PasswordAuthenticator ref = PasswordAuthenticator.create()
        authenticator("username", "password")
        match authenticator.token()
        | let t: Array[U8 val] val => 
            let data = [as U8:
                0x00; 0x75; 0x73; 0x65; 0x72; 0x6E; 0x61; 0x6D; 0x65
                0x00; 0x70; 0x61; 0x73; 0x73; 0x77; 0x6F; 0x72; 0x64
            ]
            for (a, b) in Iter[U8 val](data.values()).zip[U8 val](t.values()) do
                h.assert_eq[U8](a, b)
            end
        else h.fail()
        end


class iso _TestAuthenticatorName is UnitTest
    
    fun name(): String =>
        "Authenticator.name"

    fun tag apply(h: TestHelper) =>
        let authenticator = PasswordAuthenticator.create()
        h.assert_eq[String val](
            "org.apache.cassandra.auth.PasswordAuthenticator",
            authenticator.name()
        )
