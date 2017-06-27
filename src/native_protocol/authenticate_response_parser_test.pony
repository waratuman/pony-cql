use "ponytest"

actor AuthenticateResponseParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthenticateResponseParserTest)


class iso AuthenticateResponseParserTest is UnitTest

    fun name(): String =>
        "AuthenticateResponseParser.parse"
    
    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] ref = [as U8:
            0x00; 0x2F; 0x6F; 0x72; 0x67; 0x2E; 0x61; 0x70; 0x61; 0x63; 0x68
            0x65; 0x2E; 0x63; 0x61; 0x73; 0x73; 0x61; 0x6E; 0x64; 0x72; 0x61
            0x2E; 0x61; 0x75; 0x74; 0x68; 0x2E; 0x50; 0x61; 0x73; 0x73; 0x77
            0x6F; 0x72; 0x64; 0x41; 0x75; 0x74; 0x68; 0x65; 0x6E; 0x74; 0x69
            0x63; 0x61; 0x74; 0x6F; 0x72
        ]
        var response = AuthenticateResponseParser(data)

        h.assert_eq[String val](
            "org.apache.cassandra.auth.PasswordAuthenticator",
            response.authenticator_name
        )
