use "format"

primitive Bytes

    fun val of[A: Integer[A] val](value: A): Array[U8 val] val =>
        recover
            let data = Array[U8 val]()
            var width: A = value.bitwidth()// - A.from[U8](8)
            let byte: A = A.from[U8](8)
            while width.usize() > 0 do
                width = width - byte
                data.push((value >> width).u8())
            end
            data
        end

    fun val i8(data: Array[U8 val] val): I8 val ? =>
        data(0).i8()

    fun val u8(data: Array[U8 val] val): U8 val ? =>
        data(0).u8()

    fun val i16(data: Array[U8 val] val): I16 val ? =>
        let a = data(0).i16()
        let b = data(1).i16()
        ((a << 8) or b)
    
    fun val u16(data: Array[U8 val] val): U16 val ? =>
        let a = data(0).u16()
        let b = data(1).u16()
        ((a << 8) or b)

    fun val i32(data: Array[U8 val] val): I32 val ? =>
        let a = data(0).i32()
        let b = data(1).i32()
        let c = data(2).i32()
        let d = data(3).i32()
        (a << 24) or (b << 16) or (c << 8) or d

    fun val u32(data: Array[U8 val] val): U32 val ? =>
        let a = data(0).u32()
        let b = data(1).u32()
        let c = data(2).u32()
        let d = data(3).u32()
        (a << 24) or (b << 16) or (c << 8) or d

    fun val from_hex_string(data: String val): Array[U8 val] val ? => 
        recover
            let result = Array[U8 val]()
            var index: USize = 0
            var value: U8 = 0

            while index < (data.size() - 1) do
                var msb = _hexValue(data(index))
                var lsb = _hexValue(data(index + 1))

                result.push((msb << 4) or lsb)
                index = index + 2
            end
            result
        end

    fun val to_hex_string(data: Array[U8 val] val): String val =>
        recover
            let hexString = String()
            for byte in data.values() do
                hexString.append(Format.int[U8](byte, FormatHexBare, PrefixDefault, 2))
            end
            hexString
        end
    
    fun _hexValue(byte: U8): U8 ? =>
        if (byte >= 48) and (byte <= 57) then
            byte - 48
        elseif (byte >= 97) and (byte <= 102) then
            byte - 87
        elseif (byte >= 65) and (byte <= 70) then
            byte - 55
        else
            error
        end