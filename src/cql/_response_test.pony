use "format"
use "ponytest"
use collection = "collections"

actor ResponseTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestResponseString)
        test(_TestAuthenticateResponse)

class iso _TestResponseString is UnitTest
    fun name(): String => "cql/response/string"
    fun tag apply(h: TestHelper) ? =>
        h.assert_eq[String val](
            "[0] READY",
            recover
                let data: Array[U8 val] val = recover
                    [0x84, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00]
                end
                Response.decode(data).string()
            end
        )

        h.assert_eq[String val](
            "[0] AUTHENTICATE org.apache.cassandra.auth.PasswordAuthenticator",
            recover
                let data = Bytes.from_hex_string("840000000300000031002F6F72672E6170616368652E63617373616E6472612E617574682E50617373776F726441757468656E74696361746F72")
                Response.decode(data).string()
            end
        )

class iso _TestAuthenticateResponse is UnitTest
    fun name(): String => "cql/response/authenticate"
    fun tag apply(h: TestHelper) ? => 
        h.assert_eq[String val](
            "[0] AUTHENTICATE org.apache.cassandra.auth.PasswordAuthenticator",
            recover
                let data = Bytes.from_hex_string("840000000300000031002F6F72672E6170616368652E63617373616E6472612E617574682E50617373776F726441757468656E74696361746F72")
                Response.decode(data).string()
            end
        )
