use "ponytest"


actor ResponseTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        AuthSuccessResponseTestList.make().tests(test)
        AuthenticateResponseTestList.make().tests(test)
        ErrorResponseTestList.make().tests(test)
        ReadyResponseTestList.make().tests(test)
        SupportedResponseTestList.make().tests(test)
        ResultResponseTestList.make().tests(test)


