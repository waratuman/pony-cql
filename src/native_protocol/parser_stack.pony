use "../cql"
use collections = "collections"

class ParserStack

    var _offset: USize = 0
    let _data: Array[U8 val] val

    new ref apply(data: Array[U8 val] val) =>
        _data = data

    new ref create(data: Array[U8 val] val) =>
        _data = data

    fun box offset(): USize =>
        _offset

    fun box size(): USize =>
        _data.size() - _offset

    fun ref shift(): U8 val ? =>
        _data(_offset = _offset + 1)

    fun ref shiftN(n: USize val): Array[U8 val] val ? =>
        if ((_offset + n) > _data.size()) then
            error
        end

        let start: USize val = _offset
        _offset = _offset + n
        recover _data.slice(start, _offset) end

    fun ref uint(): U32 val ? =>
        """
        A 4 byte unsigned integer.
        """
        let a = shift().u32()
        let b = shift().u32()
        let c = shift().u32()
        let d = shift().u32()
        (a << 24) or (b << 16) or (c << 8) or d

    fun ref int(): I32 val ? =>
        """
        A 4 byte signed integer.
        """
        let a = shift().i32()
        let b = shift().i32()
        let c = shift().i32()
        let d = shift().i32()
        (a << 24) or (b << 16) or (c << 8) or d
    
    fun ref long(): I64 val ? =>
        """
        A 8 byte signed integer.
        """
        (int().i64() << 32) or int().i64()

    fun ref byte(): U8 val ? =>
        shift()

    fun ref short(): U16 val ? =>
        """
        A 2 byte unsigned integer.
        """
        let a = shift().u16()
        let b = shift().u16()
        ((a << 8) or b)
    
    fun ref string(): String val ? => 
        """
        A short, n, followed by a n byte UTF-8 string.
        """
        let length = short().usize()
        String.from_array(shiftN(length))
    
    fun ref long_string(): String val ? =>
        """
        An int, n, followed by a n byte UTF-8 string.
        """
        let length = int().usize()
        String.from_array(shiftN(length))

    fun ref uuid(): Array[U8 val] val ? =>
        """
        A 16 byte long uuid.
        """
        shiftN(16)

    fun ref string_list(): Array[String val] val ? =>
        """
        A short, n, followed by n strings.
        """
        recover
            let result = Array[String val]()
            let n: U16 val = short()
            var i: U16 = 0
            while i < n do
                result.push(string())
                i = i + 1
            end
            result
        end

    fun ref bytes(): (Array[U8 val] val | None val) ? =>
        """
        An int, n, followed by n bytes. If n < 0, no bytes follow and None is
        returned.
        """
        let length = int()
        if (length < 0) then
            None
        else
            shiftN(length.usize())
        end

    fun ref value(): (Array[U8 val] val | None val) ? =>
        """
        An int, n, followed by n bytes. If n == -1 the value None is returned.
        The docs mention n == -2 meaning not set. This is not implemented yet.
        If n < -2 an error is thrown.
        """
        let length = int()
        if (length < -2) then
            error
        elseif (length < 0) then
            None
        else
            shiftN(length.usize())
        end

    fun ref short_bytes(): Array[U8 val] val ? =>
        """
        A short, n, followed by n bytes. If n < 0, no bytes follow and None is
        returned.
        """
        let length = short()
        shiftN(length.usize())

    // [unsigned vint]   An unsigned variable length integer. A vint is encoded with the most significant byte (MSB) first.
    //               The most significant byte will contains the information about how many extra bytes need to be read
    //               as well as the most significant bits of the integer.
    //               The number of extra bytes to read is encoded as 1 bits on the left side.
    //               For example, if we need to read 2 more bytes the first byte will start with 110
    //               (e.g. 256 000 will be encoded on 3 bytes as [110]00011 11101000 00000000)
    //               If the encoded integer is 8 bytes long the vint will be encoded on 9 bytes and the first
    //               byte will be: 11111111
    
    // [option]       A pair of <id><value> where <id> is a [short] representing
    //                the option id and <value> depends on that option (and can be
    //                of size 0). The supported id (and the corresponding <value>)
    //                will be described when this is used.
    // [option list]  A [short] n, followed by n [option].

    fun ref inet(): Inet val ? =>
        """
        An address (ip and port) to a node. It consists of one byte, n, that
        represents the address size, followed by n bytes representing the IP
        address (in practice n can only be either 4 (IPv4) or 16 (IPv6)),
        following by an int representing the port.
        """
        let size' = byte()
        var host: (U32 val | U128 val)
        if size' == 4 then
            host = uint()
        elseif size' == 16 then
            host = (long().u128() << 64) or long().u128()
        else
            error
        end
        let port = uint()

        recover Inet.create(host, port) end

    fun ref inetaddr(): (U32 val | U128 val) ? =>
        """
        An IP address (without port) to a node. It consists of one byte, n, that
        represents the address size, followed by n bytes representing the IP
        address (in practice n can only be either 4 (IPv4) or 16 (IPv6)).
        """
        let size' = byte()
        if size' == 4 then
            uint()
        elseif size' == 16 then
            (long().u128() << 64) or long().u128()
        else
            error
        end

    fun ref consistency(): Consistency val ? =>
        """
        A consistency level specification. This is a short.
        """
        match short()
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
        else AnyConsistency
        end

    fun ref string_map(): collections.Map[String val, String val] val ? =>
        """
        A short, n, followed by n pair <k><v> where <k> and <v>
        are a string.
        """
        recover
            let pairs = short()
            let result = collections.Map[String val, String val](pairs.usize())
            var i: U16 = 0
            while i < pairs do
                result.insert(string(), string())
                i = i + 1
            end
            result
        end
    
    fun ref string_multimap(): collections.Map[String val, Array[String val] val] ? =>
        """
        A short, n, followed by n pair <k><v> where <k> is a
        string and <v> is a string_list.
        """
        recover
            let pairs = short()
            let result = collections.Map[String val, Array[String val] val](pairs.usize())
            var i: U16 = 0
            while i < pairs do
                result.insert(string(), string_list())
                i = i + 1
            end
            result
        end

    fun ref bytes_map(): collections.Map[String val, (Array[U8 val] val | None val)] val ? =>
        """
        A short, n, followed by n pair <k><v> where <k> is a string and <v>
        is a bytes.
        """
        recover
            let pairs = short()
            let result = collections.Map[String val, (Array[U8 val] val | None val)](pairs.usize())
            var i: U16 = 0
            while i < pairs do
                result.insert(string(), bytes())
                i = i + 1
            end
            result
        end
