use "ponytest"
use "logger"

actor ClientNotifyTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestClientNotify)
        test(_TestClientNotifyAuthenticated)
        test(_TestClientNotifyAuthenticateFailed)
        

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
        // let logger = StringLogger(Fine, h.env.out)
        // let server = Server(auth, _TestClientNotifyServerNotify(h), "", "", logger)
        let server = Server(auth, _TestClientNotifyServerNotify(h))
        h.dispose_when_done(server)
        h.long_test(20_000_000)
    

class _TestClientNotifyServerNotify is ServerNotify

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
                _TestClientNotifyClientNotify(_h),
                host,
                port
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


class _TestClientNotifyAuthenticated is (UnitTest & ClientNotify)

    var _client: (Client ref | None val) = None

    fun name(): String => "ClientNotify.authenticated"

    fun ref apply(h: TestHelper) ? =>
        h.expect_action("server listening")
        h.expect_action("client connecting")
        h.expect_action("client authenticate")
        h.expect_action("client authenticated")
        h.expect_action("client connected")
        h.expect_action("client received")
        h.expect_action("client closed")
        h.expect_action("server accepted")

        let auth = h.env.root as AmbientAuth
        let logger = StringLogger(Fine, h.env.out)
        let authenticator: PasswordAuthenticator = PasswordAuthenticator
        authenticator("cassandra", "cassandra")
        let server = Server(auth, _TestClientNotifyAuthenticatedServerNotify(h), consume authenticator, "", "0", logger)
        
        h.dispose_when_done(server)
        h.long_test(20_000_000)


class _TestClientNotifyAuthenticatedServerNotify is ServerNotify

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
                _TestClientNotifyAuthenticatedClientNotify(_h),
                host,
                port,
                logger
            )
            _h.dispose_when_done(client)
            _h.complete_action("server listening")
        end

    fun ref not_listening(server: Server) =>
        _h.fail_action("server listening")

class _TestClientNotifyAuthenticatedClientNotify is ClientNotify
    
    let _h: TestHelper
    
    new iso create(h: TestHelper) =>
        _h = h

    fun ref authenticate(client: Client ref, authenticator: Authenticator iso): Authenticator iso^ =>
        _h.complete_action("client authenticate")

        recover
            let a: Authenticator ref = consume authenticator
            match a
            | let b: PasswordAuthenticator ref => b("cassandra", "cassandra")
            end
            a
        end

    fun ref authenticated(client: Client) =>
        _h.complete_action("client authenticated")

    fun ref closed(client: Client) =>
        _h.complete_action("client closed")

    fun ref connecting(client: Client, count: U32) =>
        _h.complete_action("client connecting")

    fun ref connected(client: Client) =>
        _h.complete_action("client connected")

    fun ref received(client: Client ref, message: Message val) =>
        _h.complete_action("client received")
        match message
        | let m: AuthSuccessResponse val => client.close()
        end

class _TestClientNotifyAuthenticateFailed is (UnitTest & ClientNotify)

    var _client: (Client ref | None val) = None

    fun name(): String => "ClientNotify.authenticate_failed"

    fun ref apply(h: TestHelper) ? =>
        h.expect_action("server listening")
        h.expect_action("client connecting")
        h.expect_action("server accepted")
        h.expect_action("client authenticate")
        h.expect_action("client authenticate failed")
        h.expect_action("client received")
        h.expect_action("client closed")
        
        let auth = h.env.root as AmbientAuth
        let logger = StringLogger(Fine, h.env.out)
        let authenticator: PasswordAuthenticator = PasswordAuthenticator
        authenticator("cassandra", "cassandra")
        let server = Server(auth, _TestClientNotifyAuthenticateFailedServerNotify(h), consume authenticator, "", "0", logger)
        
        h.dispose_when_done(server)
        h.long_test(20_000_000)


class _TestClientNotifyAuthenticateFailedServerNotify is ServerNotify

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
                _TestClientNotifyAuthenticateFailedClientNotify(_h),
                host,
                port,
                logger
            )
            _h.dispose_when_done(client)
            _h.complete_action("server listening")
        end

    fun ref not_listening(server: Server) =>
        _h.fail_action("server listening")

class _TestClientNotifyAuthenticateFailedClientNotify is ClientNotify
    
    let _h: TestHelper
    
    new iso create(h: TestHelper) =>
        _h = h

    fun ref authenticate(client: Client ref, authenticator: Authenticator iso): Authenticator iso^ =>
        _h.complete_action("client authenticate")

        recover
            let a: Authenticator ref = consume authenticator
            match a
            | let b: PasswordAuthenticator ref => b("wrong username", "wrong password")
            end
            a
        end

    fun ref authenticated(client: Client) =>
        _h.fail_action("client authenticate failed")

    fun ref authenticate_failed(client: Client) =>
        _h.complete_action("client authenticate failed")

    fun ref closed(client: Client) =>
        _h.complete_action("client closed")

    fun ref connecting(client: Client, count: U32) =>
        _h.complete_action("client connecting")

    fun ref received(client: Client ref, message: Message val) =>
        _h.complete_action("client received")
        match message
        | let m: ErrorResponse val => client.close()
        end

// class _TestClientNotifyClosed is UnitTest

// class _TestClientNotifyConnectFailed is UnitTest

// class _TestClientNotifyThrottled is UnitTest

// class _TestClientNotifyUnthrottled is UnitTest
