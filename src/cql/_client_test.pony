use "ponytest"

actor ClientTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestClientCreate)

class _TestClientCreate is UnitTest
    fun name(): String => "Client.create"

    fun tag apply(h: TestHelper) =>
        let client = Client(h.env)
        


// class _TestAuthenticate is UnitTest

// class _TestClosed is UnitTest