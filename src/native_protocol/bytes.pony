use "format"

primitive Bytes

    fun val of(value: (Signed val | Unsigned val)): Array[U8 val] iso^ =>
        match value
        | let v: U8 => ofU8(v)
        | let v: I8 => ofI8(v)
        | let v: U16 => ofU16(v)
        | let v: I16 => ofI16(v)
        | let v: U32 => ofU32(v)
        | let v: I32 => ofI32(v)
        // | let v: U64 => ofU64(v)
        // | let v: I64 => ofI64(v)
        // | let v: U128 => ofU128(v)
        // | let v: I128 => ofI128(v)
        // | let v: ULong => ofULong(v)
        // | let v: ILong => ofILong(v)
        // | let v: USize => ofUSize(v)
        // | let v: ISize => ofISize(v)
        else recover Array[U8]() end
        end

    fun val ofU8(value: U8): Array[U8 val] iso^ =>
        recover [value] end

    fun val ofI8(value: I8): Array[U8 val] iso^ =>
        recover [value.u8()] end
    
    fun val ofU16(value: U16): Array[U8 val] iso^ =>
        recover
            [ (value >> 8).u8(); value.u8() ]
        end

    fun val ofI16(value: I16): Array[U8 val] iso^ =>
        recover
            [ (value >> 8).u8(); value.u8() ]
        end

    fun val ofU32(value: U32): Array[U8 val] iso^ =>
        recover
            [ (value >> 24).u8(); (value >> 16).u8(); (value >> 8).u8(); value.u8() ]
        end

    fun val ofI32(value: I32): Array[U8 val] iso^ =>
        recover
            [ (value >> 24).u8(); (value >> 16).u8(); (value >> 8).u8(); value.u8() ]
        end

    fun val i8(data: Array[U8 val] box): I8 val ? =>
        data(0).i8()

    fun val u8(data: Array[U8 val] box): U8 val ? =>
        data(0).u8()

    fun val i16(data: Array[U8 val] box): I16 val ? =>
        let a = data(0).i16()
        let b = data(1).i16()
        ((a << 8) or b)
    
    fun val u16(data: Array[U8 val] box): U16 val ? =>
        let a = data(0).u16()
        let b = data(1).u16()
        ((a << 8) or b)

    fun val i32(data: Array[U8 val] box): I32 val ? =>
        let a = data(0).i32()
        let b = data(1).i32()
        let c = data(2).i32()
        let d = data(3).i32()
        (a << 24) or (b << 16) or (c << 8) or d

    fun val u32(data: Array[U8 val] box): U32 val ? =>
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

    fun val to_hex_string(data: Array[U8 val] box): String val =>
        var result: String val = ""
        for byte in data.values() do
            result = result + Format.int[U8](byte, FormatHexBare, PrefixDefault, 2)
        end
        result

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