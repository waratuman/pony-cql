use "ponytest"
use "itertools"
use "../cql"

actor StackTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(StackTestApply)
        test(StackTestTake)
        test(StackTestTakeN)
        test(StackTestTakeUint)
        test(StackTestTakeInt)
        test(StackTestTakeLong)
        test(StackTestTakeByte)
        test(StackTestTakeShort)
        test(StackTestTakeString)
        test(StackTestTakeLongString)
        test(StackTestTakeUuid)
        test(StackTestTakeStringList)
        test(StackTestTakeBytes)
        test(StackTestTakeValue)
        test(StackTestTakeShortBytes)
        test(StackTestTakeOption)
        test(StackTestTakeOptionList)
        test(StackTestTakeInet)
        test(StackTestTakeInetaddr)
        test(StackTestTakeConsistency)
        test(StackTestTakeStringMap)
        test(StackTestTakeStringMultimap)
        test(StackTestTakeBytesMap)

class iso StackTestApply is UnitTest

    fun name(): String =>
        "Stack.take_apply"
    
    fun tag apply(h: TestHelper) =>
        let stack = Stack(recover [as U8: 1] end)
        h.complete(true)


class iso StackTestTake is UnitTest

    fun name(): String =>
        "Stack.take"
    
    fun tag apply(h: TestHelper) ? =>
        let stack = Stack(recover [as U8: 1] end)
        h.assert_eq[U8 val](1, stack.take())
        h.assert_eq[USize val](0, stack.size())
        

class iso StackTestTakeN is UnitTest

    fun name(): String =>
        "Stack.take_n"

    fun tag apply(h: TestHelper) ? =>
        let stack = Stack(recover [as U8: 1; 2; 3] end)
        for (a, b) in Zip2[U8 val, U8 val]([as U8: 1; 2].values(), stack.take_n(2).values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](1, stack.size())


class iso StackTestTakeUint is UnitTest

    fun name(): String =>
        "Stack.take_uint"

    fun tag apply(h: TestHelper) ? =>
        let stack = Stack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        h.assert_eq[U32 val](U32.max_value(), stack.take_uint())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeInt is UnitTest

    fun name(): String =>
        "Stack.take_int"

    fun tag apply(h: TestHelper) ? =>
        let stack = Stack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        h.assert_eq[I32 val](-1, stack.take_int())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeLong is UnitTest

    fun name(): String =>
        "Stack.take_long"

    fun tag apply(h: TestHelper) ? =>
        let stack = Stack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF] end)
        h.assert_eq[I64 val](-1, stack.take_long())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeByte is UnitTest

    fun name(): String =>
        "Stack.take_byte"

    fun tag apply(h: TestHelper) ? =>
        let stack = Stack(recover [as U8: 0x08] end)
        h.assert_eq[U8 val](0x08, stack.byte())
        h.assert_eq[USize val](0, stack.size())
    

