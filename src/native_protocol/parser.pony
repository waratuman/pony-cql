use "../cql"
use collections = "collections"


interface Parser[A]

    fun box apply(data: Seq[U8 val] iso): A ?


primitive ByteParser is Parser[U8 val]

    fun box apply(data: Seq[U8 val] ref): U8 val ? =>
        data.shift()?


primitive UIntParser is Parser[U32 val]
    """
    A 4 byte unsigned integer.
    """

    fun box apply(data: Seq[U8 val] ref): U32 val ? =>
        let a = data.shift()?.u32()
        let b = data.shift()?.u32()
        let c = data.shift()?.u32()
        let d = data.shift()?.u32()
        (a << 24) or (b << 16) or (c << 8) or d


primitive IntParser is Parser[I32 val]
    """
    A 4 byte signed integer.
    """

    fun box apply(data: Seq[U8 val] ref): I32 val ? =>
        let a = data.shift()?.i32()
        let b = data.shift()?.i32()
        let c = data.shift()?.i32()
        let d = data.shift()?.i32()
        (a << 24) or (b << 16) or (c << 8) or d


primitive LongParser is Parser[I64 val]
    """
    A 8 byte signed integer.
    """

    fun box apply(data: Seq[U8 val] ref): I64 val ? =>
        let a = data.shift()?.i64()
        let b = data.shift()?.i64()
        let c = data.shift()?.i64()
        let d = data.shift()?.i64()
        let e = data.shift()?.i64()
        let f = data.shift()?.i64()
        let g = data.shift()?.i64()
        let h = data.shift()?.i64()
        (a << 56) or (b << 48) or (c << 40) or (d << 32) or (e << 24) or (f << 16) or (g << 8) or h


primitive ShortParser is Parser[U16 val]
    """
    A 2 byte unsigned integer.
    """

    fun box apply(data: Seq[U8 val] ref): U16 val ? =>
        let a = data.shift()?.u16()
        let b = data.shift()?.u16()
        ((a << 8) or b)


primitive StringParser is Parser[String ref]
    """
    A short, n, followed by a n byte UTF-8 string.
    """

    fun box apply(data: Seq[U8 val] ref): String iso^ ? =>
        var length = ShortParser(data)?.usize()
        let result = recover iso String end
        while (length = length - 1) > 0 do
            result.push(data.shift()?)
        end
        consume result


primitive LongStringParser is Parser[String]
    """
    An int, n, followed by a n byte UTF-8 string.
    """

    fun box apply(data: Seq[U8 val] ref): String iso^ ? =>
        var length = IntParser(data)?.usize()
        let result = recover iso String end
        while (length = length - 1) > 0 do
            result.push(data.shift()?)
        end
        consume result


primitive UUIDParser is Parser[Array[U8 val]]
    """
    A 16 byte long uuid.
    """
    
    fun box apply(data: Seq[U8 val] ref): Array[U8 val] iso^ ? =>
        let result = recover iso Array[U8 val] end
        var length: USize val = 16
        while (length = length - 1) > 0 do
            result.push(data.shift()?)
        end
        consume result


primitive StringListParser is Parser[Array[String val]]
    """
    A short, n, followed by n strings.
    """

    fun box apply(data: Seq[U8 val] ref): Array[String val] iso^ ? =>
        let result = recover iso Array[String val] end
        var length: U16 val = ShortParser(data)?
        while (length = length - 1) > 0 do
            result.push(StringParser(data)?)
        end
        consume result


primitive BytesParser is Parser[(Array[U8 val] | None)]
    """
    An int, n, followed by n bytes. If n < 0, no bytes follow and None is
    returned.
    """

    fun box apply(data: Seq[U8 val] ref): (Array[U8 val] iso^ | None) ? =>
        var length = IntParser(data)?
        if (length < 0) then
            return None
        end

        let result: Array[U8 val] iso = recover iso Array[U8 val] end
        while (length = length - 1) > 0 do
            result.push(data.shift()?)
        end
        consume result


primitive ValueParser is Parser[(Array[U8 val] ref | None)]
    """
    An int, n, followed by n bytes. If n == -1 the value None is returned.
    The docs mention n == -2 meaning not set. This is not implemented yet.
    If n < -2 an error is thrown.
    """

    fun box apply(data: Seq[U8 val] ref): (Array[U8 val] ref | None) ? =>
        var length = IntParser(data)?
        if (length < -2) then
            error
        elseif (length < 0) then
            return None
        end

        let result = Array[U8 val]
        while (length = length - 1) > 0 do
            result.push(data.shift()?)
        end
        result


