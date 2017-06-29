use "ponytest"


actor FrameVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(FrameVisitorTest)


class iso FrameVisitorTest is UnitTest
    
    fun name(): String =>
        "FrameVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var request: Request val = recover StartupRequest("3.0.0") end
        var frame: Frame val = recover Frame(4, 0, 0, request) end
        var result: Array[U8 val] val = recover FrameVisitor(frame) end
        
        h.assert_eq[String val](
            "0400000001000000160001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(result)
        )

        request = recover AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end) end
        frame = recover Frame(4, 0, 0, request) end
        result = recover FrameVisitor(frame) end
        h.assert_eq[String val](
            "040000000F0000000600000002ABCD",
            Bytes.to_hex_string(result)
        )
