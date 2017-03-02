use "ponytest"

actor Main is TestList
    new create(env: Env) =>
        PonyTest(env, this)
        // Client(env).connect()

    new make() => None

    fun tag tests(test: PonyTest) =>
        BytesTestList.make().tests(test)
        RequestTestList.make().tests(test)
        ResponseTestList.make().tests(test)
        VisitorTestList.make().tests(test)
        ParserTestList.make().tests(test)
