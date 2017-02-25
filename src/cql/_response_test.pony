use "format"
use "ponytest"
use collection = "collections"

actor ResponseTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestResponseString)

class iso _TestResponseString is UnitTest
    fun name(): String => "cql/response/string"
    fun tag apply(h: TestHelper) ? =>
        h.assert_eq[String val](
            "[0] READY",
            recover
                let data: Array[U8 val] val = recover
                    [0x84, 0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00]
                end
                Response.decode( data).string()
            end
        )
