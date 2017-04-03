use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor ParserTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestParseFrame)
        test(_TestParseStartupRequest)
        test(_TestParseAuthResponseRequest)
        test(_TestParseOptionsRequest)
        
        test(_TestParseErrorResponse)
        test(_TestParseReadyResponse)
        test(_TestParseAuthenticateResponse)
        test(_TestParseSupportedResponse)
        test(_TestParseAuthSuccessResponse)

        test(_TestParseString)
        test(_TestParseStringList)
        test(_TestParseShort)
        test(_TestParseInt)
        test(_TestParseStringMap)
        test(_TestParseStringMultiMap)
        test(_TestParseBytes)

class iso _TestParseFrame is UnitTest
    fun name(): String => "Parser.parseFrame"

    fun tag apply(h: TestHelper) ? => 
        var data: Array[U8 val] val = Bytes.from_hex_string("0400000001000000160001000B43514C5F56455253494F4E0005332E302E30")
        var frame = Parser(data).parseFrame()

        h.assert_eq[U8](4, frame.version)
        h.assert_eq[U8](0, frame.flags)
        h.assert_eq[U16](0, frame.stream)
        
        match frame.body
        | let b: StartupRequest => h.assert_eq[String]("3.0.0", b.cqlVersion)
        else h.fail()
        end

        data = Bytes.from_hex_string("040000010F00000004FFFFFFFF")
        frame = Parser(data).parseFrame()
        
        h.assert_eq[U8](4, frame.version)
        h.assert_eq[U8](0, frame.flags)
        h.assert_eq[U16](1, frame.stream)
        match frame.body
        | let b: AuthResponseRequest => None
        else h.fail()
        end

class iso _TestParseStartupRequest is UnitTest
    fun name(): String => "Parser.parseStartupRequest"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("0001000B43514C5F56455253494F4E0005332E302E30")
        var request = Parser(data).parseStartupRequest()

        h.assert_eq[String val]("3.0.0", request.cqlVersion)
        match request.compression
        | let c: None => h.assert_eq[None val](None, c)
        else h.fail()
        end

        data = Bytes.from_hex_string("0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30")
        request = Parser(data).parseStartupRequest()
        h.assert_eq[String val]("3.0.0", request.cqlVersion)
        match request.compression
        | let c: String => h.assert_eq[String val]("snappy", c)
        else h.fail()
        end

class iso _TestParseAuthResponseRequest is UnitTest
    fun name(): String => "Parser.parseAuthResponseRequest"

    fun tag apply(h: TestHelper) ? =>
        var data = Bytes.from_hex_string("FFFFFFFF")
        var request = Parser(data).parseAuthResponseRequest()

        match request.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        data = Bytes.from_hex_string("00000002ABCD")
        request = Parser(data).parseAuthResponseRequest()

        match request.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end

class iso _TestParseOptionsRequest is UnitTest
    fun name(): String => "Parser.parseOptionsRequest"

    fun tag apply(h: TestHelper) =>
        var data: Array[U8 val] val = recover Array[U8 val]() end
        var request = Parser(data).parseOptionsRequest()
        var result: Array[U8 val] val = recover Visitor.visitOptionsRequest(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )

class iso _TestParseErrorResponse is UnitTest
    fun name(): String => "Parser.parseErrorResponse"

    fun tag apply(h: TestHelper) ? =>
        let data = Bytes.from_hex_string("00000000000C536572766572206572726F72")
        let response = Parser(data).parseErrorResponse()
        h.assert_eq[I32 val](0, response.code)
        h.assert_eq[String val]("Server error", response.message)


class iso _TestParseReadyResponse is UnitTest
    fun name(): String => "Parser.parseReadyResponse"

    fun tag apply(h: TestHelper) ? =>
        let data = Bytes.from_hex_string("FFFFFFFF") // Extra data should be ignored
        Parser(data).parseReadyResponse()


