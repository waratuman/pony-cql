use "format"
use "ponytest"
use collection = "collections"

actor ResponseTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestReadyResponseString)
        test(_TestAuthenticateResponseString)

class iso _TestReadyResponseString is UnitTest
    fun name(): String => "ReadyResponse.string"
    
    fun tag apply(h: TestHelper) => 
        let response = ReadyResponse()
        h.assert_eq[String val](
            "READY",
            response.string()
        )

class iso _TestAuthenticateResponseString is UnitTest
    fun name(): String => "AuthenticateResponse.string"
    
    fun tag apply(h: TestHelper) => 
        let response = AuthenticateResponse("org.apache.cassandra.auth.PasswordAuthenticator")
        h.assert_eq[String val](
            "AUTHENTICATE org.apache.cassandra.auth.PasswordAuthenticator",
            response.string()
        )
