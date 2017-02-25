use "format"
use "ponytest"
use collection = "collections"

actor RequestTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestRequestCreate)
        test(_TestRequestEncode)
        test(_TestRequestString)


class iso _TestRequestCreate is UnitTest
    fun name(): String => "cql/request/create"
    
    fun tag apply(h: TestHelper) =>
        var request = Request.create(Startup, 0, None)
        h.assert_eq[U8](Startup.value(), request.opcode.value())

        request = Request.create(Query, 0, None)
        h.assert_eq[U8](Query.value(), request.opcode.value())

class iso _TestRequestEncode is UnitTest
    fun name(): String => "cql/request/encode"

    fun tag apply(h: TestHelper) ? =>
        h.assert_eq[String val](
            "040000000100000000",
            recover
                let request = Request.create(Startup, 0, None)
                let hexString = String()
                for byte in request.encode().values() do
                    hexString.append(Format.int[U8](byte, FormatHexBare, PrefixDefault, 2))
                end
                hexString
            end
        )

        h.assert_eq[String val](
            "0400000001000000160001000B43514C5F56455253494F4E0005332E302E30",
            recover
                let body = recover
                    let b: collection.Map[String val, String val] ref = collection.Map[String val, String val]()
                    b.update("CQL_VERSION", "3.0.0")
                    b
                end
                let request = Request.create(Startup, 0, consume body)
                let hexString = String()
                for byte in request.encode().values() do
                    hexString.append(Format.int[U8](byte, FormatHexBare, PrefixDefault, 2))
                end
                hexString
            end
        )

class iso _TestRequestString is UnitTest
    fun name(): String => "cql/request/string"
    fun tag apply(h: TestHelper) =>
        h.assert_eq[String val](
            "[0] STARTUP",
            recover
                let body = recover
                    let b: collection.Map[String val, String val] ref = collection.Map[String val, String val]()
                    b.update("CQL_VERSION", "3.0.0")
                    b
                end
                let request = Request.create(Startup, 0, None)
                request.string()
            end
        )

        h.assert_eq[String val](
            "[0] STARTUP { \"CQL_VERSION\": \"3.0.0\" }",
            recover
                let body = recover
                    let b: collection.Map[String val, String val] ref = collection.Map[String val, String val]()
                    b.update("CQL_VERSION", "3.0.0")
                    b
                end
                let request = Request.create(Startup, 0, consume body)
                request.string()
            end
        )
