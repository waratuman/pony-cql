use "crypto"
use "format"
use "ponytest"
use collection = "collections"

actor RequestTestList is TestList
    
    new create(env: Env) => PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        test(_TestStartupRequestCreate)
        test(_TestStartupRequestDecode)
        test(_TestStartupRequestEncode)
        test(_TestStartupRequestString)
        
        test(_TestAuthResponseRequestCreate)
        test(_TestAuthResponseRequestDecode)
        test(_TestAuthResponseRequestEncode)
        test(_TestAuthResponseRequestString)

        test(_TestOptionsRequestCreate)
        test(_TestOptionsRequestDecode)
        test(_TestOptionsRequestEncode)
        test(_TestOptionsRequestString)

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

class iso _TestStartupRequestDecode is UnitTest
    fun name(): String => "StartupRequest.decode"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = Bytes.from_hex_string("0001000B43514C5F56455253494F4E0005332E302E30")
        var request = StartupRequest.decode(data)

        h.assert_eq[String val]("3.0.0", request.cqlVersion)
        match request.compression
        | let c: None => h.assert_eq[None val](None, c)
        else h.fail()
        end

        data = Bytes.from_hex_string("0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30")
        request = StartupRequest.decode(data)
        h.assert_eq[String val]("3.0.0", request.cqlVersion)
        match request.compression
        | let c: String => h.assert_eq[String val]("snappy", c)
        else h.fail()
        end

class iso _TestStartupRequestEncode is UnitTest
    fun name(): String => "StartupRequest.encode"

    fun tag apply(h: TestHelper) =>
        var request = StartupRequest("3.0.0")
        h.assert_eq[String val](
            "0001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(request.encode())
        )

        request = StartupRequest("3.0.0", "snappy")
        h.assert_eq[String val](
            "0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(request.encode())
        )

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

        request = AuthResponseRequest(recover [as U8: 0xAB, 0xCD] end)
        match request.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end

class iso _TestAuthResponseRequestDecode is UnitTest
    fun name(): String => "AuthResponseRequest.decode"

    fun tag apply(h: TestHelper) ? =>
        var data = Bytes.from_hex_string("FFFFFFFF")
        var request = AuthResponseRequest.decode(data)

        match request.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        data = Bytes.from_hex_string("00000002ABCD")
        request = AuthResponseRequest.decode(data)

        match request.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end

class iso _TestAuthResponseRequestEncode is UnitTest
    fun name(): String => "AuthResponseRequest.encode"

    fun tag apply(h: TestHelper) =>
        var request = AuthResponseRequest()
        h.assert_eq[String val](
            "FFFFFFFF",
            Bytes.to_hex_string(request.encode())
        )

        request = AuthResponseRequest(recover [as U8: 0xAB, 0xCD] end)
        h.assert_eq[String val](
            "00000002ABCD",
            Bytes.to_hex_string(request.encode())
        )

class iso _TestAuthResponseRequestString is UnitTest
    fun name(): String => "AuthResponseRequest.string"
    
    fun tag apply(h: TestHelper) =>
        var request = AuthResponseRequest()
        h.assert_eq[String val](
            "AUTH_RESPONSE",
            request.string()
        )

        request = AuthResponseRequest(recover [as U8: 0xAB, 0xCD] end)
        h.assert_eq[String val](
            "AUTH_RESPONSE",
            request.string()
        )

class iso _TestOptionsRequestCreate is UnitTest
    fun name(): String => "OptionsRequest.create"

    fun tag apply(h: TestHelper) =>
        let request = OptionsRequest.create()

class iso _TestOptionsRequestDecode is UnitTest
    fun name(): String => "OptionsRequest.decode"

    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover Array[U8 val]() end
        var request = OptionsRequest.decode(data)
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(request.encode())
        )

        // Extra data should be ignored
        data = Bytes.from_hex_string("FFFFFFFF")
        request = OptionsRequest.decode(data)
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(request.encode())
        )


class iso _TestOptionsRequestEncode is UnitTest
    fun name(): String => "OptionsRequest.encode"

    fun tag apply(h: TestHelper) =>
        let request = OptionsRequest.create()
        h.assert_eq[String val](
            "",
            Bytes.to_hex_string(request.encode())
        )

class iso _TestOptionsRequestString is UnitTest
    fun name(): String => "OptionsRequest.string"

    fun tag apply(h: TestHelper) =>
        let request = OptionsRequest.create()
        h.assert_eq[String val]("OPTIONS", request.string())

