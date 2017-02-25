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
