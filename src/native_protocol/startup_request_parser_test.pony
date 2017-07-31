use "ponytest"

actor StartupRequestParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(StartupRequestParserTest)


class iso StartupRequestParserTest is UnitTest

    fun name(): String =>
        "StartupRequestParser.parse"
    
    fun tag apply(h: TestHelper) ? =>
        var data = [as U8:
            0x00; 0x01; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        var request = StartupRequestParser(data)?

        h.assert_eq[String val]("3.0.0", request.cql_version)
        match request.compression
        | let c: None => h.assert_eq[None val](None, c)
        else h.fail()
        end

        data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x06; 0x73; 0x6E; 0x61; 0x70; 0x70
            0x79; 0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53
            0x49; 0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        request = StartupRequestParser(data)?

        h.assert_eq[String val]("3.0.0", request.cql_version)
        match request.compression
        | let c: String => h.assert_eq[String val]("snappy", c)
        else h.fail()
        end
