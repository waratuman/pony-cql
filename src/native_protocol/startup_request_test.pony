use "ponytest"

actor StartupRequestTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestStartupRequestCreate)
        test(_TestStartupRequestString)


class iso _TestStartupRequestCreate is UnitTest

    fun name(): String =>
        "StartupRequest.create"

    fun tag apply(h: TestHelper) =>
        var request = StartupRequest("3.0.0")
        h.assert_eq[String val]("3.0.0", request.cql_version)
        match request.compression
        | let c: None => h.assert_eq[None val](None, c)
        else h.fail()
        end

        request = StartupRequest("3.0.1", "lz4")
        h.assert_eq[String val]("3.0.1", request.cql_version)
        match request.compression
        | let c: String val => h.assert_eq[String val]("lz4", c)
        else h.fail()
        end

        request = StartupRequest("3.0.1", "snappy")
        h.assert_eq[String val]("3.0.1", request.cql_version)
        match request.compression
        | let c: String val => h.assert_eq[String val]("snappy", c)
        else h.fail()
        end


class iso _TestStartupRequestString is UnitTest

    fun name(): String =>
        "StartupRequest.string"

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
