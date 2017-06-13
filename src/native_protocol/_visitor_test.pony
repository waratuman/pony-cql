use "crypto"
use "chrono"
use "net"
use "format"
use "ponytest"
use collection = "collections"
use cql = "../cql"

actor VisitorTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestVisitFrame)
        test(_TestVisitStartupRequest)
        test(_TestVisitAuthResponseRequest)
        test(_TestVisitOptionsRequest)
        test(_TestVisitQueryRequest)

        test(_TestVisitErrorResponse)        
        test(_TestVistReadyResponse)
        test(_TestVisitAuthenticateResponse)
        test(_TestVisitSupportedResponse)
        test(_TestVisitAuthSuccessResponse)

        test(_TestVisitQueryParameter)

        test(_TestVisitConsistency)
        test(_TestVisitNone)
        test(_TestVisitInt)
        test(_TestVisitShort)
        test(_TestVisitBytes)
        test(_TestVisitString)
        test(_TestVisitStringList)
        test(_TestVisitStringMap)

class iso _TestVisitFrame is UnitTest
    fun name(): String => "Visitor.visitFrame"

    fun tag apply(h: TestHelper) =>
        var request: Request val = recover StartupRequest("3.0.0") end
        var frame: Frame val = recover Frame(4, 0, 0, request) end
        var result: Array[U8 val] val = recover Visitor.visitFrame(frame) end
        
        h.assert_eq[String val](
            "0400000001000000160001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(result)
        )

        request = recover AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end) end
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

        request = recover AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end) end
        result = recover Visitor.visitAuthResponseRequest(request) end
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitOptionsRequest is UnitTest
    fun name(): String => "Visitor.visitOptionsRequest"

    fun tag apply(h: TestHelper) =>
        let request: OptionsRequest val = OptionsRequest()
        let result: Array[U8 val] val = recover Visitor.visitOptionsRequest(request) end
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(result)
        )


class iso _TestVisitQueryRequest is UnitTest
    
    fun name(): String val =>
        "Visitor.visitQueryRequest"
    
    fun tag apply(h: TestHelper) ? =>
       var request: QueryRequest val = QueryRequest("SELECT * FROM example", None)
        var result: Array[U8 val] val = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000001553454C454354202A2046524F4D206578616D706C65000400",
            Bytes.to_hex_string(result)
        )


        var binding: Array[QueryParameter val] val =  recover [ as QueryParameter val: None ] end
        request = QueryRequest("SELECT * FROM example WHERE id = ?", binding)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010001FFFFFFFF",
            Bytes.to_hex_string(result)
        )

        binding = recover [as QueryParameter val: "address@example.com"] end
        request = QueryRequest("SELECT * FROM example WHERE email = ?", binding)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000002553454C454354202A2046524F4D206578616D706C6520574845524520656D61696C203D203F00040100010000001361646472657373406578616D706C652E636F6D",
            Bytes.to_hex_string(result)
        )


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

        binding = recover [as QueryParameter val: none; ascii; i64; blob; bool; date; f64; f32; net_address; i32; list; map; set; i16; time; i8] end
        request = QueryRequest("SELECT * FROM example WHERE id = ?", binding)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010010FFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB00000004000000200000006D0000000DFFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB000000040000002000000002001000000008000028259C3ACC000000000108000000CC0000000C000000036931360000000200100000000369333200000004000000200000000366363400000008405028F5C28F5C29000000056173636969000000064153434949210000000474696D6500000008000028259C3ACC00000000026938000000010800000004626C6F62000000030102030000000B6E65745F6164647265737300000004C00002EB000000046E756C6CFFFFFFFF000000046461746500000004800000000000000366333200000004420147AE00000006626967696E740000000800000000000000010000000D000000010000000576616C756500000002001000000008000028259C3ACC000000000108",
            Bytes.to_hex_string(result)
        )

        let consistencies = [as Consistency: AnyConsistency; One; Two; Three; Quorum; All; LocalQuorum; EachQuorum; Serial; LocalSerial; LocalOne]
        for consistency in consistencies.values() do
            request = QueryRequest("SELECT * FROM example;", None, consistency)
            result = recover Visitor.visitQueryRequest(request) end
            h.assert_eq[String val](
                "0000001653454C454354202A2046524F4D206578616D706C653B" + Bytes.to_hex_string(Bytes.ofU16(consistency.value())) + "00",
                Bytes.to_hex_string(result)
            )
        end

        request = QueryRequest("SELECT * FROM example;", None, Quorum, false)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B000402",
            Bytes.to_hex_string(result)
        )

        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, 1)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B00040400000001",
            Bytes.to_hex_string(result)
        )
        
        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, None, recover [as U8: 1; 2; 3; 4] end)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B0004080000000401020304",
            Bytes.to_hex_string(result)
        )
        
        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, None, None, LocalSerial)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B0004100009",
            Bytes.to_hex_string(result)
        )

        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, None, None, None, 9999999999)
        result = recover Visitor.visitQueryRequest(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B00042000000002540BE3FF",
            Bytes.to_hex_string(result)
        )


