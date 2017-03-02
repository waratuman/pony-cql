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

class iso _TestVisitStartupRequest is UnitTest
    fun name(): String => "Visitor.visitStartupRequest"

    fun tag apply(h: TestHelper) =>
        var request = StartupRequest("3.0.0")
        h.assert_eq[String val](
            "0001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(Visitor(request))
        )

        request = StartupRequest("3.0.0", "snappy")
        h.assert_eq[String val](
            "0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(Visitor(request))
        )

class iso _TestVisitAuthResponseRequest is UnitTest
    fun name(): String => "Visitor.visitAuthResponseRequest"

    fun tag apply(h: TestHelper) =>
        var request = AuthResponseRequest()
        h.assert_eq[String val](
            "FFFFFFFF",
            Bytes.to_hex_string(Visitor(request))
        )

        request = AuthResponseRequest(recover [as U8: 0xAB, 0xCD] end)
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(Visitor(request))
        )

class iso _TestVisitOptionsRequest is UnitTest
    fun name(): String => "Visitor.visitOptionsRequest"

    fun tag apply(h: TestHelper) =>
        let request = OptionsRequest.create()
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(Visitor(request))
        )
