use "../native_protocol"

primitive ASCIIParser is Parser[String ref]
    """
    A short, n, followed by a n byte UTF-8 string.
    """

    fun box apply(data: Seq[U8 val] ref): String iso^ ? =>
        var length = ShortParser(data)?.usize()
        recover iso
            let result = String
            while (length = length - 1) > 0 do
                result.push(data.shift()?)
            end
            result
        end


primitive BigIntParser is Parser[I64 val]
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


primitive BooleanParser is Parser[Bool val]
    """
    A single byte.  A value of 0 denotes "false"; any other value denotes
    "true". (However, it is recommended that a value of 1 be used to represent
    "true".)
    """

    fun box apply(data: Seq[U8 val] ref): Bool val ? =>
        data.shift()? == 0x01


primitive TextParser is Parser[String val]
    """
    A sequence of bytes conforming to the UTF-8 specifications.
    """

    fun box apply(data: Seq[U8 val] ref): String iso^ =>
        let result = recover iso String end
        for value in data.values() do
            result.push(value)
        end
        consume result

        

primitive VarCharParser is Parser[String val]
    """
    An alias of the "text" type.
    """

    fun box apply(data: Seq[U8 val] ref): String iso^ =>  
        TextParser(data)
        

primitive SmallIntParser is Parser[I16 val]
    """
    A 4 byte signed integer.
    """

    fun box apply(data: Seq[U8 val] ref): I16 val ? =>
        let a = data.shift()?.i16()
        let b = data.shift()?.i16()
        (a << 8) or b
