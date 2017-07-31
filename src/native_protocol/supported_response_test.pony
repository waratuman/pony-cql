use "ponytest"

actor SupportedResponseTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestSupportedResponseCreate)
        test(_TestSupportedResponseString)


class iso _TestSupportedResponseCreate is UnitTest

    fun name(): String =>
        "SupportedResponse.create"
    
    fun tag apply(h: TestHelper) ? =>
        var response = SupportedResponse(recover ["3.0.1"] end, recover ["lzo"] end)
        h.assert_eq[String val]("3.0.1", response.cql_version(0)?)
        h.assert_eq[String val]("lzo", response.compression(0)?)


class iso _TestSupportedResponseString is UnitTest

    fun name(): String =>
        "SupportedResponse.string"
    
    fun tag apply(h: TestHelper) =>
        let response = SupportedResponse(recover ["3.0.0"] end, recover ["lzo"; "gzip"] end)
        h.assert_eq[String val](
            "SUPPORTED { \"COMPRESSION\": [\"lzo\", \"gzip\"], \"CQL_VERSION\": [\"3.0.0\"] }",
            response.string()
        )