class iso StackTestTakeShort is UnitTest

    fun name(): String =>
        "Stack.take_short"

    fun tag apply(h: TestHelper) ? =>
        let stack = Stack(recover [as U8: 0xFF; 0xFF] end)
        h.assert_eq[U16 val](U16.max_value(), stack.take_short())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeString is UnitTest

    fun name(): String =>
        "Stack.take_string"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8: 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61]
        end
        let stack = Stack(data)
        h.assert_eq[String val]("cassandra", stack.take_string())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeLongString is UnitTest

    fun name(): String =>
        "Stack.take_long_string"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8: 0x00; 0x00; 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61]
        end
        let stack = Stack(data)
        h.assert_eq[String val]("cassandra", stack.take_long_string())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeUuid is UnitTest

    fun name(): String =>
        "Stack.take_uuid"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8:
                0x00; 0x01; 0x02; 0x03; 0x04; 0x05; 0x06; 0x07
                0x08; 0x09; 0x0A; 0x0B; 0x0C; 0x0D; 0x0E; 0x0F
            ]
        end
        let stack = Stack(data)
        for (a, b) in Zip2[U8 val, U8 val](data.values(), stack.take_uuid().values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeStringList is UnitTest

    fun name(): String =>
        "Stack.take_string_list"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8:
                0x00; 0x02
                0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
                0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
            ]
        end
        let stack = Stack(data)
        let expected: Array[String val] val = recover ["cassandra"; "cassandra"] end
        for (a, b) in Zip2[String val, String val](expected.values(), stack.take_string_list().values()) do
            h.assert_eq[String val](a, b)
        end
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeBytes is UnitTest

    fun name(): String =>
        "Stack.take_bytes"

    fun tag apply(h: TestHelper) ? =>
        var stack = Stack(recover [as U8: 0x00; 0x00; 0x00; 0x01; 0x02; 0x03] end)
        match stack.take_bytes()
        | let v: Array[U8 val] val =>
            for (a, b) in Zip2[U8 val, U8 val]([as U8: 2; 3].values(), v.values()) do
                h.assert_eq[U8 val](a, b)
            end
        else
            h.fail()
        end
        
        h.assert_eq[USize val](1, stack.size())

        stack = Stack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        match stack.take_bytes()
        | None => None
        else h.fail()
        end
        
        h.assert_eq[USize val](0, stack.size())



class iso StackTestTakeValue is UnitTest

    fun name(): String =>
        "Stack.take_value"

    fun tag apply(h: TestHelper) ? =>
        var stack = Stack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        match stack.take_value()
        | None => None
        else h.fail()
        end

        stack = Stack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFE] end)
        match stack.take_value()
        | None => None
        else h.fail()
        end

        stack = Stack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFD] end)
        try
            stack.take_value()
            h.fail()
        else
            h.complete(true)
        end

class iso StackTestTakeShortBytes is UnitTest

    fun name(): String =>
        "Stack.take_short_bytes"

    fun tag apply(h: TestHelper) ? =>
        var stack = Stack(recover [as U8: 0x00; 0x01; 0x02; 0x03] end)
        for (a, b) in Zip2[U8 val, U8 val]([as U8: 2; 3].values(), stack.take_short_bytes().values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](1, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x00] end)
        h.assert_eq[USize val](0, stack.take_short_bytes().size())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeOption is UnitTest

    fun name(): String =>
        "Stack.take_option"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso StackTestTakeOptionList is UnitTest

    fun name(): String =>
        "Stack.take_option_list"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso StackTestTakeInet is UnitTest

    fun name(): String =>
        "Stack.take_inet"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover
            [as U8:
                0x04
                0xC0; 0xA8; 0x00; 0x01
                0x00; 0x00; 0x15; 0x38
            ]
        end
        var stack = Stack(data)
        var ipv4: U32 = 3232235521
        h.assert_eq[Inet val](recover Inet.create(ipv4, 5432) end, stack.take_inet())

        data = recover
            [as U8:
                0x10 
                0x00; 0x00; 0x00; 0x00
                0x00; 0x00; 0x00; 0x00 
                0x00; 0x00; 0x00; 0x00
                0x00; 0x00; 0x00; 0x01
                0x00; 0x00; 0x15; 0x38
            ]
        end
        stack = Stack(data)
        let ipv6: U128 = 1
        h.assert_eq[Inet val](recover Inet.create(ipv6 , 5432) end, stack.take_inet())


class iso StackTestTakeInetaddr is UnitTest

    fun name(): String =>
        "Stack.take_inet_addr"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover
            [as U8:
                0x04
                0xC0; 0xA8; 0x00; 0x01
            ]
        end
        var stack = Stack(data)
        var ipv4: U32 = 3232235521
        h.assert_eq[U32 val](ipv4, stack.take_inetaddr() as U32)

        data = recover
            [as U8:
                0x10 
                0x00; 0x00; 0x00; 0x00
                0x00; 0x00; 0x00; 0x00 
                0x00; 0x00; 0x00; 0x00
                0x00; 0x00; 0x00; 0x01
            ]
        end
        stack = Stack(data)
        let ipv6: U128 = 1
        h.assert_eq[U128 val](ipv6, stack.take_inetaddr() as U128)


