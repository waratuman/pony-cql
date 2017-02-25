use "ponytest"

actor BytesTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestBytesFromU16)
        test(_TestBytesFromU32)
        test(_TestBytesToU16)


class iso _TestBytesFromU16 is UnitTest
    fun name(): String => "cql/bytes/from_u16"
    
    fun tag apply(h: TestHelper) ? =>
        var number: U16 = 0xFF00
        var bytes = Bytes.from_u16(number)
        h.assert_eq[U8](0xFF, bytes.apply(0))
        h.assert_eq[U8](0x00, bytes.apply(1))

        number = 0x00FF
        bytes = Bytes.from_u16(number)
        h.assert_eq[U8](0x00, bytes.apply(0))
        h.assert_eq[U8](0xFF, bytes.apply(1))

class iso _TestBytesFromU32 is UnitTest
    fun name(): String => "cql/bytes/from_u32"
    
    fun tag apply(h: TestHelper) ? =>
        var number: U32 = 0x11223344
        var bytes = Bytes.from_u32(number)
        h.assert_eq[U8](0x11, bytes.apply(0))
        h.assert_eq[U8](0x22, bytes.apply(1))
        h.assert_eq[U8](0x33, bytes.apply(2))
        h.assert_eq[U8](0x44, bytes.apply(3))

        number = 0x44332211
        bytes = Bytes.from_u32(number)
        h.assert_eq[U8](0x11, bytes.apply(3))
        h.assert_eq[U8](0x22, bytes.apply(2))
        h.assert_eq[U8](0x33, bytes.apply(1))
        h.assert_eq[U8](0x44, bytes.apply(0))

class iso _TestBytesToU16 is UnitTest
    fun name(): String => "cql/bytes/to_u16"
    
    fun tag apply(h: TestHelper) ? =>
        h.assert_eq[U16](0x00FF, Bytes.to_u16(Bytes.from_u16(0x00FF)))
        h.assert_eq[U16](0xFF00, Bytes.to_u16(Bytes.from_u16(0xFF00)))
