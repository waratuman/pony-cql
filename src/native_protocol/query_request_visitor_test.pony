use "net"
use "chrono"
use "ponytest"
use cql = "../cql"
use collections = "collections"


actor QueryRequestVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(QueryRequestVisitorTest)
        test(QueryRequestParameterVisitorTest)


class iso QueryRequestVisitorTest is UnitTest
    
    fun name(): String val =>
        "QueryRequestVisitorTest.apply"
    
    fun tag apply(h: TestHelper) ? =>
       var request: QueryRequest val = QueryRequest("SELECT * FROM example", None)
        var result: Array[U8 val] val = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000001553454C454354202A2046524F4D206578616D706C65000400",
            Bytes.to_hex_string(result)
        )


        var binding: Array[QueryParameter val] val =  recover [ as QueryParameter val: None ] end
        request = QueryRequest("SELECT * FROM example WHERE id = ?", binding)
        result = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010001FFFFFFFF",
            Bytes.to_hex_string(result)
        )

        binding = recover [as QueryParameter val: "address@example.com"] end
        request = QueryRequest("SELECT * FROM example WHERE email = ?", binding)
        result = recover QueryRequestVisitor(request) end
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
            let map = collections.Map[String val, cql.NativeType val]()
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
            let set = collections.Set[String val]
            set.set("value")
            set
        end

        binding = recover [as QueryParameter val: none; ascii; i64; blob; bool; date; f64; f32; net_address; i32; list; map; set; i16; time; i8] end
        request = QueryRequest("SELECT * FROM example WHERE id = ?", binding)
        result = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010010FFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB00000004000000200000006D0000000DFFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB000000040000002000000002001000000008000028259C3ACC000000000108000000CC0000000C000000036931360000000200100000000369333200000004000000200000000366363400000008405028F5C28F5C29000000056173636969000000064153434949210000000474696D6500000008000028259C3ACC00000000026938000000010800000004626C6F62000000030102030000000B6E65745F6164647265737300000004C00002EB000000046E756C6CFFFFFFFF000000046461746500000004800000000000000366333200000004420147AE00000006626967696E740000000800000000000000010000000D000000010000000576616C756500000002001000000008000028259C3ACC000000000108",
            Bytes.to_hex_string(result)
        )

        let consistencies = [as Consistency: AnyConsistency; One; Two; Three; Quorum; All; LocalQuorum; EachQuorum; Serial; LocalSerial; LocalOne]
        for consistency in consistencies.values() do
            request = QueryRequest("SELECT * FROM example;", None, consistency)
            result = recover QueryRequestVisitor(request) end
            h.assert_eq[String val](
                "0000001653454C454354202A2046524F4D206578616D706C653B" + Bytes.to_hex_string(Bytes.ofU16(consistency.value())) + "00",
                Bytes.to_hex_string(result)
            )
        end

        request = QueryRequest("SELECT * FROM example;", None, Quorum, false)
        result = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B000402",
            Bytes.to_hex_string(result)
        )

        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, 1)
        result = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B00040400000001",
            Bytes.to_hex_string(result)
        )
        
        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, None, recover [as U8: 1; 2; 3; 4] end)
        result = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B0004080000000401020304",
            Bytes.to_hex_string(result)
        )
        
        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, None, None, LocalSerial)
        result = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B0004100009",
            Bytes.to_hex_string(result)
        )

        request = QueryRequest("SELECT * FROM example;", None, Quorum, true, None, None, None, 9999999999)
        result = recover QueryRequestVisitor(request) end
        h.assert_eq[String val](
            "0000001653454C454354202A2046524F4D206578616D706C653B00042000000002540BE3FF",
            Bytes.to_hex_string(result)
        )


class iso QueryRequestParameterVisitorTest is UnitTest

    fun name(): String =>
        "QueryRequestParameterVisitorTest"
    
    fun tag apply(h: TestHelper) ? =>
        var result: Array[U8 val] val = recover QueryRequestParameterVisitor("test") end
        h.assert_eq[String val]("0000000474657374", Bytes.to_hex_string(result))

        let bigint: I64 = 64
        result = recover QueryRequestParameterVisitor(bigint) end
        h.assert_eq[String val]("000000080000000000000040", Bytes.to_hex_string(result))

        let blob: Array[U8 val] val = recover [as U8: 0; 1; 2; 3; 4; 5; 0xFF] end
        result = recover QueryRequestParameterVisitor(blob) end
        h.assert_eq[String val]("00000007000102030405FF", Bytes.to_hex_string(result))

        let bool: Bool = true
        result = recover QueryRequestParameterVisitor(blob) end
        h.assert_eq[String val]("00000007000102030405FF", Bytes.to_hex_string(result))

        // var date: Date val = recover Date(-2147483648) end
        var date: Date val = recover Date.civil(-5877641, 6, 23) end//-2147483647) end  
        result = recover QueryRequestParameterVisitor(date) end
        h.assert_eq[String val]("0000000400000000", Bytes.to_hex_string(result))
        
        date = recover Date.civil(1970, 1, 1) end
        result = recover QueryRequestParameterVisitor(date) end
        h.assert_eq[String val]("0000000480000000", Bytes.to_hex_string(result))

        date = recover Date.civil(5881580, July, 11) end
        result = recover QueryRequestParameterVisitor(date) end
        h.assert_eq[String val]("00000004FFFFFFFF", Bytes.to_hex_string(result))

        let double: F64 = 3.141592653589
        result = recover QueryRequestParameterVisitor(double) end
        h.assert_eq[String val]("00000008400921FB5444261E", Bytes.to_hex_string(result))

        let float: F32 = F32.max_value()
        result = recover QueryRequestParameterVisitor(float) end
        h.assert_eq[String val]("000000047F7FFFFF", Bytes.to_hex_string(result))
        
        var net_address = DNS((h.env.root as AmbientAuth), "192.0.2.235", "80")(0)
        result = recover QueryRequestParameterVisitor(net_address) end
        h.assert_eq[String val]("00000004C00002EB", Bytes.to_hex_string(result))

        net_address = DNS((h.env.root as AmbientAuth), "2001:0db8:85a3:0000:0000:8a2e:0370:7334", "80")(0)
        result = recover QueryRequestParameterVisitor(net_address) end
        h.assert_eq[String val]("00000010B80D01200000A3852E8A000034737003", Bytes.to_hex_string(result))

        let int: I32 val = 32
        result = recover QueryRequestParameterVisitor(int) end
        h.assert_eq[String val]("0000000400000020", Bytes.to_hex_string(result))

        var time: Time val = recover Time.create(0) end
        result = recover QueryRequestParameterVisitor(time) end
        h.assert_eq[String val]("000000080000000000000000", Bytes.to_hex_string(result))

        time = recover Time.create(86399999999999) end
        result = recover QueryRequestParameterVisitor(time) end
        h.assert_eq[String val]("0000000800004E94914EFFFF", Bytes.to_hex_string(result))

        // let timestamp: 

        let tinyint: I16 val = 16
        result = recover QueryRequestParameterVisitor(tinyint) end
        h.assert_eq[String val]("000000020010", Bytes.to_hex_string(result))

