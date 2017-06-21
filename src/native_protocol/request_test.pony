use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor RequestTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        AuthResponseRequestTestList.make().tests(test)
        OptionsRequestTestList.make().tests(test)
        QueryRequestTestList.make().tests(test)
        StartupRequestTestList.make().tests(test)
