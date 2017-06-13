use "crypto"
use "chrono"
use "net"
use "format"
use "ponytest"
use "itertools"
use cql = "../cql"
use collection = "collections"

actor ParserTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestParseFrame)
        test(_TestParseStartupRequest)
        test(_TestParseAuthResponseRequest)
        test(_TestParseOptionsRequest)
        test(_TestParseQueryRequest)
        
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
    
    fun name(): String =>
        "Parser.parseAuthenticateResponse"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("002F6F72672E6170616368652E63617373616E6472612E617574682E50617373776F726441757468656E74696361746F72")
        var response = Parser(data).parseAuthenticateResponse()
        h.assert_eq[String val](
            "org.apache.cassandra.auth.PasswordAuthenticator",
            response.authenticator_name
        )

class iso _TestParseSupportedResponse is UnitTest

    fun name(): String =>
        "Parser.parseSupportedResponse"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("0002000B434F4D5052455353494F4E00020006736E6170707900036C7A6F000B43514C5F56455253494F4E00010005332E302E30")
        var response = Parser(data).parseSupportedResponse()
        h.assert_eq[String val]("3.0.0", response.cql_version(0))
        h.assert_eq[String val]("snappy", response.compression(0))
        h.assert_eq[String val]("lzo", response.compression(1))


class iso _TestParseQueryRequest is UnitTest

    fun name(): String val =>
        "Parser.parseQueryResponse"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("0000001553454C454354202A2046524F4D206578616D706C65000400")
        var request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example", request.query)
        h.assert_eq[Bool val](true, request.query_parameters is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010001FFFFFFFF")
        request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example WHERE id = ?", request.query)
        h.assert_eq[USize val](1, (request.query_parameters as Array[QueryParameter val] val).size())
        h.assert_eq[Bool val](true, (request.query_parameters as Array[QueryParameter val] val)(0) is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000002553454C454354202A2046524F4D206578616D706C6520574845524520656D61696C203D203F00040100010000001361646472657373406578616D706C652E636F6D")
        request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example WHERE email = ?", request.query)
        h.assert_eq[String val](
            "address@example.com",
            String.from_array((request.query_parameters as Array[QueryParameter val] val)(0) as Array[U8 val] val)
        )
        h.assert_eq[USize val](1, (request.query_parameters as Array[QueryParameter val] val).size())
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010010FFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB00000004000000200000006D0000000DFFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB000000040000002000000002001000000008000028259C3ACC000000000108000000CC0000000C000000036931360000000200100000000369333200000004000000200000000366363400000008405028F5C28F5C29000000056173636969000000064153434949210000000474696D6500000008000028259C3ACC00000000026938000000010800000004626C6F62000000030102030000000B6E65745F6164647265737300000004C00002EB000000046E756C6CFFFFFFFF000000046461746500000004800000000000000366333200000004420147AE00000006626967696E740000000800000000000000010000000D000000010000000576616C756500000002001000000008000028259C3ACC000000000108")
        let none: None val = None
        let ascii: String val = "ASCII!"
        let i64: I64 val = 1
        let blob: Array[U8 val] val = recover [1; 2; 3] end
        let bool: Bool val = true
        let date: Date val = recover Date(0) end
        let f64: F64 val = 64.64
        let f32: F32 val = 32.32
        let net_address = DNS((h.env.root as AmbientAuth), "192.0.2.235", "80")(0)
        let i32: I32 val = 32
        let i16: I16 val = 16
        let time: Time val = recover Time.civil(12, 15, 42) end
        let i8: I8 val = 8
        let list: Seq[cql.NativeType val] val = recover [as cql.NativeType: none; ascii; i64; blob; bool; date; f64; f32; net_address; i32; i16; time; i8] end
        let map: cql.MapType val = recover
            let map = collection.Map[String val, cql.NativeType val]()
            map.insert("null", none)
            map.insert("ascii", ascii)
            map.insert("bigint", i64)
            map.insert("blob", blob)
            map.insert("date", date)
            map.insert("f64", f64)
            map.insert("f32", f32)
            map.insert("net_address", net_address)
            map.insert("i32", i32)
            map.insert("i16", i16)
            map.insert("time", time)
            map.insert("i8", i8)
            map
        end
        let set: cql.SetType val = recover
            let set = collection.Set[String val]
            set.set("value")
            set
        end
        request = Parser(data).parseQueryRequest()
        let params = request.query_parameters as Array[QueryParameter val] val
        h.assert_eq[String val]("SELECT * FROM example WHERE id = ?", request.query)
        h.assert_eq[USize val](16, params.size())
        h.assert_eq[None val](none, params(0) as None val)
        h.assert_eq[String val](String.from_array(params(1) as Array[U8 val] val), ascii)
        for (a, b) in Zip2[U8 val, U8 val]((params(15) as Array[U8 val] val).values(), (recover [i8.u8()] end).values()) do
            h.assert_eq[U8 val](a, b)
        end
        

        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        let consistencies = [as Consistency: AnyConsistency; One; Two; Three; Quorum; All; LocalQuorum; EachQuorum; Serial; LocalSerial; LocalOne]
        for consistency in consistencies.values() do
            data = Bytes.from_hex_string("0000001553454C454354202A2046524F4D206578616D706C65" + Bytes.to_hex_string(Bytes.ofU16(consistency.value())) + "00")
            request = Parser(data).parseQueryRequest()
            h.assert_eq[Consistency val](request.consistency, consistency)
        end

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B000402")
        request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.query_parameters is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](false, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)
        
        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B00040400000001")
        request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.query_parameters is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[I32 val](1, request.page_size as I32 val)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B0004080000000401020304")
        request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.query_parameters is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        for (a, b) in Zip2[U8 val, U8 val]((request.paging_state as Array[U8 val] val).values(), (recover [as U8: 1; 2; 3; 4] end).values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B0004100009")
        request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.query_parameters is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is LocalSerial)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B00042000000002540BE3FF")
        request = Parser(data).parseQueryRequest()
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.query_parameters is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[I64 val](9999999999, request.timestamp as I64)


class iso _TestParseAuthSuccessResponse is UnitTest
    
    fun name(): String =>
        "Parser.parseAuthSuccessResponse"

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

    fun name(): String =>
        "Parser.parseString"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61] end
        h.assert_eq[String val](
            "cassandra",
            Parser(data).parseString()
        )

class iso _TestParseStringList is UnitTest

    fun name(): String =>
        "Parser.parseStringList"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0x00; 0x01; 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61] end
        let result: Array[String val] val = Parser(data).parseStringList()
        h.assert_eq[String val](
            "cassandra",
            result(0)
        )

class iso _TestParseShort is UnitTest

    fun name(): String =>
        "Parser.parseShort"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0x00; 0x09] end
        h.assert_eq[U16 val](
            9,
            Parser(data).parseShort()
        )

class iso _TestParseInt is UnitTest

    fun name(): String =>
        "Parser.parseInt"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end
        h.assert_eq[I32 val](
            -1,
            Parser(data).parseInt()
        )

class iso _TestParseStringMap is UnitTest

    fun name(): String =>
        "Parser.parseStringMap"

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
