use "format"
use "ponytest"
use collection = "collections"

actor MessageTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        None
