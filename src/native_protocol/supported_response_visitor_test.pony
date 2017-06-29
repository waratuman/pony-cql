use "ponytest"
use "itertools"

actor SupportedResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(SupportedResponseVisitorTest)


class iso SupportedResponseVisitorTest is UnitTest

    fun name(): String =>
        "SupportedResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let response: SupportedResponse val = recover iso SupportedResponse(recover ["3.0.0"] end, recover ["snappy"; "lzo"] end) end
        let result: Array[U8 val] val = recover SupportedResponseVisitor(response) end
        let data = [ as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x02; 0x00; 0x06; 0x73; 0x6E; 0x61
            0x70; 0x70; 0x79; 0x00; 0x03; 0x6C; 0x7A; 0x6F; 0x00; 0x0B; 0x43
            0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00
            0x01; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        for (a, b) in Zip2[U8, U8](data.values(), result.values()) do
            h.assert_eq[U8](a, b)
        end