primitive ShortBytesParser is Parser[Array[U8 val] ref]
    """
    A short, n, followed by n bytes. If n < 0, no bytes follow and None is
    returned.
    """

    fun box apply(data: Seq[U8 val] ref): Array[U8 val] ref ? =>
        var length = ShortParser(data)?
        let result = Array[U8 val]
        while (length = length - 1) > 0 do
            result.push(data.shift()?)
        end
        result


primitive OptionParser is Parser[(U16 val, (Array[U8 val] ref | None))]
    """
    A pair of <id><value> where <id> is a short representing
    the option id and <value> depends on that option (and can be
    of size 0). The supported id (and the corresponding <value>)
    will be described when this is used.
    """

    fun box apply(data: Seq[U8 val] ref): (U16 val, (Array[U8 val] ref | None)) ? =>
        let id = ShortParser(data)?
        let value = None

        (id, value)


primitive InetParser is Parser[Inet ref]
    """
    An address (ip and port) to a node. It consists of one byte, n, that
    represents the address size, followed by n bytes representing the IP
    address (in practice n can only be either 4 (IPv4) or 16 (IPv6)),
    following by an int representing the port.
    """

    fun box apply(data: Seq[U8 val] ref): Inet ref ? =>
        let size = ByteParser(data)?
        let host: (U32 val | U128 val) = if size == 4 then
            UIntParser(data)?
        elseif size == 16 then
            (LongParser(data)?.u128() << 64) or LongParser(data)?.u128()
        else
            error
        end

        let port = UIntParser(data)?
        Inet(host, port)


primitive InetAddrParser is Parser[(U32 val | U128 val)]
    """
    An IP address (without port) to a node. It consists of one byte, n, that
    represents the address size, followed by n bytes representing the IP
    address (in practice n can only be either 4 (IPv4) or 16 (IPv6)).
    """

    fun box apply(data: Seq[U8 val] ref): (U32 val | U128 val) ? =>
        let size = ByteParser(data)?
        if size == 4 then
            UIntParser(data)?
        elseif size == 16 then
            (LongParser(data)?.u128() << 64) or LongParser(data)?.u128()
        else
            error
        end


primitive ConsistencyParser is Parser[Consistency val]
    """
    A consistency level specification. This is a short.
    """

    fun box apply(data: Seq[U8 val] ref): Consistency val ? =>
        match ShortParser(data)?
        | 0x0000 => AnyConsistency
        | 0x0001 => One
        | 0x0002 => Two
        | 0x0003 => Three
        | 0x0004 => Quorum
        | 0x0005 => All
        | 0x0006 => LocalQuorum
        | 0x0007 => EachQuorum
        | 0x0008 => Serial
        | 0x0009 => LocalSerial
        | 0x000A => LocalOne
        else Quorum
        end


primitive StringMapParser is Parser[collections.Map[String val, String val]]
    """
    A short, n, followed by n pair <k><v> where <k> and <v>
    are a string.
    """
    
    fun box apply(data: Seq[U8 val] ref): collections.Map[String val, String val] iso^ ? =>
        var pairs = ShortParser(data)?
        let result = recover iso collections.Map[String val, String val](pairs.usize()) end
        while (pairs = pairs - 1) > 0 do
            result.insert(StringParser(data)?, StringParser(data)?)?
        end
        consume result


primitive StringMultiMapParser is Parser[collections.Map[String val, Array[String val] ref]]
    """
    A short, n, followed by n pair <k><v> where <k> is a
    string and <v> is a take_string_list.
    """

    fun box apply(data: Seq[U8 val] ref): collections.Map[String val, Array[String val] ref] iso^ ? =>
        var pairs = ShortParser(data)?
        let result = recover iso collections.Map[String val, Array[String val]](pairs.usize()) end
        while (pairs = pairs - 1) > 0 do
            result.insert(StringParser(data)?, StringListParser(data)?)?
        end
        consume result


primitive BytesMapParser is Parser[collections.Map[String box, (Array[U8 val] ref | None val)]]
    """
    A short, n, followed by n pair <k><v> where <k> is a string and <v>
    is a bytes.
    """
    
    fun box apply(data: Seq[U8 val] ref): collections.Map[String box, (Array[U8 val] ref | None val)] iso^ ? =>
        var pairs = ShortParser(data)?
        let result = recover iso collections.Map[String box, (Array[U8 val] ref | None val)](pairs.usize()) end
        while (pairs = pairs - 1) > 0 do
            result.insert(StringParser(data)?, BytesParser(data)?)?
        end
        consume result
