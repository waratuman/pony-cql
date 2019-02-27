use "ponytest"
use "itertools"


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
        var data = [ as U8:
            0x04; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00; 0x16; 0x00; 0x01
            0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49
            0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](a, b)
        end

        request = recover AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end) end
        frame = recover Frame(4, 0, 0, request) end
        result = recover FrameVisitor(frame) end
        data = [ as U8:
            0x04; 0x00; 0x00; 0x00; 0x0F; 0x00; 0x00; 0x00; 0x06; 0x00; 0x00
            0x00; 0x02; 0xAB; 0xCD
        ]
        for (c, d) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](c, d)
        end
