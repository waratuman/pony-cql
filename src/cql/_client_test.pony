use "ponytest"
use "logger"

actor ClientTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestClientCreate)

class _TestClientCreate is UnitTest
    fun name(): String => "Client.create"

    fun tag apply(h: TestHelper) =>
        None
        // let logger = StringLogger(Fine, h.env.out)
        // // let server = Server.create(h.env.root as AmbientAuth, "localhost", "7654", logger)
        
        // let client = Client(h.env.root as AmbientAuth, _TestClientCreateNotify.create(), "localhost", "7654", logger)
        // h.long_test(200_000_000)
        // h.dispose_when_done(client)
        // // h.dispose_when_done(server)


class _TestClientCreateNotify is ClientNotify

// class _TestClientClosed is UnitTest

// class _TestClientConnect is UnitTest

// class _TestClientConnectFailed is UnitTest

// class _TestClientConnected is UnitTest

// class _TestClientReceived is UnitTest

// class _TestClientThrottled is UnitTest

// class _TestClientUnthrottled is UnitTest
