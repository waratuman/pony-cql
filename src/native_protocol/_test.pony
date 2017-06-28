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
        ParserTestList.make().tests(test)

        // Visitors
        VisitorTestList.make().tests(test)
        FrameVisitorTestList.make().tests(test)

        // Not refactored:
        BytesTestList.make().tests(test)
        OldVisitorTestList.make().tests(test)
        RequestTestList.make().tests(test)
        ResponseTestList.make().tests(test)
