use "itertools"
use "ponytest"
use "../cql"
use collections = "collections"


actor VisitorTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        AuthResponseRequestVisitorTestList.make().tests(test)
        AuthSuccessResponseVisitorTestList.make().tests(test)
        AuthenticateResponseVisitorTestList.make().tests(test)
        ErrorResponseVisitorTestList.make().tests(test)
        FrameVisitorTestList.make().tests(test)
        OptionsRequestVisitorTestList.make().tests(test)
        QueryRequestVisitorTestList.make().tests(test)
        ReadyResponseVisitorTestList.make().tests(test)
        ResultResponseVisitorTestList.make().tests(test)
        StartupRequestVisitorTestList.make().tests(test)
        SupportedResponseVisitorTestList.make().tests(test)
        
        test(BoolVisitorTest)
        test(ByteVisitorTest)
        test(UIntVisitorTest)
        test(IntVisitorTest)
        test(LongVisitorTest)
        test(ShortVisitorTest)
        test(FloatVisitorTest)
        test(DoubleVisitorTest)
        test(StringVisitorTest)
        test(LongStringVisitorTest)
        test(UUIDVisitorTest)
        test(StringListVisitorTest)
        test(BytesVisitorTest)
        test(ValueVisitorTest)
        test(ShortBytesVisitorTest)
        test(OptionVisitorTest)
        test(OptionListVisitor)
        test(InetVisitorTest)
        test(InetAddrVisitorTest)
        test(ConsistencyVisitorTest)
        test(StringMapVisitorTest)
        test(StringMultiMapVisitorTest)
        test(BytesMapVisitorTest)


class iso ByteVisitorTest is UnitTest

    fun name(): String =>
        "ByteVisitor.apply"
    
    fun tag apply(h: TestHelper) ? =>
        let collector = ByteVisitor(3)
        h.assert_eq[USize](1, collector.size())
        h.assert_eq[U8](3, collector(0)?)


class iso BoolVisitorTest is UnitTest

    fun name(): String =>
        "BoolVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [ as U8: 0x00 ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](BoolVisitor(false).values()) do
            h.assert_eq[U8](a, b)
        end

        data = [ as U8: 0x01 ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](BoolVisitor(true).values()) do
            h.assert_eq[U8](a, b)
        end

class iso UIntVisitorTest is UnitTest

    fun name(): String =>
        "UIntVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](UIntVisitor(U32.max_value()).values()) do
            h.assert_eq[U8](a, b)
        end


class iso IntVisitorTest is UnitTest

    fun name(): String =>
        "IntVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](IntVisitor(-1).values()) do
            h.assert_eq[U8](a, b)
        end


class iso LongVisitorTest is UnitTest

    fun name(): String =>
        "LongVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](LongVisitor(-1).values()) do
            h.assert_eq[U8](a, b)
        end


class iso FloatVisitorTest is UnitTest

    fun name(): String =>
        "FloatVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        let expected = [ as U8: 0x7F; 0x7F; 0xFF; 0xFF ]
        let actual = FloatVisitor(F32.max_value())
        
        for (a, b) in Iter[U8 val](expected.values()).zip[U8 val](actual.values()) do
            h.assert_eq[U8](a, b)
        end


class iso DoubleVisitorTest is UnitTest

    fun name(): String =>
        "DoubleVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        let expected = [ as U8: 0x7F; 0xEF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF ]
        let actual = DoubleVisitor(F64.max_value())
        
        for (a, b) in Iter[U8 val](expected.values()).zip[U8 val](actual.values()) do
            h.assert_eq[U8](a, b)
        end

class iso ShortVisitorTest is UnitTest

    fun name(): String =>
        "ShortVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](ShortVisitor(U16.max_value()).values()) do
            h.assert_eq[U8](a, b)
        end
        

class iso StringVisitorTest is UnitTest

    fun name(): String =>
        "StringVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8:
            0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
        ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](StringVisitor("cassandra").values()) do
            h.assert_eq[U8](a, b)
        end


class iso LongStringVisitorTest is UnitTest

    fun name(): String =>
        "LongStringVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8:
            0x00; 0x00; 0x00; 0x09
            0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
        ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](LongStringVisitor("cassandra").values()) do
            h.assert_eq[U8](a, b)
        end


class iso UUIDVisitorTest is UnitTest

    fun name(): String =>
        "UUIDVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8:
            0x00; 0x01; 0x02; 0x03; 0x04; 0x05; 0x06; 0x07
            0x08; 0x09; 0x0A; 0x0B; 0x0C; 0x0D; 0x0E; 0x0F
        ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](UUIDVisitor(data).values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso StringListVisitorTest is UnitTest

    fun name(): String =>
        "StringListVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data: Array[U8 val] ref = [as U8:
            0x00; 0x02
            0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
            0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
        ]

        let results: Seq[U8 val] ref = StringListVisitor(["cassandra"; "cassandra"])
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](results.values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso BytesVisitorTest is UnitTest

    fun name(): String =>
        "BytesVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0x00; 0x00; 0x00; 0x02; 0x02; 0x03]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](BytesVisitor([as U8: 2; 3]).values()) do
            h.assert_eq[U8 val](a, b)
        end
    
        data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (c, d) in Iter[U8 val](data.values()).zip[U8 val](BytesVisitor(None).values()) do
            h.assert_eq[U8 val](c, d)
        end


class iso ValueVisitorTest is UnitTest

    fun name(): String =>
        "ValueVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](ValueVisitor(None).values()) do
            h.assert_eq[U8 val](a, b)
        end
        
        data = [as U8: 0x00; 0x00; 0x00; 0x01; 0x01]
        for (c, d) in Iter[U8 val](data.values()).zip[U8 val](ValueVisitor([as U8: 1]).values()) do
            h.assert_eq[U8 val](c, d)
        end


class iso ShortBytesVisitorTest is UnitTest

    fun name(): String =>
        "ShortBytesVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0x00; 0x02; 0x02; 0x03]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](ShortBytesVisitor([as U8: 2; 3]).values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x00]
        for (c, d) in Iter[U8 val](data.values()).zip[U8 val](ShortBytesVisitor(Array[U8 val]).values()) do
            h.assert_eq[U8 val](c, d)
        end


class iso OptionVisitorTest is UnitTest

    fun name(): String =>
        "OptionVisitor.apply"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso OptionListVisitor is UnitTest

    fun name(): String =>
        "OptionListVisitor.apply"

    fun tag apply(h: TestHelper) =>
        h.fail()


class iso InetVisitorTest is UnitTest

    fun name(): String =>
        "InetVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0x04
            0xC0; 0xA8; 0x00; 0x01
            0x00; 0x00; 0x15; 0x38
        ]
        var ipv4: U32 = 3232235521
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](InetVisitor(Inet.create(ipv4, 5432)).values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x10 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x00 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x01
            0x00; 0x00; 0x15; 0x38
        ]
        let ipv6: U128 = 1
        for (c, d) in Iter[U8 val](data.values()).zip[U8 val](InetVisitor(Inet.create(ipv6, 5432)).values()) do
            h.assert_eq[U8 val](c, d)
        end


