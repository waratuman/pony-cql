use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor ParserTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestParseMessage)
        test(_TestParseStartupRequest)
        test(_TestParseAuthResponseRequest)
        test(_TestParseOptionsRequest)

        test(_TestParseReadyResponse)

class iso _TestParseMessage is UnitTest
    fun name(): String => "Parser.parseMessage"

    fun tag apply(h: TestHelper) ? => 
        var data: Array[U8 val] val = Bytes.from_hex_string("0400000001000000160001000B43514C5F56455253494F4E0005332E302E30")
        var message = Parser.parseMessage(data)

        h.assert_eq[U8](4, message.version)
        h.assert_eq[U8](0, message.flags)
        h.assert_eq[U16](0, message.stream)
        
        match message.body
        | let b: StartupRequest => h.assert_eq[String]("3.0.0", b.cqlVersion)
        else h.fail()
        end

        data = Bytes.from_hex_string("040000010F0000000600000002ABCD")
        message = Parser.parseMessage(data)
        
        h.assert_eq[U8](4, message.version)
        h.assert_eq[U8](0, message.flags)
        h.assert_eq[U16](1, message.stream)
        match message.body
        | let b: AuthResponseRequest => None
        else h.fail()
        end

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
        var result: Array[U8 val] val = recover Visitor.visitOptionsRequest(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )

        // Extra data should be ignored
        data = Bytes.from_hex_string("FFFFFFFF")
        request = Parser.parseOptionsRequest(data)
        result = recover Visitor.visitOptionsRequest(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )

class iso _TestParseReadyResponse is UnitTest
    fun name(): String => "Parser.parseReadyResponse"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover Array[U8 val]() end
        var request = Parser.parseReadyResponse(data)
        var result: Array[U8 val] val = recover Visitor.visitReadyResponse(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )

        // Extra data should be ignored
        data = Bytes.from_hex_string("FFFFFFFF")
        request = Parser.parseReadyResponse(data)
        result = recover Visitor.visitReadyResponse(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )

// class iso _TestParseBytes is UnitTest