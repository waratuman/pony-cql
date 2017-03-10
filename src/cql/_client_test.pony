use "ponytest"

actor ClientTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestClientCreate)


class _TestClientCreate is UnitTest
    fun name(): String => "Client.create"

    fun tag apply(h: TestHelper) =>
        let client = Client(h.env, _TestClientCreateNotify.create())


class _TestClientCreateNotify is ClientNotify

// class _TestClientClosed is UnitTest

// class _TestClientConnect is UnitTest

// class _TestClientConnecting is UnitTest

// class _TestClientConnectFailed is UnitTest

// class _TestClientConnected is UnitTest

// class _TestClientReceived is UnitTest

// class _TestClientThrottled is UnitTest

// class _TestClientUnthrottled is UnitTest
