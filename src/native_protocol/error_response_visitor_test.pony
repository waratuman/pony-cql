use "ponytest"
use "itertools"

actor ErrorResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(ErrorResponseVisitorTest)


class iso ErrorResponseVisitorTest is UnitTest
    fun name(): String => "ErrorResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let request: ErrorResponse val = ErrorResponse(0x0000, "Server error")
        let result: Array[U8 val] val = recover ErrorResponseVisitor(request) end
        let data = [ as U8:
            0x00; 0x00; 0x00; 0x00; 0x00; 0x0C; 0x53; 0x65; 0x72; 0x76; 0x65
            0x72; 0x20; 0x65; 0x72; 0x72; 0x6F; 0x72
        ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](a, b)
        end
