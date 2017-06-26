use "ponytest"

actor Main is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        RequestTestList.make().tests(test)
        ResponseTestList.make().tests(test)

        // Parsers
        AuthResponseRequestParserTestList.make().tests(test)
        AuthenticateResponseParserTestList.make().tests(test)
        AuthSuccessResponseParserTestList.make().tests(test)
        ErrorResponseParserTestList.make().tests(test)
        FrameParserTestList.make().tests(test)
        FrameTestList.make().tests(test)
        OptionsRequestParserTestList.make().tests(test)
        QueryRequestParserTestList.make().tests(test)
        StackTestList.make().tests(test)
        ReadyResponseParserTestList.make().tests(test)
        StartupRequestParserTestList.make().tests(test)
        SupportedResponseParserTestList.make().tests(test)

        // Not refactored:
        BytesTestList.make().tests(test)
        OldVisitorTestList.make().tests(test)
        RequestTestList.make().tests(test)
        ResponseTestList.make().tests(test)
