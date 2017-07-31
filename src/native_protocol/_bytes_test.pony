use "ponytest"

actor BytesTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestBytesOfI8)
        test(_TestBytesOfI16)
        test(_TestBytesOfI32)
        test(_TestBytesOfU8)
        test(_TestBytesOfU16)
        test(_TestBytesOfU32)
        test(_TestBytesI8)
        test(_TestBytesI16)
        test(_TestBytesI32)
        test(_TestBytesU8)
        test(_TestBytesU16)
        test(_TestBytesU32)

class iso _TestBytesOfI8 is UnitTest
    fun name(): String => "cql/bytes/of[I8]"
    
    fun tag apply(h: TestHelper) ? =>
        var number: I8 = I8.max_value()
        var bytes = Bytes.of(number)
        h.assert_eq[U8](0x7F, bytes.apply(0)?)

class iso _TestBytesOfU8 is UnitTest
    fun name(): String => "cql/bytes/of[U8]"
    
    fun tag apply(h: TestHelper) ? =>
        var number: U8 = 0xFA
        var bytes = Bytes.of(number)
        h.assert_eq[U8](0xFA, bytes.apply(0)?)

class iso _TestBytesOfI16 is UnitTest
    fun name(): String => "Bytes.of[I16]"
    
    fun tag apply(h: TestHelper) ? =>
        var number: I16 = I16.max_value()
        var bytes = Bytes.of(number)
        h.assert_eq[U8](0x7F, bytes.apply(0)?)
        h.assert_eq[U8](0xFF, bytes.apply(1)?)

        number = 0x00FF
        bytes = Bytes.of(number)
        h.assert_eq[U8](0x00, bytes.apply(0)?)
        h.assert_eq[U8](0xFF, bytes.apply(1)?)

class iso _TestBytesOfU16 is UnitTest
    fun name(): String => "Bytes.of[U16]"
    
    fun tag apply(h: TestHelper) ? =>
        var number: U16 = 0xFF00
        var bytes = Bytes.of(number)
        h.assert_eq[U8](0xFF, bytes.apply(0)?)
        h.assert_eq[U8](0x00, bytes.apply(1)?)

        number = 0x00FF
        bytes = Bytes.of(number)
        h.assert_eq[U8](0x00, bytes.apply(0)?)
        h.assert_eq[U8](0xFF, bytes.apply(1)?)

class iso _TestBytesOfI32 is UnitTest
    fun name(): String => "Bytes.of[I32]"
    
    fun tag apply(h: TestHelper) ? =>
        var number: I32 = 0x11223344
        var bytes = Bytes.of(number)
        h.assert_eq[U8](0x11, bytes.apply(0)?)
        h.assert_eq[U8](0x22, bytes.apply(1)?)
        h.assert_eq[U8](0x33, bytes.apply(2)?)
        h.assert_eq[U8](0x44, bytes.apply(3)?)

        number = 0x44332211
        bytes = Bytes.of(number)
        h.assert_eq[U8](0x11, bytes.apply(3)?)
        h.assert_eq[U8](0x22, bytes.apply(2)?)
        h.assert_eq[U8](0x33, bytes.apply(1)?)
        h.assert_eq[U8](0x44, bytes.apply(0)?)

class iso _TestBytesOfU32 is UnitTest
    fun name(): String => "Bytes.of[U32]"
    
    fun tag apply(h: TestHelper) ? =>
        var number: U32 = 0x11223344
        var bytes = Bytes.of(number)
        h.assert_eq[U8](0x11, bytes.apply(0)?)
        h.assert_eq[U8](0x22, bytes.apply(1)?)
        h.assert_eq[U8](0x33, bytes.apply(2)?)
        h.assert_eq[U8](0x44, bytes.apply(3)?)

        number = 0x44332211
        bytes = Bytes.of(number)
        h.assert_eq[U8](0x11, bytes.apply(3)?)
        h.assert_eq[U8](0x22, bytes.apply(2)?)
        h.assert_eq[U8](0x33, bytes.apply(1)?)
        h.assert_eq[U8](0x44, bytes.apply(0)?)

class iso _TestBytesI8 is UnitTest
    fun name(): String => "Bytes.i8"
    
    fun tag apply(h: TestHelper) ? =>
        let a: I8 = I8.min_value()
        let b: I8 = I8.max_value()
        h.assert_eq[I8](a, Bytes.i8(Bytes.of(a))?)
        h.assert_eq[I8](b, Bytes.i8(Bytes.of(b))?)

class iso _TestBytesU8 is UnitTest
    fun name(): String => "Bytes.u8"
    
    fun tag apply(h: TestHelper) ? =>
        let a: U8 = 0x00
        let b: U8 = 0xFF
        h.assert_eq[U8](a, Bytes.u8(Bytes.of(a))?)
        h.assert_eq[U8](b, Bytes.u8(Bytes.of(b))?)

class iso _TestBytesI16 is UnitTest
    fun name(): String => "Bytes.u16"
    
    fun tag apply(h: TestHelper) ? =>
        let a: I16 = I16.min_value()
        let b: I16 = I16.max_value()
        h.assert_eq[I16](a, Bytes.i16(Bytes.of(a))?)
        h.assert_eq[I16](b, Bytes.i16(Bytes.of(b))?)

class iso _TestBytesU16 is UnitTest
    fun name(): String => "Bytes.u16"
    
    fun tag apply(h: TestHelper) ? =>
        let a: U16 = 0x00FF
        let b: U16 = 0xFF00
        h.assert_eq[U16](a, Bytes.u16(Bytes.of(a))?)
        h.assert_eq[U16](b, Bytes.u16(Bytes.of(b))?)

class iso _TestBytesI32 is UnitTest
    fun name(): String => "Bytes.i32"
    
    fun tag apply(h: TestHelper) ? =>
        let a: I32 = I32.min_value()
        let b: I32 = I32.max_value()
        h.assert_eq[I32](a, Bytes.i32(Bytes.of(a))?)
        h.assert_eq[I32](b, Bytes.i32(Bytes.of(b))?)

class iso _TestBytesU32 is UnitTest
    fun name(): String => "Bytes.u32"
    
    fun tag apply(h: TestHelper) ? =>
        let a: U32 = 0x00FF00FF
        let b: U32 = 0xFF00FF00
        h.assert_eq[U32](a, Bytes.u32(Bytes.of(a))?)
        h.assert_eq[U32](b, Bytes.u32(Bytes.of(b))?)
