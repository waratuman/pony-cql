use "format"
use "ponytest"
use collection = "collections"

actor ResponseTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestErrorResponseCreate)
        test(_TestErrorResponseString)
        test(_TestReadyResponseString)
        test(_TestAuthenticateResponseString)
        test(_TestSupportedResponseString)
        test(_TestResultResponseString)
        test(_TestAuthSuccessResponseString)
        
class iso _TestErrorResponseCreate is UnitTest

    fun name(): String => "ErrorResponse.create"

    fun tag apply(h: TestHelper) =>
        let errorMessage = "java.lang.IndexOutOfBoundsException: index: 4, length: 131080 (expected: range(0, 44))"
        let response = ErrorResponse(0x0000, errorMessage)
        h.assert_eq[I32 val](0x0000, response.code)
        h.assert_eq[String val](errorMessage, response.message)

class iso _TestErrorResponseString is UnitTest

    fun name(): String => "ErrorResponse.string"

    fun tag apply(h: TestHelper) =>
        let errorMessage = "java.lang.IndexOutOfBoundsException: index: 4, length: 131080 (expected: range(0, 44))"
        let response = ErrorResponse(0x0000, errorMessage)
        h.assert_eq[String val](
            "ERROR 0x00000000 java.lang.IndexOutOfBoundsException: index: 4, length: 131080 (expected: range(0, 44))",
            response.string()
        )

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

class iso _TestSupportedResponseString is UnitTest

    fun name(): String val =>
        "SupportedResponse.string"

    fun tag apply(h: TestHelper) =>
        let response = SupportedResponse(recover ["3.0.0"] end, recover ["lzo"; "gzip"] end)
        h.assert_eq[String val](
            "SUPPORTED { \"COMPRESSION\": [\"lzo\", \"gzip\"], \"CQL_VERSION\": [\"3.0.0\"] }",
            response.string()
        )

class iso _TestResultResponseString is UnitTest

    fun name(): String val =>
        "SupportedResponse.string"

    fun tag apply(h: TestHelper) =>
        let response = VoidResultResponse.create()
        h.assert_eq[String val](
            "RESULT VOID",
            response.string()
        )

class iso _TestAuthSuccessResponseString is UnitTest
    fun name(): String => "AuthSuccessResponse.string"

    fun tag apply(h: TestHelper) => 
        var response = AuthSuccessResponse()
        h.assert_eq[String val](
            "AUTH_SUCCESS",
            response.string()
        )

        response = AuthSuccessResponse(recover [as U8: 0xAB; 0xCD] end)
        h.assert_eq[String val](
            "AUTH_SUCCESS",
            response.string()
        )
