use "net"
use "ponytest"
use "chrono"
use "itertools"

use cql = "../cql"
use collections = "collections"

actor QueryRequestParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(QueryRequestParserTest)


class iso QueryRequestParserTest is UnitTest

    fun name(): String =>
        "QueryRequestParser.apply"
    
    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] ref = Bytes.from_hex_string("0000001553454C454354202A2046524F4D206578616D706C65000400")?
        var request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example", request.query)
        h.assert_eq[Bool val](true, request.binding is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010001FFFFFFFF")?
        request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example WHERE id = ?", request.query)
        h.assert_eq[USize val](1, (request.binding as Array[QueryParameter val] val).size())
        h.assert_eq[Bool val](true, (request.binding as Array[QueryParameter val] val)(0)? is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000002553454C454354202A2046524F4D206578616D706C6520574845524520656D61696C203D203F00040100010000001361646472657373406578616D706C652E636F6D")?
        request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example WHERE email = ?", request.query)
        h.assert_eq[String val](
            "address@example.com",
            String.from_array((request.binding as Array[QueryParameter val] val)(0)? as Array[U8 val] val)
        )
        h.assert_eq[USize val](1, (request.binding as Array[QueryParameter val] val).size())
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000002253454C454354202A2046524F4D206578616D706C65205748455245206964203D203F0004010010FFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB00000004000000200000006D0000000DFFFFFFFF00000006415343494921000000080000000000000001000000030102030000000101000000048000000000000008405028F5C28F5C2900000004420147AE00000004C00002EB000000040000002000000002001000000008000028259C3ACC000000000108000000CC0000000C000000036931360000000200100000000369333200000004000000200000000366363400000008405028F5C28F5C29000000056173636969000000064153434949210000000474696D6500000008000028259C3ACC00000000026938000000010800000004626C6F62000000030102030000000B6E65745F6164647265737300000004C00002EB000000046E756C6CFFFFFFFF000000046461746500000004800000000000000366333200000004420147AE00000006626967696E740000000800000000000000010000000D000000010000000576616C756500000002001000000008000028259C3ACC000000000108")?
        let none: None val = None
        let ascii: String val = "ASCII!"
        let i64: I64 val = 1
        let blob: Array[U8 val] val = recover [1; 2; 3] end
        let bool: Bool val = true
        let date: Date val = recover Date(0) end
        let f64: F64 val = 64.64
        let f32: F32 val = 32.32
        let net_address = DNS((h.env.root as AmbientAuth), "192.0.2.235", "80")(0)?
        let i32: I32 val = 32
        let i16: I16 val = 16
        let time: Time val = recover Time.civil(12, 15, 42) end
        let i8: I8 val = 8
        let list: Seq[cql.NativeType val] val = recover [as cql.NativeType: none; ascii; i64; blob; bool; date; f64; f32; net_address; i32; i16; time; i8] end
        let map: cql.MapType val = recover
            let map = collections.Map[String val, cql.NativeType val]()
            map.insert("null", none)?
            map.insert("ascii", ascii)?
            map.insert("bigint", i64)?
            map.insert("blob", blob)?
            map.insert("date", date)?
            map.insert("f64", f64)?
            map.insert("f32", f32)?
            map.insert("net_address", net_address)?
            map.insert("i32", i32)?
            map.insert("i16", i16)?
            map.insert("time", time)?
            map.insert("i8", i8)?
            map
        end
        let set: cql.SetType val = recover
            let set = collections.Set[String val]
            set.set("value")
            set
        end
        request = QueryRequestParser(data)?
        let params = request.binding as Array[QueryParameter val] val
        h.assert_eq[String val]("SELECT * FROM example WHERE id = ?", request.query)
        h.assert_eq[USize val](16, params.size())
        h.assert_eq[None val](none, params(0)? as None val)
        h.assert_eq[String val](String.from_array(params(1)? as Array[U8 val] val), ascii)
        for (a, b) in Iter[U8 val]((params(15)? as Array[U8 val] val).values()).zip[U8 val]((recover [i8.u8()] end).values()) do
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
            data = Bytes.from_hex_string("0000001553454C454354202A2046524F4D206578616D706C65" + Bytes.to_hex_string(Bytes.ofU16(consistency.value())) + "00")?
            request = QueryRequestParser(data)?
            h.assert_eq[Consistency val](request.consistency, consistency)
        end

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B000402")?
        request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.binding is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](false, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)
        
        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B00040400000001")?
        request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.binding is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[I32 val](1, request.page_size as I32 val)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B0004080000000401020304")?
        request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.binding is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        for (c, d) in Iter[U8 val]((request.paging_state as Array[U8 val] val).values()).zip[U8 val]((recover [as U8: 1; 2; 3; 4] end).values()) do
            h.assert_eq[U8 val](c, d)
        end
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B0004100009")?
        request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.binding is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is LocalSerial)
        h.assert_eq[Bool val](true, request.timestamp is None)

        data = Bytes.from_hex_string("0000001653454C454354202A2046524F4D206578616D706C653B00042000000002540BE3FF")?
        request = QueryRequestParser(data)?
        h.assert_eq[String val]("SELECT * FROM example;", request.query)
        h.assert_eq[Bool val](true, request.binding is None)
        h.assert_eq[Consistency val](request.consistency, Quorum)
        h.assert_eq[Bool val](true, request.metadata)
        h.assert_eq[Bool val](true, request.page_size is None)
        h.assert_eq[Bool val](true, request.paging_state is None)
        h.assert_eq[Bool val](true, request.serial_consistency is None)
        h.assert_eq[I64 val](9999999999, request.timestamp as I64)
