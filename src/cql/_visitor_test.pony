use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor VisitorTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestVisitMesssage)
        test(_TestVisitStartupRequest)
        test(_TestVisitAuthResponseRequest)
        test(_TestVisitOptionsRequest)
        
        test(_TestVistReadyResponse)
        test(_TestVisitAuthenticateResponse)

        test(_TestVisitNone)
        test(_TestVisitInt)
        test(_TestVisitShort)
        test(_TestVisitBytes)
        test(_TestVisitString)
        test(_TestVisitStringMap)

class iso _TestVisitMesssage is UnitTest
    fun name(): String => "Visitor.visitFrame"

    fun tag apply(h: TestHelper) =>
        var request: Request val = recover StartupRequest("3.0.0") end
        var frame: Frame val = recover Frame(4, 0, 0, request) end
        var result: Array[U8 val] val = recover Visitor.visitFrame(frame) end
        
        h.assert_eq[String val](
            "0400000001000000160001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(result)
        )

        request = recover AuthResponseRequest(recover [as U8: 0xAB, 0xCD] end) end
        frame = recover Frame(4, 0, 0, request) end
        result = recover Visitor.visitFrame(frame) end
        h.assert_eq[String val](
            "040000000F0000000600000002ABCD",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitStartupRequest is UnitTest
    fun name(): String => "Visitor.visitStartupRequest"

    fun tag apply(h: TestHelper) =>
        var request: StartupRequest val = recover StartupRequest("3.0.0") end
        var result: Array[U8 val] val = recover Visitor.visitStartupRequest(request) end
        
        h.assert_eq[String val](
            "0001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(result)
        )

        request = recover StartupRequest("3.0.0", "snappy") end
        result = recover Visitor.visitStartupRequest(request) end
        h.assert_eq[String val](
            "0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitAuthResponseRequest is UnitTest
    fun name(): String => "Visitor.visitAuthResponseRequest"

    fun tag apply(h: TestHelper) =>
        var request: AuthResponseRequest val = recover AuthResponseRequest() end
        var result: Array[U8 val] val = recover Visitor.visitAuthResponseRequest(request) end
        h.assert_eq[String val](
            "FFFFFFFF",
            Bytes.to_hex_string(result)
        )

        request = recover AuthResponseRequest(recover [as U8: 0xAB, 0xCD] end) end
        result = recover Visitor.visitAuthResponseRequest(request) end
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitOptionsRequest is UnitTest
    fun name(): String => "Visitor.visitOptionsRequest"

    fun tag apply(h: TestHelper) =>
        let request: OptionsRequest val = recover OptionsRequest() end
        let result: Array[U8 val] val = recover Visitor.visitOptionsRequest(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )

class iso _TestVistReadyResponse is UnitTest
    fun name(): String => "Visitor.visitReady"

    fun tag apply(h: TestHelper) =>
        let collector = Array[U8 val]()
        Visitor.visitReadyResponse(ReadyResponse(), collector)
        h.assert_eq[USize](0, collector.size())

class iso _TestVisitAuthenticateResponse is UnitTest
    fun name(): String => "Visitor.visitAuthenticateResponse"

    fun tag apply(h: TestHelper) =>
        let request: AuthenticateResponse val = recover AuthenticateResponse("org.apache.cassandra.auth.PasswordAuthenticator") end
        let result: Array[U8 val] val = recover Visitor.visitAuthenticateResponse(request) end
        h.assert_eq[String val](
            "002F6F72672E6170616368652E63617373616E6472612E617574682E50617373776F726441757468656E74696361746F72",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitNone is UnitTest
    fun name(): String => "Visitor.visitNone"

    fun tag apply(h: TestHelper) =>
        let collector = Array[U8 val]()
        Visitor.visitNone(None, collector)
        h.assert_eq[USize](0, collector.size())

class iso _TestVisitInt is UnitTest
    fun name(): String => "Visitor.visitInt"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        Visitor.visitInt(I32.min_value(), collector)
        h.assert_eq[U8](0x80, collector(0))
        h.assert_eq[U8](0x00, collector(1))
        h.assert_eq[U8](0x00, collector(2))
        h.assert_eq[U8](0x00, collector(3))
        
        collector = Array[U8 val]()
        Visitor.visitInt(I32.max_value(), collector)
        h.assert_eq[U8](0x7F, collector(0))
        h.assert_eq[U8](0xFF, collector(1))
        h.assert_eq[U8](0xFF, collector(2))
        h.assert_eq[U8](0xFF, collector(3))

class iso _TestVisitShort is UnitTest
    fun name(): String => "Visitor.visitShort"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        Visitor.visitShort(U16.min_value(), collector)
        h.assert_eq[U8](0x00, collector(0))
        h.assert_eq[U8](0x00, collector(1))
        
        collector = Array[U8 val]()
        Visitor.visitShort(U16.max_value(), collector)
        h.assert_eq[U8](0xFF, collector(0))
        h.assert_eq[U8](0xFF, collector(1))

class iso _TestVisitBytes is UnitTest
    fun name(): String => "Visitor.visitBytes"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        Visitor.visitBytes(recover [as U8: 0xAB, 0xCD] end, collector)
        h.assert_eq[U8](0x00, collector(0))
        h.assert_eq[U8](0x00, collector(1))
        h.assert_eq[U8](0x00, collector(2))
        h.assert_eq[U8](0x02, collector(3))
        h.assert_eq[U8](0xAB, collector(4))
        h.assert_eq[U8](0xCD, collector(5))

class iso _TestVisitString is UnitTest
    fun name(): String => "Visitor.visitString"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        Visitor.visitString("CQL_VERSION", collector)
        h.assert_eq[U8](0x00, collector(0))
        h.assert_eq[U8](0x0B, collector(1))
        h.assert_eq[U8](0x43, collector(2))
        h.assert_eq[U8](0x51, collector(3))
        h.assert_eq[U8](0x4C, collector(4))
        h.assert_eq[U8](0x5F, collector(5))
        h.assert_eq[U8](0x56, collector(6))
        h.assert_eq[U8](0x45, collector(7))
        h.assert_eq[U8](0x52, collector(8))
        h.assert_eq[U8](0x53, collector(9))
        h.assert_eq[U8](0x49, collector(10))
        h.assert_eq[U8](0x4F, collector(11))
        h.assert_eq[U8](0x4E, collector(12))

class iso _TestVisitStringMap is UnitTest
    fun name(): String => "Visitor.visitStringMap"

    fun tag apply(h: TestHelper) ? =>
        let data: collection.Map[String val, String val] val = recover
            let d = collection.Map[String val, String val]()
            d.insert("username", "cassandra")
            d.insert("password", "cassandra")
            d
        end
        
        let collector: Array[U8 val] val = recover
            let c = Array[U8 val]()
            Visitor.visitStringMap(data, c)
            c
        end

        h.assert_eq[String val](
            "0002000870617373776F7264000963617373616E6472610008757365726E616D65000963617373616E647261",
            Bytes.to_hex_string(collector)
        )
