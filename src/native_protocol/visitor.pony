
use cql = "../cql"
use collections = "collections"

interface Visitor[A]

    fun box apply(obj: A, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref


primitive ByteVisitor is Visitor[U8 val]

    fun box apply(value: U8 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push(value)
        collector


primitive BoolVisitor is Visitor[Bool val]
    """
    A boolean value represented as 1 byte. 0 is False and 1 is True
    """

    fun box apply(value: Bool box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        if value == true then
            collector.push(0x01)
        else
            collector.push(0x00)
        end
        collector

primitive UIntVisitor is Visitor[U32 val]
    """
    A 4 byte unsigned integer.
    """

    fun box apply(value: U32 box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 24).u8())
        collector.push((value >> 16).u8())
        collector.push((value >> 8).u8())
        collector.push(value.u8())
        collector


primitive IntVisitor is Visitor[I32 val]
    """
    A 4 byte signed integer.
    """

    fun box apply(value: I32 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 24).u8())
        collector.push((value >> 16).u8())
        collector.push((value >> 8).u8())
        collector.push(value.u8())
        collector


primitive LongVisitor is Visitor[I64 val]
    """
    A 8 byte signed integer.
    """

    fun box apply(value: I64 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 56).u8())
        collector.push((value >> 48).u8())
        collector.push((value >> 40).u8())
        collector.push((value >> 32).u8())
        collector.push((value >> 24).u8())
        collector.push((value >> 16).u8())
        collector.push((value >> 08).u8())
        collector.push(value.u8())
        collector


