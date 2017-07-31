use "ponytest"
use "itertools"
use collections = "collections"
use "../cql"

actor ParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        AuthResponseRequestParserTestList.make().tests(test)
        AuthenticateResponseParserTestList.make().tests(test)
        AuthSuccessResponseParserTestList.make().tests(test)
        ErrorResponseParserTestList.make().tests(test)
        FrameParserTestList.make().tests(test)
        FrameTestList.make().tests(test)
        OptionsRequestParserTestList.make().tests(test)
        QueryRequestParserTestList.make().tests(test)
        ReadyResponseParserTestList.make().tests(test)
        StartupRequestParserTestList.make().tests(test)
        SupportedResponseParserTestList.make().tests(test)

        test(ByteParserTest)
        test(UIntParserTest)
        test(IntParserTest)
        test(LongParserTest)
        test(ShortParserTest)
        test(StringParserTest)
        test(LongStringParserTest)
        test(UUIDParserTest)
        test(StringListParserTest)
        test(BytesParserTest)
        test(ValueParserTest)
        test(ShortBytesParserTest)
        test(OptionParser)
        test(OptionListParser)
        test(InetParserTest)
        test(InetAddrParserTest)
        test(ConsistencyParserTest)
        test(StringMapParserTest)
        test(StringMultiMapParserTest)
        test(BytesMapParserTest)



class iso ByteParserTest is UnitTest

    fun name(): String =>
        "ByteParser.apply"
    
    fun tag apply(h: TestHelper) ? =>
        let data = [as U8: 3]
        h.assert_eq[U8](3, ByteParser(data)?)


class iso UIntParserTest is UnitTest

    fun name(): String =>
        "UIntParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        h.assert_eq[U32 val](U32.max_value(), UIntParser(data)?)
        h.assert_eq[USize val](0, data.size())


class iso IntParserTest is UnitTest

    fun name(): String =>
        "IntParser.apply"
    
    fun tag apply(h: TestHelper) ? =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        h.assert_eq[I32 val](-1, IntParser(data)?)
        h.assert_eq[USize val](0, data.size())


class iso LongParserTest is UnitTest

    fun name(): String =>
        "LongParser.apply"
    
    fun tag apply(h: TestHelper) ? =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF]
        h.assert_eq[I64 val](-1, LongParser(data)?)
        h.assert_eq[USize val](0, data.size())


class iso ShortParserTest is UnitTest

    fun name(): String =>
        "ShortParser.apply"
    
    fun tag apply(h: TestHelper) ? =>
        let data = [as U8: 0xFF; 0xFF]
        h.assert_eq[U16 val](U16.max_value(), ShortParser(data)?)
        h.assert_eq[USize val](0, data.size())


class iso StringParserTest is UnitTest

    fun name(): String =>
        "StringParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
        ]
        h.assert_eq[String box]("cassandra", StringParser(data)?)
        h.assert_eq[USize val](0, data.size())


class iso LongStringParserTest is UnitTest

    fun name(): String =>
        "LongStringParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x00; 0x00; 0x09
            0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
        ]
        h.assert_eq[String box]("cassandra", LongStringParser(data)?)
        h.assert_eq[USize val](0, data.size())


class iso UUIDParserTest is UnitTest

    fun name(): String =>
        "UUIDParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x01; 0x02; 0x03; 0x04; 0x05; 0x06; 0x07
            0x08; 0x09; 0x0A; 0x0B; 0x0C; 0x0D; 0x0E; 0x0F
        ]
        for (a, b) in Zip2[U8 val, U8 val](data.values(), UUIDParser(data)?.values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](0, data.size())


class iso StringListParserTest is UnitTest

    fun name(): String =>
        "StringListParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data: Array[U8 val] ref = [as U8:
            0x00; 0x02
            0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
            0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
        ]

        let expected: Array[String val] val = recover ["cassandra"; "cassandra"] end
        let results: Array[String val] ref = StringListParser(data)?
        for (a, b) in Zip2[String box, String box](expected.values(), results.values()) do
            h.assert_eq[String box](a, b)
        end
        h.assert_eq[USize val](0, data.size())


class iso BytesParserTest is UnitTest

    fun name(): String =>
        "BytesParser.apply"

    fun tag apply(h: TestHelper) ? =>
        var data = [as U8: 0x00; 0x00; 0x00; 0x01; 0x02; 0x03]
        match BytesParser(data)?
        | let v: Array[U8 val] ref =>
            for (a, b) in Zip2[U8 val, U8 val]([as U8: 2; 3].values(), v.values()) do
                h.assert_eq[U8 val](a, b)
            end
        else
            h.fail()
        end
        
        h.assert_eq[USize val](1, data.size())

        data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        match BytesParser(data)?
        | None => None
        else h.fail()
        end
        
        h.assert_eq[USize val](0, data.size())


class iso ValueParserTest is UnitTest

    fun name(): String =>
        "ValueParser.apply"

    fun tag apply(h: TestHelper) ? =>
        var data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        match ValueParser(data)?
        | None => None
        else h.fail()
        end

        data = [as U8: 0xFF; 0xFF; 0xFF; 0xFE]
        match ValueParser(data)?
        | None => None
        else h.fail()
        end

        data = [as U8: 0xFF; 0xFF; 0xFF; 0xFD]
        try
            ValueParser(data)?
            h.fail()
        else
            h.complete(true)
        end