class iso _TestParseAuthenticateResponse is UnitTest
    fun name(): String => "Parser.parseAuthenticateResponse"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("002F6F72672E6170616368652E63617373616E6472612E617574682E50617373776F726441757468656E74696361746F72")
        var response = Parser(data).parseAuthenticateResponse()
        h.assert_eq[String val](
            "org.apache.cassandra.auth.PasswordAuthenticator",
            response.authenticator_name
        )

class iso _TestParseSupportedResponse is UnitTest

    fun name(): String => "Parser.parseSupportedResponse"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("0002000B434F4D5052455353494F4E00020006736E6170707900036C7A6F000B43514C5F56455253494F4E00010005332E302E30")
        var response = Parser(data).parseSupportedResponse()
        h.assert_eq[String val]("3.0.0", response.cql_version(0))
        h.assert_eq[String val]("snappy", response.compression(0))
        h.assert_eq[String val]("lzo", response.compression(1))

        // h.assert_eq[Array[String val] val](
        //     ["snappy"], response.compression
        // )

class iso _TestParseAuthSuccessResponse is UnitTest
    fun name(): String => "Parser.parseAuthSuccessResponse"

    fun tag apply(h: TestHelper) ? =>
        var data = Bytes.from_hex_string("FFFFFFFF")
        var response = Parser(data).parseAuthSuccessResponse()

        match response.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        data = Bytes.from_hex_string("00000002ABCD")
        response = Parser(data).parseAuthSuccessResponse()

        match response.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end

class iso _TestParseString is UnitTest
    fun name(): String => "Parser.parseString"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61] end
        h.assert_eq[String val](
            "cassandra",
            Parser(data).parseString()
        )

class iso _TestParseStringList is UnitTest
    fun name(): String => "Parser.parseStringList"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0x00; 0x01; 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61] end
        let result: Array[String val] val = Parser(data).parseStringList()
        h.assert_eq[String val](
            "cassandra",
            result(0)
        )

class iso _TestParseShort is UnitTest
    fun name(): String => "Parser.parseShort"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0x00; 0x09] end
        h.assert_eq[U16 val](
            9,
            Parser(data).parseShort()
        )

class iso _TestParseInt is UnitTest
    fun name(): String => "Parser.parseInt"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end
        h.assert_eq[I32 val](
            -1,
            Parser(data).parseInt()
        )

class iso _TestParseStringMap is UnitTest
    fun name(): String => "Parser.parseStringMap"

    fun tag apply(h: TestHelper) ? =>
        let data = Bytes.from_hex_string("0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30")
        let map = Parser(data).parseStringMap()
        h.assert_eq[String val]("snappy", map("COMPRESSION"))
        h.assert_eq[String val]("3.0.0", map("CQL_VERSION"))

class iso _TestParseStringMultiMap is UnitTest
    fun name(): String => "Parser.parseStringMultiMap"

    fun tag apply(h: TestHelper) ? =>
        let data = Bytes.from_hex_string("0002000B434F4D5052455353494F4E00020006736E6170707900036C7A6F000B43514C5F56455253494F4E00010005332E302E30")
        let map = Parser(data).parseStringMultiMap()
        h.assert_eq[String val]("snappy", map("COMPRESSION")(0))
        h.assert_eq[String val]("lzo", map("COMPRESSION")(1))
        h.assert_eq[String val]("3.0.0", map("CQL_VERSION")(0))

class iso _TestParseBytes is UnitTest
    fun name(): String => "Parser.parseBytes"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover [as U8: 0x00; 0x00; 0x00; 0x02; 0xAB; 0xCD] end
        var result = Parser(data).parseBytes()
        match result
        | let r: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, r(0))
            h.assert_eq[U8](0xCD, r(1))
        else h.fail()
        end
        

        data = recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end
        result = Parser(data).parseBytes()
        match result
        | let r: None => h.assert_eq[None val](None, r)
        else h.fail()
        end
