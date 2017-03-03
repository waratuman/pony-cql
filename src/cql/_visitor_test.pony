use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor VisitorTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestVisitStartupRequest)
        test(_TestVisitAuthResponseRequest)
        test(_TestVisitOptionsRequest)

        test(_TestVisitNone)
        test(_TestVisitInt)
        test(_TestVisitShort)
        test(_TestVisitBytes)
        test(_TestVisitString)

class iso _TestVisitStartupRequest is UnitTest
    fun name(): String => "Visitor.visitStartupRequest"

    fun tag apply(h: TestHelper) =>
        var request: StartupRequest val = recover StartupRequest("3.0.0") end
        h.assert_eq[String val](
            "0001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(Visitor(request))
        )

        request = recover StartupRequest("3.0.0", "snappy") end
        h.assert_eq[String val](
            "0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(Visitor(request))
        )

class iso _TestVisitAuthResponseRequest is UnitTest
    fun name(): String => "Visitor.visitAuthResponseRequest"

    fun tag apply(h: TestHelper) =>
        var request: AuthResponseRequest val = recover AuthResponseRequest() end
        h.assert_eq[String val](
            "FFFFFFFF",
            Bytes.to_hex_string(Visitor(request))
        )

        request = recover AuthResponseRequest(recover [as U8: 0xAB, 0xCD] end) end
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(Visitor(request))
        )

class iso _TestVisitOptionsRequest is UnitTest
    fun name(): String => "Visitor.visitOptionsRequest"

    fun tag apply(h: TestHelper) =>
        let request: OptionsRequest val = recover OptionsRequest() end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(Visitor(request))
        )

class iso _TestVisitNone is UnitTest
    fun name(): String => "Visitor.visitNone"

    fun tag apply(h: TestHelper) =>
        let collector = Array[U8 val]()
        Visitor.visitNone(collector, None)
        h.assert_eq[USize](0, collector.size())

class iso _TestVisitInt is UnitTest
    fun name(): String => "Visitor.visitInt"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        Visitor.visitInt(collector, I32.min_value())
        h.assert_eq[U8](0x80, collector(0))
        h.assert_eq[U8](0x00, collector(1))
        h.assert_eq[U8](0x00, collector(2))
        h.assert_eq[U8](0x00, collector(3))
        
        collector = Array[U8 val]()
        Visitor.visitInt(collector, I32.max_value())
        h.assert_eq[U8](0x7F, collector(0))
        h.assert_eq[U8](0xFF, collector(1))
        h.assert_eq[U8](0xFF, collector(2))
        h.assert_eq[U8](0xFF, collector(3))

class iso _TestVisitShort is UnitTest
    fun name(): String => "Visitor.visitShort"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        Visitor.visitShort(collector, U16.min_value())
        h.assert_eq[U8](0x00, collector(0))
        h.assert_eq[U8](0x00, collector(1))
        
        collector = Array[U8 val]()
        Visitor.visitShort(collector, U16.max_value())
        h.assert_eq[U8](0xFF, collector(0))
        h.assert_eq[U8](0xFF, collector(1))

class iso _TestVisitBytes is UnitTest
    fun name(): String => "Visitor.visitBytes"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        Visitor.visitBytes(collector, recover [as U8: 0xAB, 0xCD] end)
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
        Visitor.visitString(collector, "CQL_VERSION")
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
