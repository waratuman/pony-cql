use "ponytest"

actor SupportedResponseParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(SupportedResponseParserTest)


class iso SupportedResponseParserTest is UnitTest

    fun name(): String =>
        "SupportedResponseParser.parse"
    
    fun tag apply(h: TestHelper) ? =>
        let data = [as U8:
            0x00; 0x02; 0x00; 0x0B; 0x43; 0x4F; 0x4D; 0x50; 0x52; 0x45; 0x53
            0x53; 0x49; 0x4F; 0x4E; 0x00; 0x02; 0x00; 0x06; 0x73; 0x6E; 0x61
            0x70; 0x70; 0x79; 0x00; 0x03; 0x6C; 0x7A; 0x6F; 0x00; 0x0B; 0x43
            0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49; 0x4F; 0x4E; 0x00
            0x01; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        let response: SupportedResponse ref = SupportedResponseParser(data)?
        h.assert_eq[String val]("3.0.0", response.cql_version(0)?)
        h.assert_eq[String val]("snappy", response.compression(0)?)
        h.assert_eq[String val]("lzo", response.compression(1)?)