use "ponytest"

actor Main is TestList
    new create(env: Env) =>
        PonyTest(env, this)
        // try
        //     let logger = StringLogger(Fine, env.out)
        //     Client(env.root as AmbientAuth, ClientNotifyTest.create(), "", "9042", logger)
        // end

    new make() => None

    fun tag tests(test: PonyTest) =>
        BytesTestList.make().tests(test)
        
        VisitorTestList.make().tests(test)
        ParserTestList.make().tests(test)

        FrameTestList.make().tests(test)
        RequestTestList.make().tests(test)
        ResponseTestList.make().tests(test)
