use "ponytest"

actor ClientTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestClientCreate)

class _TestClientCreate is UnitTest
    fun name(): String => "Client.create"

    fun tag apply(h: TestHelper) ? =>
        h.expect_action("client connected")
        let auth = h.env.root as AmbientAuth
        let server: TestServer = TestServer(auth, _TestClientCreateServerNotify(h))
        h.dispose_when_done(server)
        h.long_test(20_000_000)

class _TestClientCreateServerNotify  is TestServerNotify

    let _h: TestHelper

    new iso create(h: TestHelper) =>
        _h = h

    fun ref listening(server: TestServer ref) =>
        try
            (let host, let port) = server.local_address.name()
            let client = Client(
                _h.env.root as AmbientAuth,
                _TestClientCreateClientNotify(_h),
                host,
                port
            )
            _h.dispose_when_done(client)
        end

class _TestClientCreateClientNotify is ClientNotify
    
    let _h: TestHelper

    new iso create(h: TestHelper) =>
        _h = h

    fun ref connected(client: Client ref) =>
        _h.complete_action("client connected")
        client.close()

// class _TestClientClosed is UnitTest

// class _TestClientConnect is UnitTest

// class _TestClientConnectFailed is UnitTest

// class _TestClientConnected is UnitTest

// class _TestClientReceived is UnitTest

// class _TestClientThrottled is UnitTest

// class _TestClientUnthrottled is UnitTest
