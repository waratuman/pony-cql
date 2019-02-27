use "ponytest"
use "itertools"

actor AuthSuccessResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthSuccessResponseVisitorTest)


class iso AuthSuccessResponseVisitorTest is UnitTest
    
    fun name(): String =>
        "AuthSuccessResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var response: AuthSuccessResponse val = recover AuthSuccessResponse() end
        var result: Array[U8 val] val = recover AuthSuccessResponseVisitor(response) end
        var data = [ as U8: 0xFF; 0xFF; 0xFF; 0xFF ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](a, b)
        end

        response = recover AuthSuccessResponse(recover [as U8: 0xAB; 0xCD] end) end
        result = recover AuthSuccessResponseVisitor(response) end
        data = [ as U8: 0x00; 0x00; 0x00; 0x02; 0xAB; 0xCD ]
        for (c, d) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](c, d)
        end
