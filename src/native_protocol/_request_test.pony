use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor RequestTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestStartupRequestCreate)
        test(_TestStartupRequestString)

        test(_TestAuthResponseRequestCreate)
        test(_TestAuthResponseRequestString)

        test(_TestOptionsRequestCreate)
        test(_TestOptionsRequestString)

        test(_TestQueryRequestCreate)
        test(_TestQueryRequestString)

class iso _TestStartupRequestCreate is UnitTest
    fun name(): String => "StartupRequest.create"

    fun tag apply(h: TestHelper) =>
        var request = StartupRequest("3.0.0")
        h.assert_eq[String val]("3.0.0", request.cqlVersion)
        match request.compression
        | let c: None => h.assert_eq[None val](None, c)
        else h.fail()
        end

        request = StartupRequest("3.0.1", "lz4")
        h.assert_eq[String val]("3.0.1", request.cqlVersion)
        match request.compression
        | let c: String val => h.assert_eq[String val]("lz4", c)
        else h.fail()
        end

        request = StartupRequest("3.0.1", "snappy")
        h.assert_eq[String val]("3.0.1", request.cqlVersion)
        match request.compression
        | let c: String val => h.assert_eq[String val]("snappy", c)
        else h.fail()
        end

class iso _TestStartupRequestString is UnitTest
    fun name(): String => "StartupRequest.string"

    fun tag apply(h: TestHelper) =>
        var request = StartupRequest("3.0.0")
        h.assert_eq[String val](
            "STARTUP { \"CQL_VERSION\": \"3.0.0\" }",
            request.string()
        )

        request = StartupRequest("3.0.1", "lz4")
        h.assert_eq[String val](
            "STARTUP { \"COMPRESSION\": \"lz4\", \"CQL_VERSION\": \"3.0.1\" }",
            request.string()
        )

class iso _TestAuthResponseRequestCreate is UnitTest
    fun name(): String => "AuthResponseRequest.create"
    
    fun tag apply(h: TestHelper) ? =>
        var request = AuthResponseRequest()
        match request.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        request = AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end)
        match request.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end


class iso _TestAuthResponseRequestString is UnitTest
    fun name(): String => "AuthResponseRequest.string"
    
    fun tag apply(h: TestHelper) =>
        var request = AuthResponseRequest()
        h.assert_eq[String val](
            "AUTH_RESPONSE",
            request.string()
        )

        request = AuthResponseRequest(recover [as U8: 0xAB; 0xCD] end)
        h.assert_eq[String val](
            "AUTH_RESPONSE",
            request.string()
        )


class iso _TestOptionsRequestCreate is UnitTest
    fun name(): String => "OptionsRequest.create"

    fun tag apply(h: TestHelper) =>
        let request = OptionsRequest.create()


class iso _TestOptionsRequestString is UnitTest
    fun name(): String => "OptionsRequest.string"

    fun tag apply(h: TestHelper) =>
        let request = OptionsRequest.create()
        h.assert_eq[String val]("OPTIONS", request.string())


class iso _TestQueryRequestCreate is UnitTest

    fun name(): String val =>
        "QueryRequest.create"

    fun tag apply(h: TestHelper) =>
        None


class iso _TestQueryRequestString is UnitTest

    fun name(): String val =>
        "QueryRequest.string"

    fun tag apply(h: TestHelper) =>
        let request = QueryRequest.create("SELECT * FROM example;")
        h.assert_eq[String val]("QUERY \"SELECT * FROM example;\"", request.string())
