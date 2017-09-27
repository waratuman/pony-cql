use "ponytest"
use "itertools"

actor AuthResponseRequestVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthResponseRequestVisitorTest)


class iso AuthResponseRequestVisitorTest is UnitTest

    fun name(): String =>
        "AuthResponseRequestVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var request: AuthResponseRequest val = recover AuthResponseRequest() end
        var result: Array[U8 val] val = recover AuthResponseRequestVisitor(request) end
        var data = [ as U8: 0xFF; 0xFF; 0xFF; 0xFF ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](a, b)
        end

        request = recover AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end) end
        result = recover AuthResponseRequestVisitor(request) end
        data = [ as U8: 0x00; 0x00; 0x00; 0x02; 0xAB; 0xCD ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](a, b)
        end
