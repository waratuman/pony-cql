use "ponytest"
use "itertools"


actor AuthenticateResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthenticateResponseVisitorTest)


class iso AuthenticateResponseVisitorTest is UnitTest

    fun name(): String =>
        "AuthenticateResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let response: AuthenticateResponse val = recover AuthenticateResponse("org.apache.cassandra.auth.PasswordAuthenticator") end
        let result: Array[U8 val] val = recover AuthenticateResponseVisitor(response) end
        let data = [ as U8:
            0x00; 0x2F; 0x6F; 0x72; 0x67; 0x2E; 0x61; 0x70; 0x61; 0x63; 0x68
            0x65; 0x2E; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
            0x2E; 0x61; 0x75; 0x74; 0x68; 0x2E; 0x50; 0x61; 0x73; 0x73; 0x77
            0x6F; 0x72; 0x64; 0x41; 0x75; 0x74; 0x68; 0x65; 0x6E; 0x74; 0x69
            0x63; 0x61; 0x74; 0x6F; 0x72
        ]
        for (a, b) in Iter[U8 val](data.values()).zip[U8 val](result.values()) do
            h.assert_eq[U8](a, b)
        end