primitive ShortVisitor is Visitor[U16 val]
    """
    A 2 byte unsigned integer.
    """

    fun box apply(value: U16 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push((value >> 8).u8())
        collector.push(value.u8())
        collector


primitive FloatVisitor is Visitor[F32 val]
    """
    A 4 byte floating point number in the IEEE 754 binary32 format.
    """

    fun box apply(value: F32 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        UIntVisitor(value.bits(), collector)


primitive DoubleVisitor is Visitor[F64 val]
    """
    An 8 byte floating point number in the IEEE 754 binary64 format.
    """

    fun box apply(value: F64 val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        let bits = value.bits()
        collector.push((bits >> 56).u8())
        collector.push((bits >> 48).u8())
        collector.push((bits >> 40).u8())
        collector.push((bits >> 32).u8())
        collector.push((bits >> 24).u8())
        collector.push((bits >> 16).u8())
        collector.push((bits >> 08).u8())
        collector.push(bits.u8())
        collector


primitive StringVisitor is Visitor[String]
    """
    A short, n, followed by a n byte UTF-8 string.
    """

    fun box apply(value: String val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(value.size().u16(), collector)
        for byte in value.array().values() do
            ByteVisitor(byte, collector)
        end
        collector


primitive LongStringVisitor is Visitor[String]
    """
    An int, n, followed by a n byte UTF-8 string.
    """

    fun box apply(value: String val, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        IntVisitor(value.size().i32(), collector)
        for byte in value.array().values() do
            ByteVisitor(byte, collector)
        end
        collector


primitive UUIDVisitor is Visitor[Seq[U8 val]]
    """
    A 16 byte long uuid.
    """
    
    fun box apply(uuid: Seq[U8 val] box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        var length: USize = 0
        for byte in uuid.values() do
            ByteVisitor(byte)
        end
        collector


primitive StringListVisitor is Visitor[Array[String val]]
    """
    A short, n, followed by n strings.
    """

    fun box apply(value: Array[String val] box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(value.size().u16(), collector)
        for s in value.values() do
            StringVisitor(s, collector)
        end
        collector


primitive BytesVisitor is Visitor[(Seq[U8 val] | None)]
    """
    An int, n, followed by n bytes. If n < 0, no bytes follow and None is
    returned.
    """

    fun box apply(value: (Seq[U8 val] box | None), collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value
        | None => IntVisitor(-1, collector)
        | let v: Seq[U8 val] box =>
            IntVisitor(v.size().i32(), collector)
            for byte in v.values() do
                collector.push(byte)
            end
        end
        collector


primitive ValueVisitor is Visitor[(Seq[U8 val] ref | None)]
    """
    An int, n, followed by n bytes. If n == -1 the value None is returned.
    The docs mention n == -2 meaning not set. This is not implemented yet.
    If n < -2 an error is thrown.
    """

    fun box apply(value: (Seq[U8 val] box | None), collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value
        | None => IntVisitor(-1, collector)
        | let v: Seq[U8 val] box =>
            IntVisitor(v.size().i32(), collector)
            for byte in v.values() do
                collector.push(byte)
            end
        end
        collector


primitive ShortBytesVisitor is Visitor[Seq[U8 val] ref]
    """
    A short, n, followed by n bytes. If n < 0, no bytes follow and None is
    returned.
    """

    fun box apply(value: Seq[U8 val] box, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(value.size().u16(), collector)
        for byte in value.values() do
            collector.push(byte)
        end
        collector


primitive InetVisitor is Visitor[cql.Inet ref]
    """
    An address (ip and port) to a node. It consists of one byte, n, that
    represents the address size, followed by n bytes representing the IP
    address (in practice n can only be either 4 (IPv4) or 16 (IPv6)),
    following by an int representing the port.
    """

    fun box apply(value: cql.Inet ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value.host
        | let h: U32 box =>
            ByteVisitor(4, collector)
            UIntVisitor(h, collector)
        | let h: U128 box =>
            ByteVisitor(16, collector)
            LongVisitor((h >> 64).i64(), collector)
            LongVisitor(h.i64(), collector)
        end

        UIntVisitor(value.port, collector)
        collector


primitive InetAddrVisitor is Visitor[(U32 val | U128 val)]
    """
    An IP address (without port) to a node. It consists of one byte, n, that
    represents the address size, followed by n bytes representing the IP
    address (in practice n can only be either 4 (IPv4) or 16 (IPv6)).
    """

    fun box apply(value: (U32 box | U128 box), collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        match value
        | let h: U32 box =>
            ByteVisitor(4, collector)
            UIntVisitor(h, collector)
        | let h: U128 box =>
            ByteVisitor(16, collector)
            LongVisitor((h >> 64).i64(), collector)
            LongVisitor(h.i64(), collector)
        end
        collector


primitive ConsistencyVisitor is Visitor[Consistency val]
    """
    A consistency level specification. This is a short.
    """

    fun box apply(value: Consistency, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        collector.push(0x00)
        collector.push(match value
        | AnyConsistency => 0x00
        | One => 0x01
        | Two => 0x02
        | Three => 0x03
        | Quorum => 0x04
        | All => 0x05
        | LocalQuorum => 0x06
        | EachQuorum => 0x07
        | Serial => 0x08
        | LocalSerial => 0x09
        | LocalOne => 0x0A
        end)
        collector


primitive StringMapVisitor is Visitor[collections.Map[String val, String val]]
    """
    A short, n, followed by n pair <k><v> where <k> and <v>
    are a string.
    """
    
    fun box apply(map: collections.Map[String val, String val] ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(map.size().u16(), collector)
        for (key, value) in map.pairs() do
            StringVisitor(key, collector)
            StringVisitor(value, collector)
        end
        collector


primitive StringMultiMapVisitor is Visitor[collections.Map[String val, Array[String val] ref]]
    """
    A short, n, followed by n pair <k><v> where <k> is a
    string and <v> is a take_string_list.
    """

    fun box apply(map: collections.Map[String val, Array[String val] ref] ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(map.size().u16(), collector)
        for (key, value) in map.pairs() do
            StringVisitor(key, collector)
            StringListVisitor(value, collector)
        end
        collector


primitive BytesMapVisitor is Visitor[collections.Map[String val, (Array[U8 val] ref | None val)]]
    """
    A short, n, followed by n pair <k><v> where <k> is a string and <v>
    is a bytes.
    """
    
    fun box apply(map: collections.Map[String val, (Array[U8 val] ref | None val)] ref, collector: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        ShortVisitor(map.size().u16(), collector)
        for (key, value) in map.pairs() do
            StringVisitor(key, collector)
            BytesVisitor(value, collector)
        end
        collector
