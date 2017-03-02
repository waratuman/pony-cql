use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor ParserTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestParseStartupRequest)
        test(_TestParseAuthResponseRequest)
        test(_TestParseOptionsRequest)

class iso _TestParseStartupRequest is UnitTest
    fun name(): String => "Parser.parseStartupRequest"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("0001000B43514C5F56455253494F4E0005332E302E30")
        var request = Parser.parseStartupRequest(data)

        h.assert_eq[String val]("3.0.0", request.cqlVersion)
        match request.compression
        | let c: None => h.assert_eq[None val](None, c)
        else h.fail()
        end

        data = Bytes.from_hex_string("0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30")
        request = Parser.parseStartupRequest(data)
        h.assert_eq[String val]("3.0.0", request.cqlVersion)
        match request.compression
        | let c: String => h.assert_eq[String val]("snappy", c)
        else h.fail()
        end

class iso _TestParseAuthResponseRequest is UnitTest
    fun name(): String => "Parser.parseAuthResponseRequest"

    fun tag apply(h: TestHelper) ? =>
        var data = Bytes.from_hex_string("FFFFFFFF")
        var request = Parser.parseAuthResponseRequest(data)

        match request.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        data = Bytes.from_hex_string("00000002ABCD")
        request = Parser.parseAuthResponseRequest(data)

        match request.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end

class iso _TestParseOptionsRequest is UnitTest
    fun name(): String => "Parser.parseOptionsRequest"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover Array[U8 val]() end
        var request = Parser.parseOptionsRequest(data)
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(Visitor(request))
        )

        // Extra data should be ignored
        data = Bytes.from_hex_string("FFFFFFFF")
        request = Parser.parseOptionsRequest(data)
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(Visitor(request))
        )

