use "ponytest"

actor Main is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        BytesTestList.make().tests(test)
        
        VisitorTestList.make().tests(test)
        ParserTestList.make().tests(test)

        FrameTestList.make().tests(test)
        RequestTestList.make().tests(test)
        ResponseTestList.make().tests(test)
