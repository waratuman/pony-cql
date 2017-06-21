use "ponytest"
use "itertools"
use "../cql"

actor ParserStackTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(ParserStackTestApply)
        test(ParserStackTestShift)
        test(ParserStackTestShiftN)
        test(ParserStackTestUint)
        test(ParserStackTestInt)
        test(ParserStackTestLong)
        test(ParserStackTestByte)
        test(ParserStackTestShort)
        test(ParserStackTestString)
        test(ParserStackTestLongString)
        test(ParserStackTestUuid)
        test(ParserStackTestStringList)
        test(ParserStackTestBytes)
        test(ParserStackTestValue)
        test(ParserStackTestShortBytes)
        test(ParserStackTestOption)
        test(ParserStackTestOptionList)
        test(ParserStackTestInet)
        test(ParserStackTestInetaddr)
        test(ParserStackTestConsistency)
        test(ParserStackTestStringMap)
        test(ParserStackTestStringMultimap)
        test(ParserStackTestBytesMap)

class iso ParserStackTestApply is UnitTest

    fun name(): String =>
        "ParserStack.apply"
    
    fun tag apply(h: TestHelper) =>
        let stack = ParserStack(recover [as U8: 1] end)
        h.complete(true)


class iso ParserStackTestShift is UnitTest

    fun name(): String =>
        "ParserStack.shift"
    
    fun tag apply(h: TestHelper) ? =>
        let stack = ParserStack(recover [as U8: 1] end)
        h.assert_eq[U8 val](1, stack.shift())
        h.assert_eq[USize val](0, stack.size())
        

class iso ParserStackTestShiftN is UnitTest

    fun name(): String =>
        "ParserStack.shiftN"

    fun tag apply(h: TestHelper) ? =>
        let stack = ParserStack(recover [as U8: 1; 2; 3] end)
        for (a, b) in Zip2[U8 val, U8 val]([as U8: 1; 2].values(), stack.shiftN(2).values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](1, stack.size())


class iso ParserStackTestUint is UnitTest

    fun name(): String =>
        "ParserStack.uint"

    fun tag apply(h: TestHelper) ? =>
        let stack = ParserStack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        h.assert_eq[U32 val](U32.max_value(), stack.uint())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestInt is UnitTest

    fun name(): String =>
        "ParserStack.int"

    fun tag apply(h: TestHelper) ? =>
        let stack = ParserStack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        h.assert_eq[I32 val](-1, stack.int())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestLong is UnitTest

    fun name(): String =>
        "ParserStack.long"

    fun tag apply(h: TestHelper) ? =>
        let stack = ParserStack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF] end)
        h.assert_eq[I64 val](-1, stack.long())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestByte is UnitTest

    fun name(): String =>
        "ParserStack.byte"

    fun tag apply(h: TestHelper) ? =>
        let stack = ParserStack(recover [as U8: 0x08] end)
        h.assert_eq[U8 val](0x08, stack.byte())
        h.assert_eq[USize val](0, stack.size())
    

class iso ParserStackTestShort is UnitTest

    fun name(): String =>
        "ParserStack.short"

    fun tag apply(h: TestHelper) ? =>
        let stack = ParserStack(recover [as U8: 0xFF; 0xFF] end)
        h.assert_eq[U16 val](U16.max_value(), stack.short())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestString is UnitTest

    fun name(): String =>
        "ParserStack.string"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8: 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61]
        end
        let stack = ParserStack(data)
        h.assert_eq[String val]("cassandra", stack.string())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestLongString is UnitTest

    fun name(): String =>
        "ParserStack.long_string"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8: 0x00; 0x00; 0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61]
        end
        let stack = ParserStack(data)
        h.assert_eq[String val]("cassandra", stack.long_string())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestUuid is UnitTest

    fun name(): String =>
        "ParserStack.uuid"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8:
                0x00; 0x01; 0x02; 0x03; 0x04; 0x05; 0x06; 0x07
                0x08; 0x09; 0x0A; 0x0B; 0x0C; 0x0D; 0x0E; 0x0F
            ]
        end
        let stack = ParserStack(data)
        for (a, b) in Zip2[U8 val, U8 val](data.values(), stack.uuid().values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestStringList is UnitTest

    fun name(): String =>
        "ParserStack.string_list"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [as U8:
                0x00; 0x02
                0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
                0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
            ]
        end
        let stack = ParserStack(data)
        let expected: Array[String val] val = recover ["cassandra"; "cassandra"] end
        for (a, b) in Zip2[String val, String val](expected.values(), stack.string_list().values()) do
            h.assert_eq[String val](a, b)
        end
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestBytes is UnitTest

    fun name(): String =>
        "ParserStack.bytes"

    fun tag apply(h: TestHelper) ? =>
        var stack = ParserStack(recover [as U8: 0x00; 0x00; 0x00; 0x01; 0x02; 0x03] end)
        match stack.bytes()
        | let v: Array[U8 val] val =>
            for (a, b) in Zip2[U8 val, U8 val]([as U8: 2; 3].values(), v.values()) do
                h.assert_eq[U8 val](a, b)
            end
        else
            h.fail()
        end
        
        h.assert_eq[USize val](1, stack.size())

        stack = ParserStack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        match stack.bytes()
        | None => None
        else h.fail()
        end
        
        h.assert_eq[USize val](0, stack.size())



class iso ParserStackTestValue is UnitTest

    fun name(): String =>
        "ParserStack.value"

    fun tag apply(h: TestHelper) ? =>
        var stack = ParserStack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end)
        match stack.value()
        | None => None
        else h.fail()
        end

        stack = ParserStack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFE] end)
        match stack.value()
        | None => None
        else h.fail()
        end

        stack = ParserStack(recover [as U8: 0xFF; 0xFF; 0xFF; 0xFD] end)
        try
            stack.value()
            h.fail()
        else
            h.complete(true)
        end

