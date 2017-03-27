use "ponytest"
use "logger"

actor ClientNotifyTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        // test(_TestClientNotifyAuthenticate)
        test(_TestClientNotify)


// class _ClientNotifyTestServer is

class _TestClientNotifyAuthenticate is (UnitTest & ClientNotify)

    var _client: (Client ref | None val) = None

    fun name(): String => "ClientNotify.authenticate"

    fun ref apply(h: TestHelper) ? =>
        h.expect_action("server listening")
        h.expect_action("client connecting")
        h.expect_action("client connected")
        h.expect_action("server accepted")

        let auth = h.env.root as AmbientAuth
        let server = Server(auth, _TestClientNotifyAuthenticateServerNotify(h), "", "9042")
        h.dispose_when_done(server)
        h.long_test(200_000_000)
    

class _TestClientNotifyAuthenticateServerNotify is ServerNotify

    let _h: TestHelper

    new iso create(h: TestHelper) =>
        _h = h

    fun ref accepted(server: Server ref, serverConnection: ServerConnection tag) =>
        _h.complete_action("server accepted")

    fun ref listening(server: Server ref) =>
        try
            (let host, let port) = server.local_address.name()
            let client = Client(
                _h.env.root as AmbientAuth,
                _TestClientNotifyAuthenticateClientNotify(_h),
                host,
                port
            )
            _h.dispose_when_done(client)
            _h.complete_action("server listening")
        end

    fun ref not_listening(server: Server) =>
        _h.fail_action("server listening")

class _TestClientNotifyAuthenticateClientNotify is ClientNotify
    
    let _h: TestHelper
    
    new iso create(h: TestHelper) =>
        _h = h

    fun ref connecting(client: Client, count: U32) =>
        _h.complete_action("client connecting")

    fun ref connected(client: Client) =>
        _h.complete_action("client connected")

// class _TestClientNotifyAuthenticateFailed is UnitTest

// class _TestClientNotifyAuthenticated is UnitTest

// class _TestClientNotifyClosed is UnitTest

// class _TestClientNotifyConnectFailed is UnitTest

class _TestClientNotify is (UnitTest & ClientNotify)

    var _client: (Client ref | None val) = None

    fun name(): String => "ClientNotify"

    fun ref apply(h: TestHelper) ? =>
        h.expect_action("server listening")
        h.expect_action("client connecting")
        h.expect_action("client connected")
        h.expect_action("client received")
        h.expect_action("client closed")
        h.expect_action("server accepted")

        let auth = h.env.root as AmbientAuth
        let logger = StringLogger(Fine, h.env.out)
        let server = Server(auth, _TestClientNotifyServerNotify(h), "", "9042", logger)
        h.dispose_when_done(server)
        h.long_test(2_000_000_000)
    

class _TestClientNotifyServerNotify is ServerNotify

    let _h: TestHelper

    new iso create(h: TestHelper) =>
        _h = h

    fun ref accepted(server: Server ref, serverConnection: ServerConnection tag) =>
        _h.complete_action("server accepted")

    fun ref listening(server: Server ref) =>
        try
            (let host, let port) = server.local_address.name()
            let logger = StringLogger(Fine, _h.env.out)
            let client = Client(
                _h.env.root as AmbientAuth,
                _TestClientNotifyClientNotify(_h),
                host,
                port,
                logger
            )
            _h.dispose_when_done(client)
            _h.complete_action("server listening")
        end

    fun ref not_listening(server: Server) =>
        _h.fail_action("server listening")

class _TestClientNotifyClientNotify is ClientNotify
    
    let _h: TestHelper

    new iso create(h: TestHelper) =>
        _h = h

    fun ref connecting(client: Client, count: U32) =>
        _h.complete_action("client connecting")

    fun ref connected(client: Client ref) =>
        _h.complete_action("client connected")
        client.options()

    fun ref received(client: Client ref, message: Message val) =>
        _h.complete_action("client received")
        client.close()

    fun ref closed(client: Client) =>
        _h.complete_action("client closed")

// class _TestClientNotifyThrottled is UnitTest

// class _TestClientNotifyUnthrottled is UnitTest


















// class iso _TestClientNotifyConnecting is UnitTest
//     fun name(): String => "ClientNotify.connecting"

//     fun tag apply(h: TestHelper) =>
//         h.expect_action("connecting")
//         _TestClientServer(h, _TestClientNotifyConnectingClientNotify(h), _TestClientNotifyConnectingServerNotify(h))
        
//         // let client = Client(h.env.root as AmbientAuth, _TestClientNotifyConnectingClientNotify.create(h), "", "9042")
//         h.long_test(200_000_000)
//         // h.dispose_when_done(client)
        

// class _TestClientNotifyConnectingClientNotify is ClientNotify

//     let _h: TestHelper

//     new iso create(h: TestHelper) =>
//         _h = h
    
//     fun ref connecting(client: Client, count: U32 val) =>
//         _h.complete_action("connecting")

// class _TestClientNotifyConnectingServerNotify is ServerNotify

//     let _h: TestHelper

//     new iso create(h: TestHelper) =>
//         _h = h