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
        test(ByteVisitorTest)
        test(UIntVisitorTest)
        test(IntVisitorTest)
        test(LongVisitorTest)
        test(ShortVisitorTest)
        test(StringVisitorTest)
        test(LongStringVisitorTest)
        test(UUIDVisitorTest)
        test(StringListVisitorTest)
        test(BytesVisitorTest)
        test(ValueVisitorTest)
        test(ShortBytesVisitorTest)
        test(OptionVisitor)
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
        h.assert_eq[U8](3, collector(0))


class iso UIntVisitorTest is UnitTest

    fun name(): String =>
        "UIntVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Zip2[U8, U8](data.values(), UIntVisitor(U32.max_value()).values()) do
            h.assert_eq[U8](a, b)
        end


class iso IntVisitorTest is UnitTest

    fun name(): String =>
        "IntVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Zip2[U8, U8](data.values(), IntVisitor(-1).values()) do
            h.assert_eq[U8](a, b)
        end


class iso LongVisitorTest is UnitTest

    fun name(): String =>
        "LongVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Zip2[U8, U8](data.values(), LongVisitor(-1).values()) do
            h.assert_eq[U8](a, b)
        end
        

class iso ShortVisitorTest is UnitTest

    fun name(): String =>
        "ShortVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0xFF; 0xFF]
        for (a, b) in Zip2[U8, U8](data.values(), ShortVisitor(U16.max_value()).values()) do
            h.assert_eq[U8](a, b)
        end
        

class iso StringVisitorTest is UnitTest

    fun name(): String =>
        "StringVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let data = [as U8:
            0x00; 0x09; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
        ]
        for (a, b) in Zip2[U8, U8](data.values(), StringVisitor("cassandra").values()) do
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
        for (a, b) in Zip2[U8, U8](data.values(), LongStringVisitor("cassandra").values()) do
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
        for (a, b) in Zip2[U8 val, U8 val](data.values(), UUIDVisitor(data).values()) do
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
        for (a, b) in Zip2[U8 val, U8 val](data.values(), results.values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso BytesVisitorTest is UnitTest

    fun name(): String =>
        "BytesVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0x00; 0x00; 0x00; 0x02; 0x02; 0x03]
        for (a, b) in Zip2[U8 val, U8 val](BytesVisitor([as U8: 2; 3]).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end
    
        data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Zip2[U8 val, U8 val](BytesVisitor(None).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso ValueVisitorTest is UnitTest

    fun name(): String =>
        "ValueVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0xFF; 0xFF; 0xFF; 0xFF]
        for (a, b) in Zip2[U8 val, U8 val](ValueVisitor(None).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end
        
        data = [as U8: 0x00; 0x00; 0x00; 0x01; 0x01]
        for (a, b) in Zip2[U8 val, U8 val](ValueVisitor([as U8: 1]).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso ShortBytesVisitorTest is UnitTest

    fun name(): String =>
        "ShortBytesVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0x00; 0x02; 0x02; 0x03]
        for (a, b) in Zip2[U8 val, U8 val](ShortBytesVisitor([as U8: 2; 3]).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x00]
        for (a, b) in Zip2[U8 val, U8 val](ShortBytesVisitor(Array[U8 val]).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso OptionVisitor is UnitTest

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
        for (a, b) in Zip2[U8 val, U8 val](InetVisitor(Inet.create(ipv4, 5432)).values(), data.values()) do
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
        for (a, b) in Zip2[U8 val, U8 val](InetVisitor(Inet.create(ipv6, 5432)).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso InetAddrVisitorTest is UnitTest

    fun name(): String =>
        "InetAddrVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var data = [ as U8: 0x04; 0xC0; 0xA8; 0x00; 0x01 ]
        var ipv4: U32 = 3232235521
        for (a, b) in Zip2[U8 val, U8 val](InetAddrVisitor(ipv4).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [ as U8: 0x10 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x00 
            0x00; 0x00; 0x00; 0x00
            0x00; 0x00; 0x00; 0x01
        ]
        let ipv6: U128 = 1
        for (a, b) in Zip2[U8 val, U8 val](InetAddrVisitor(ipv6).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end


class iso ConsistencyVisitorTest is UnitTest

    fun name(): String =>
        "ConsistencyVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        var data = [as U8: 0x00; 0x00]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(AnyConsistency).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x01]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(One).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x02]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(Two).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x03]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(Three).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x04]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(Quorum).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x05]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(All).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x06]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(LocalQuorum).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x07]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(EachQuorum).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x08]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(Serial).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x09]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(LocalSerial).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end

        data = [as U8: 0x00; 0x0A]
        for (a, b) in Zip2[U8 val, U8 val](ConsistencyVisitor(LocalOne).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
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
        map.insert("COMPRESSION", "snappy")
        map.insert("CQL_VERSION", "3.0.0")
        for (a, b) in Zip2[U8 val, U8 val](StringMapVisitor(map).values(), data.values()) do
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
        map.insert("COMPRESSION", [as String val: "snappy"; "lzo"])
        map.insert("CQL_VERSION", [as String val: "3.0.0"])
        for (a, b) in Zip2[U8 val, U8 val](StringMultiMapVisitor(map).values(), data.values()) do
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
        map.insert("COMPRESSION", [as U8 val: 0x73; 0x6E; 0x61; 0x70; 0x70; 0x79])
        map.insert("CQL_VERSION", [as U8 val: 0x33; 0x2E; 0x30; 0x2E; 0x30])
        for (a, b) in Zip2[U8 val, U8 val](BytesMapVisitor(map).values(), data.values()) do
            h.assert_eq[U8 val](a, b)
        end