class iso ParserStackTestShortBytes is UnitTest

    fun name(): String =>
        "ParserStack.short_bytes"

    fun tag apply(h: TestHelper) ? =>
        var stack = ParserStack(recover [as U8: 0x00; 0x01; 0x02; 0x03] end)
        for (a, b) in Zip2[U8 val, U8 val]([as U8: 2; 3].values(), stack.short_bytes().values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](1, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x00] end)
        h.assert_eq[USize val](0, stack.short_bytes().size())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestOption is UnitTest

    fun name(): String =>
        "ParserStack.option"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso ParserStackTestOptionList is UnitTest

    fun name(): String =>
        "ParserStack.option_list"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso ParserStackTestInet is UnitTest

    fun name(): String =>
        "ParserStack.inet"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover
            [as U8:
                0x04
                0xC0; 0xA8; 0x00; 0x01
                0x00; 0x00; 0x15; 0x38
            ]
        end
        var stack = ParserStack(data)
        var ipv4: U32 = 3232235521
        h.assert_eq[Inet val](recover Inet.create(ipv4, 5432) end, stack.inet())

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
        stack = ParserStack(data)
        let ipv6: U128 = 1
        h.assert_eq[Inet val](recover Inet.create(ipv6 , 5432) end, stack.inet())


class iso ParserStackTestInetaddr is UnitTest

    fun name(): String =>
        "ParserStack.inet_addr"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover
            [as U8:
                0x04
                0xC0; 0xA8; 0x00; 0x01
            ]
        end
        var stack = ParserStack(data)
        var ipv4: U32 = 3232235521
        h.assert_eq[U32 val](ipv4, stack.inetaddr() as U32)

        data = recover
            [as U8:
                0x10 
                0x00; 0x00; 0x00; 0x00
                0x00; 0x00; 0x00; 0x00 
                0x00; 0x00; 0x00; 0x00
                0x00; 0x00; 0x00; 0x01
            ]
        end
        stack = ParserStack(data)
        let ipv6: U128 = 1
        h.assert_eq[U128 val](ipv6, stack.inetaddr() as U128)


class iso ParserStackTestConsistency is UnitTest

    fun name(): String =>
        "ParserStack.consistency"
    
    fun tag apply(h: TestHelper) ? =>
        var stack = ParserStack(recover [as U8: 0x00; 0x00] end)
        h.assert_eq[Consistency val](AnyConsistency, stack.consistency())
        h.assert_eq[USize val](0, stack.size())
        
        stack = ParserStack(recover [as U8: 0x00; 0x01] end)
        h.assert_eq[Consistency val](One, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x02] end)
        h.assert_eq[Consistency val](Two, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x03] end)
        h.assert_eq[Consistency val](Three, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x04] end)
        h.assert_eq[Consistency val](Quorum, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x05] end)
        h.assert_eq[Consistency val](All, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x06] end)
        h.assert_eq[Consistency val](LocalQuorum, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x07] end)
        h.assert_eq[Consistency val](EachQuorum, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x08] end)
        h.assert_eq[Consistency val](Serial, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x09] end)
        h.assert_eq[Consistency val](LocalSerial, stack.consistency())
        h.assert_eq[USize val](0, stack.size())

        stack = ParserStack(recover [as U8: 0x00; 0x0A] end)
        h.assert_eq[Consistency val](LocalOne, stack.consistency())
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestStringMap is UnitTest

    fun name(): String =>
        "ParserStack.string_map"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [ 0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
              0x53; 0x49; 0x4F; 0x4E; 0x00; 0x06; 0x73; 0x6E; 0x61; 0x70; 0x70
              0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53
              0x49; 0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
            ]
        end

        let stack = ParserStack(data)
        let map = stack.string_map()
        h.assert_eq[String val]("snappy", map("COMPRESSION"))
        h.assert_eq[String val]("3.0.0", map("CQL_VERSION"))
        h.assert_eq[USize val](0, stack.size())


class iso ParserStackTestStringMultimap is UnitTest

    fun name(): String =>
        "ParserStack.string_multimap"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [ 0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
              0x53; 0x49; 0x4F; 0x4E; 0x00; 0x02; 0x00; 0x06; 0x73; 0x6E; 0x61
              0x70; 0x70; 0x79; 0x00; 0x03; 0x6C; 0x7A; 0x6F; 0x00; 0x0B; 0x43
              0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00
              0x01; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
            ]
        end
        let stack = ParserStack(data)
        let map = stack.string_multimap()
        h.assert_eq[String val]("snappy", map("COMPRESSION")(0))
        h.assert_eq[String val]("lzo", map("COMPRESSION")(1))
        h.assert_eq[String val]("3.0.0", map("CQL_VERSION")(0))


class iso ParserStackTestBytesMap is UnitTest

    fun name(): String =>
        "ParserStack.bytes_map"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] val = recover
            [ 0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
              0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x06; 0x73; 0x6E; 0x61
              0x70; 0x70; 0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45
              0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x05; 0x33; 0x2E
              0x30; 0x2E; 0x30
            ]
        end
        let stack = ParserStack(data)
        let map = stack.bytes_map()
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
