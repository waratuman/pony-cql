use "ponytest"


actor StartupRequestVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(StartupRequestVisitorTest)


class iso StartupRequestVisitorTest is UnitTest

    fun name(): String =>
        "StartupRequestVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var request: StartupRequest val = recover StartupRequest("3.0.0") end
        var result: Array[U8 val] val = recover StartupRequestVisitor(request) end
        
        h.assert_eq[String val](
            "0001000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(result)
        )

        request = recover StartupRequest("3.0.0", "snappy") end
        result = recover StartupRequestVisitor(request) end
        h.assert_eq[String val](
            "0002000B434F4D5052455353494F4E0006736E61707079000B43514C5F56455253494F4E0005332E302E30",
            Bytes.to_hex_string(result)
        )