class iso InetAddrVisitorTest is UnitTest

    fun name(): String =>
        "InetAddrVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [ as U8: 0x04; 0xC0; 0xA8; 0x00; 0x01 ]
        var ipv4: U32 = 3232235521
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](InetAddrVisitor(ipv4).values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [ as U8: 0x10 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x00 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x01
        ]
        let ipv6: U128 = 1
        for (c, d) in Iter[U8 val](data.values()).zip[U8 val](InetAddrVisitor(ipv6).values()) do
            h.assert_eq[U8 val](c, d)
        end


class iso ConsistencyVisitorTest is UnitTest

    fun name(): String =>
        "ConsistencyVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0x00; 0x00]
        for (a1, b1) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(AnyConsistency).values()) do
            h.assert_eq[U8 val](a1, b1)
        end

        data = [as U8: 0x00; 0x01]
        for (a2, b2) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(One).values()) do
            h.assert_eq[U8 val](a2, b2)
        end

        data = [as U8: 0x00; 0x02]
        for (a3, b3) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(Two).values()) do
            h.assert_eq[U8 val](a3, b3)
        end

        data = [as U8: 0x00; 0x03]
        for (a4, b4) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(Three).values()) do
            h.assert_eq[U8 val](a4, b4)
        end

        data = [as U8: 0x00; 0x04]
        for (a5, b5) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(Quorum).values()) do
            h.assert_eq[U8 val](a5, b5)
        end

        data = [as U8: 0x00; 0x05]
        for (a6, b6) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(All).values()) do
            h.assert_eq[U8 val](a6, b6)
        end

        data = [as U8: 0x00; 0x06]
        for (a7, b7) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(LocalQuorum).values()) do
            h.assert_eq[U8 val](a7, b7)
        end

        data = [as U8: 0x00; 0x07]
        for (a8, b8) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(EachQuorum).values()) do
            h.assert_eq[U8 val](a8, b8)
        end

        data = [as U8: 0x00; 0x08]
        for (a9, b9) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(Serial).values()) do
            h.assert_eq[U8 val](a9, b9)
        end

        data = [as U8: 0x00; 0x09]
        for (a10, b10) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(LocalSerial).values()) do
            h.assert_eq[U8 val](a10, b10)
        end

        data = [as U8: 0x00; 0x0A]
        for (a11, b11) in Iter[U8 val](data.values()).zip[U8 val](ConsistencyVisitor(LocalOne).values()) do
            h.assert_eq[U8 val](a11, b11)
        end


class iso StringMapVisitorTest is UnitTest

    fun name(): String =>
        "StringMapVisitor.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x06; 0x73; 0x6E; 0x61; 0x70; 0x70
            0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53
            0x49; 0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]

        let map = collections.Map[String val, String val](2)
        map.insert("COMPRESSION", "snappy")?
        map.insert("CQL_VERSION", "3.0.0")?
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](StringMapVisitor(map).values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso StringMultiMapVisitorTest is UnitTest

    fun name(): String =>
        "StringMultiMapVisitor.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x02; 0x00; 0x06; 0x73; 0x6E; 0x61
            0x70; 0x70; 0x79; 0x00; 0x03; 0x6C; 0x7A; 0x6F; 0x00; 0x0B; 0x43
            0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00
            0x01; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        
        let map = collections.Map[String val, Array[String val] ref]
        map.insert("COMPRESSION", [as String val: "snappy"; "lzo"])?
        map.insert("CQL_VERSION", [as String val: "3.0.0"])?
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](StringMultiMapVisitor(map).values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso BytesMapVisitorTest is UnitTest

    fun name(): String =>
        "BytesMapVisitor.apply"

    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x06; 0x73; 0x6E; 0x61
            0x70; 0x70; 0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45
            0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00; 0x00; 0x00; 0x05; 0x33; 0x2E
            0x30; 0x2E; 0x30
        ]
        
        let map = collections.Map[String val, (Array[U8 val] ref | None val)]
        map.insert("COMPRESSION", [as U8 val: 0x73; 0x6E; 0x61; 0x70; 0x70; 0x79])?
        map.insert("CQL_VERSION", [as U8 val: 0x33; 0x2E; 0x30; 0x2E; 0x30])?
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](BytesMapVisitor(map).values()) do
            h.assert_eq[U8 val](a, b)
        end