class iso ShortBytesParserTest is UnitTest

    fun name(): String =>
        "ShortBytesParser.apply"

    fun tag apply(h: TestHelper) ? =>
        var data = [as U8: 0x00; 0x01; 0x02; 0x03]
        for (a, b) in Zip2[U8 val, U8 val]([as U8: 2; 3].values(), ShortBytesParser(data)?.values()) do
            h.assert_eq[U8 val](a, b)
        end
        h.assert_eq[USize val](1, data.size())

        data = [as U8: 0x00; 0x00]
        h.assert_eq[USize val](0, ShortBytesParser(data)?.size())
        h.assert_eq[USize val](0, data.size())


class iso OptionParser is UnitTest

    fun name(): String =>
        "OptionParser.apply"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso OptionListParser is UnitTest

    fun name(): String =>
        "OptionListParser.apply"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso InetParserTest is UnitTest

    fun name(): String =>
        "InetParser.apply"

    fun tag apply(h: TestHelper) ? =>
        var data = [as U8: 0x04
            0xC0; 0xA8; 0x00; 0x01
            0x00; 0x00; 0x15; 0x38
        ]
        var ipv4: U32 = 3232235521
        h.assert_eq[Inet box](Inet.create(ipv4, 5432), InetParser(data)?)

        data = [as U8: 0x10 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x00 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x01
            0x00; 0x00; 0x15; 0x38
        ]
        let ipv6: U128 = 1
        h.assert_eq[Inet box](Inet.create(ipv6, 5432), InetParser(data)?)


class iso InetAddrParserTest is UnitTest

    fun name(): String =>
        "InetAddrParser.apply"

    fun tag apply(h: TestHelper) ? =>
        var data = [as U8: 0x04
            0xC0; 0xA8; 0x00; 0x01
        ]
        var ipv4: U32 = 3232235521
        h.assert_eq[U32 val](ipv4, InetAddrParser(data)? as U32)

        data = [as U8: 0x10 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x00 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x01
        ]
        let ipv6: U128 = 1
        h.assert_eq[U128 val](ipv6, InetAddrParser(data)? as U128)


class iso ConsistencyParserTest is UnitTest

    fun name(): String =>
        "ConsistencyParser.apply"
    
    fun tag apply(h: TestHelper) ? =>
        var data = [as U8: 0x00; 0x00]
        h.assert_eq[Consistency val](AnyConsistency, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())
        
        data = [as U8: 0x00; 0x01]
        h.assert_eq[Consistency val](One, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x02]
        h.assert_eq[Consistency val](Two, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x03]
        h.assert_eq[Consistency val](Three, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x04]
        h.assert_eq[Consistency val](Quorum, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x05]
        h.assert_eq[Consistency val](All, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x06]
        h.assert_eq[Consistency val](LocalQuorum, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x07]
        h.assert_eq[Consistency val](EachQuorum, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x08]
        h.assert_eq[Consistency val](Serial, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x09]
        h.assert_eq[Consistency val](LocalSerial, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())

        data = [as U8: 0x00; 0x0A]
        h.assert_eq[Consistency val](LocalOne, ConsistencyParser(data)?)
        h.assert_eq[USize val](0, data.size())


class iso StringMapParserTest is UnitTest

    fun name(): String =>
        "StringMapParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x06; 0x73; 0x6E; 0x61; 0x70; 0x70
            0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53
            0x49; 0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]

        let map = StringMapParser(data)?
        h.assert_eq[String box]("snappy", map("COMPRESSION")?)
        h.assert_eq[String box]("3.0.0", map("CQL_VERSION")?)
        h.assert_eq[USize val](0, data.size())


class iso StringMultiMapParserTest is UnitTest

    fun name(): String =>
        "StringMultiMapParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x02; 0x00; 0x06; 0x73; 0x6E; 0x61
            0x70; 0x70; 0x79; 0x00; 0x03; 0x6C; 0x7A; 0x6F; 0x00; 0x0B; 0x43
            0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00
            0x01; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        
        let map: collections.Map[String val, Array[String val] ref] ref = StringMultiMapParser(data)?
        h.assert_eq[String box]("snappy", map("COMPRESSION")?(0)?)
        h.assert_eq[String box]("lzo", map("COMPRESSION")?(1)?)
        h.assert_eq[String box]("3.0.0", map("CQL_VERSION")?(0)?)


class iso BytesMapParserTest is UnitTest

    fun name(): String =>
        "BytesMapParser.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x06; 0x73; 0x6E; 0x61
            0x70; 0x70; 0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45
            0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x05; 0x33; 0x2E
            0x30; 0x2E; 0x30
        ]
        
        let map: collections.Map[String box, (Array[U8 val] ref | None val)] = BytesMapParser(data)?
        var x = [as U8: 0x73; 0x6E; 0x61; 0x70; 0x70; 0x79]
        var y = match map("COMPRESSION")?
        | let z: Array[U8 val] ref => z
        else Array[U8 val]
        end

        for (a, b) in Zip2[U8 val, U8 val](x.values(), y.values()) do
            h.assert_eq[U8 val](a, b)
        end
        
        x = [as U8: 0x33; 0x2E; 0x30; 0x2E; 0x30]
        y = (map("CQL_VERSION")? as Array[U8 val] ref)
        for (a, b) in Zip2[U8 val, U8 val](x.values(), y.values()) do
            h.assert_eq[U8 val](a, b)
        end
