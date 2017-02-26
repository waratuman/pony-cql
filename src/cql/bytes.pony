use "format"

primitive Bytes

    fun val from_u16(u16: U16, array: Array[U8] iso = recover Array[U8 val] end): Array[U8 val] val =>
        let lsb: U8 = (u16 and 0xFF).u8()
        let msb: U8 = ((u16 >> 8) and 0xFF).u8()
        array.push(msb)
        array.push(lsb)
        consume array
    
    fun val from_u32(u32: U32, array: Array[U8] iso = recover Array[U8 val] end): Array[U8 val] val =>
        let a: U8 = (u32 and 0xFF).u8()
        let b: U8 = ((u32 >> 8) and 0xFF).u8()
        let c: U8 = ((u32 >> 16) and 0xFF).u8()
        let d: U8 = ((u32 >> 24) and 0xFF).u8()
        array.push(d)
        array.push(c)
        array.push(b)
        array.push(a)
        consume array
    
    fun val to_u16(data: Array[U8 val] val): U16 val ? =>
        let msb: U16 val = data.apply(0).u16()
        let lsb: U8 val = data.apply(1)

        ((msb << 8) or lsb.u16())

    fun val to_u32(data: Array[U8 val] val): U32 val ? =>
        let a: U32 val = data.apply(0).u32()
        let b: U32 val = data.apply(1).u32()
        let c: U32 val = data.apply(2).u32()
        let d: U32 val = data.apply(3).u32()

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