class iso StackTestTakeConsistency is UnitTest

    fun name(): String =>
        "Stack.take_consistency"
    
    fun tag apply(h: TestHelper) ? =>
        var stack = Stack(recover [as U8: 0x00; 0x00] end)
        h.assert_eq[Consistency val](AnyConsistency, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())
        
        stack = Stack(recover [as U8: 0x00; 0x01] end)
        h.assert_eq[Consistency val](One, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x02] end)
        h.assert_eq[Consistency val](Two, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x03] end)
        h.assert_eq[Consistency val](Three, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x04] end)
        h.assert_eq[Consistency val](Quorum, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x05] end)
        h.assert_eq[Consistency val](All, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x06] end)
        h.assert_eq[Consistency val](LocalQuorum, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x07] end)
        h.assert_eq[Consistency val](EachQuorum, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x08] end)
        h.assert_eq[Consistency val](Serial, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x09] end)
        h.assert_eq[Consistency val](LocalSerial, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = Stack(recover [as U8: 0x00; 0x0A] end)
        h.assert_eq[Consistency val](LocalOne, stack.take_consistency())
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeStringMap is UnitTest

    fun name(): String =>
        "Stack.take_string_map"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [ 0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
              0x53; 0x49; 0x4F; 0x4E; 0x00; 0x06; 0x73; 0x6E; 0x61; 0x70; 0x70
              0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53
              0x49; 0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
            ]
        end

        let stack = Stack(data)
        let map = stack.take_string_map()
        h.assert_eq[String val]("snappy", map("COMPRESSION"))
        h.assert_eq[String val]("3.0.0", map("CQL_VERSION"))
        h.assert_eq[USize val](0, stack.size())


class iso StackTestTakeStringMultimap is UnitTest

    fun name(): String =>
        "Stack.take_string_multimap"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [ 0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
              0x53; 0x49; 0x4F; 0x4E; 0x00; 0x02; 0x00; 0x06; 0x73; 0x6E; 0x61
              0x70; 0x70; 0x79; 0x00; 0x03; 0x6C; 0x7A; 0x6F; 0x00; 0x0B; 0x43
              0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00
              0x01; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
            ]
        end
        let stack = Stack(data)
        let map = stack.take_string_multimap()
        h.assert_eq[String val]("snappy", map("COMPRESSION")(0))
        h.assert_eq[String val]("lzo", map("COMPRESSION")(1))
        h.assert_eq[String val]("3.0.0", map("CQL_VERSION")(0))


class iso StackTestTakeBytesMap is UnitTest

    fun name(): String =>
        "Stack.take_bytes_map"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [ 0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
              0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x06; 0x73; 0x6E; 0x61
              0x70; 0x70; 0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45
              0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x05; 0x33; 0x2E
              0x30; 0x2E; 0x30
            ]
        end
        let stack = Stack(data)
        let map = stack.take_bytes_map()
        var x = [as U8: 0x73; 0x6E; 0x61; 0x70; 0x70; 0x79]
        var y = (map("COMPRESSION") as Array[U8 val] val)
        for (a, b) in Zip2[U8 val, U8 val](x.values(), y.values()) do
            h.assert_eq[U8 val](a, b)
        end
        
        x = [as U8: 0x33; 0x2E; 0x30; 0x2E; 0x30]
        y = (map("CQL_VERSION") as Array[U8 val] val)
        for (a, b) in Zip2[U8 val, U8 val](x.values(), y.values()) do
            h.assert_eq[U8 val](a, b)
        end