class iso _TestVisitErrorResponse is UnitTest
    fun name(): String => "Visitor.visitErrorResponse"

    fun tag apply(h: TestHelper) =>
        let request: ErrorResponse val = ErrorResponse(0x0000, "Server error")
        let result: Array[U8 val] val = recover Visitor.visitErrorResponse(request) end
        h.assert_eq[String val](
            "00000000000C536572766572206572726F72",
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
        let response: AuthenticateResponse val = recover AuthenticateResponse("org.apache.cassandra.auth.PasswordAuthenticator") end
        let result: Array[U8 val] val = recover Visitor.visitAuthenticateResponse(response) end
        h.assert_eq[String val](
            "002F6F72672E6170616368652E63617373616E6472612E617574682E50617373776F726441757468656E74696361746F72",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitSupportedResponse is UnitTest
    fun name(): String => "Visitor.visitSupportedResponse"

    fun tag apply(h: TestHelper) =>
        let response = SupportedResponse(recover ["3.0.0"] end, recover ["snappy"; "lzo"] end)
        let result: Array[U8 val] val = recover Visitor.visitSupportedResponse(response) end
        h.assert_eq[String val](
            "0002000B434F4D5052455353494F4E00020006736E6170707900036C7A6F000B43514C5F56455253494F4E00010005332E302E30",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitAuthSuccessResponse is UnitTest
    fun name(): String => "Visitor.visitAuthSuccessResponse"

    fun tag apply(h: TestHelper) =>
        var response: AuthSuccessResponse val = recover AuthSuccessResponse() end
        var result: Array[U8 val] val = recover Visitor.visitAuthSuccessResponse(response) end
        h.assert_eq[String val](
            "FFFFFFFF",
            Bytes.to_hex_string(result)
        )

        response = recover AuthSuccessResponse(recover [as U8: 0xAB; 0xCD] end) end
        result = recover Visitor.visitAuthSuccessResponse(response) end
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(result)
        )

class iso _TestVisitQueryParameter is UnitTest

    fun name(): String =>
        "Visitor.visitQueryParameter"
    
    fun tag apply(h: TestHelper) ? =>
        var result: Array[U8 val] val = recover Visitor.visitQueryParameter("test") end
        h.assert_eq[String val]("0000000474657374", Bytes.to_hex_string(result))

        let bigint: I64 = 64
        result = recover Visitor.visitQueryParameter(bigint) end
        h.assert_eq[String val]("000000080000000000000040", Bytes.to_hex_string(result))

        let blob: Array[U8 val] val = recover [as U8: 0; 1; 2; 3; 4; 5; 0xFF] end
        result = recover Visitor.visitQueryParameter(blob) end
        h.assert_eq[String val]("00000007000102030405FF", Bytes.to_hex_string(result))

        let bool: Bool = true
        result = recover Visitor.visitQueryParameter(blob) end
        h.assert_eq[String val]("00000007000102030405FF", Bytes.to_hex_string(result))

        // var date: Date val = recover Date(-2147483648) end
        var date: Date val = recover Date.civil(-5877641, 6, 23) end//-2147483647) end  
        result = recover Visitor.visitQueryParameter(date) end
        h.assert_eq[String val]("0000000400000000", Bytes.to_hex_string(result))
        
        date = recover Date.civil(1970, 1, 1) end
        result = recover Visitor.visitQueryParameter(date) end
        h.assert_eq[String val]("0000000480000000", Bytes.to_hex_string(result))

        date = recover Date.civil(5881580, July, 11) end
        result = recover Visitor.visitQueryParameter(date) end
        h.assert_eq[String val]("00000004FFFFFFFF", Bytes.to_hex_string(result))

        let double: F64 = 3.141592653589
        result = recover Visitor.visitQueryParameter(double) end
        h.assert_eq[String val]("00000008400921FB5444261E", Bytes.to_hex_string(result))

        let float: F32 = F32.max_value()
        result = recover Visitor.visitQueryParameter(float) end
        h.assert_eq[String val]("000000047F7FFFFF", Bytes.to_hex_string(result))
        
        var net_address = DNS((h.env.root as AmbientAuth), "192.0.2.235", "80")(0)
        result = recover Visitor.visitQueryParameter(net_address) end
        h.assert_eq[String val]("00000004C00002EB", Bytes.to_hex_string(result))

        net_address = DNS((h.env.root as AmbientAuth), "2001:0db8:85a3:0000:0000:8a2e:0370:7334", "80")(0)
        result = recover Visitor.visitQueryParameter(net_address) end
        h.assert_eq[String val]("00000010B80D01200000A3852E8A000034737003", Bytes.to_hex_string(result))

        let int: I32 val = 32
        result = recover Visitor.visitQueryParameter(int) end
        h.assert_eq[String val]("0000000400000020", Bytes.to_hex_string(result))

        var time: Time val = recover Time.create(0) end
        result = recover Visitor.visitQueryParameter(time) end
        h.assert_eq[String val]("000000080000000000000000", Bytes.to_hex_string(result))

        time = recover Time.create(86399999999999) end
        result = recover Visitor.visitQueryParameter(time) end
        h.assert_eq[String val]("0000000800004E94914EFFFF", Bytes.to_hex_string(result))

        // let timestamp: 

        let tinyint: I16 val = 16
        result = recover Visitor.visitQueryParameter(tinyint) end
        h.assert_eq[String val]("000000020010", Bytes.to_hex_string(result))

class iso _TestVisitConsistency is UnitTest

    fun name(): String =>
        "Visitor.visitConsistency"
    
    fun tag apply(h: TestHelper) =>
        h.assert_eq[String val]("0000", Bytes.to_hex_string(Visitor.visitConsistency(AnyConsistency)))
        h.assert_eq[String val]("0001", Bytes.to_hex_string(Visitor.visitConsistency(One)))
        h.assert_eq[String val]("0002", Bytes.to_hex_string(Visitor.visitConsistency(Two)))
        h.assert_eq[String val]("0003", Bytes.to_hex_string(Visitor.visitConsistency(Three)))
        h.assert_eq[String val]("0004", Bytes.to_hex_string(Visitor.visitConsistency(Quorum)))
        h.assert_eq[String val]("0005", Bytes.to_hex_string(Visitor.visitConsistency(All)))
        h.assert_eq[String val]("0006", Bytes.to_hex_string(Visitor.visitConsistency(LocalQuorum)))
        h.assert_eq[String val]("0007", Bytes.to_hex_string(Visitor.visitConsistency(EachQuorum)))
        h.assert_eq[String val]("0008", Bytes.to_hex_string(Visitor.visitConsistency(Serial)))
        h.assert_eq[String val]("0009", Bytes.to_hex_string(Visitor.visitConsistency(LocalSerial)))
        h.assert_eq[String val]("000A", Bytes.to_hex_string(Visitor.visitConsistency(LocalOne)))
        

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
        Visitor.visitBytes(recover [as U8: 0xAB; 0xCD] end, collector)
        h.assert_eq[U8](0x00, collector(0))
        h.assert_eq[U8](0x00, collector(1))
        h.assert_eq[U8](0x00, collector(2))
        h.assert_eq[U8](0x02, collector(3))
        h.assert_eq[U8](0xAB, collector(4))
        h.assert_eq[U8](0xCD, collector(5))

        collector = Array[U8 val]()
        Visitor.visitBytes(None, collector)
        h.assert_eq[U8](0xFF, collector(0))
        h.assert_eq[U8](0xFF, collector(1))
        h.assert_eq[U8](0xFF, collector(2))
        h.assert_eq[U8](0xFF, collector(3))

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

class iso _TestVisitStringList is UnitTest
    fun name(): String => "Visitor.visitStringList"

    fun tag apply(h: TestHelper) ? =>
        var collector = Array[U8 val]()
        var data: Array[String val] val = recover ["1"; "2"] end
        Visitor.visitStringList(data, collector)
        h.assert_eq[U8](0x00, collector(0))
        h.assert_eq[U8](0x02, collector(1))
        h.assert_eq[U8](0x00, collector(2))
        h.assert_eq[U8](0x01, collector(3))
        h.assert_eq[U8](49, collector(4))
        h.assert_eq[U8](0x00, collector(5))
        h.assert_eq[U8](0x01, collector(6))
        h.assert_eq[U8](50, collector(7))
        
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
