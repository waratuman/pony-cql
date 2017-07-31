use "ponytest"

actor FrameParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(FrameParserTest)


class iso FrameParserTest is UnitTest

    fun name(): String =>
        "FrameParser.apply"
    
    fun tag apply(h: TestHelper) ? =>
        var data = [as U8:
            0x04; 0x00; 0x00; 0x00; 0x01; 0x00; 0x00; 0x00; 0x16; 0x00; 0x01
            0x00; 0x0B; 0x43; 0x51; 0x4C; 0x5F; 0x56; 0x45; 0x52; 0x53; 0x49
            0x4F; 0x4E; 0x00; 0x05; 0x33; 0x2E; 0x30; 0x2E; 0x30
        ]
        var frame = FrameParser(data)?

        h.assert_eq[U8](4, frame.version)
        h.assert_eq[U8](0, frame.flags)
        h.assert_eq[U16](0, frame.stream)
        
        match frame.body
        | let b: StartupRequest val => h.assert_eq[String]("3.0.0", b.cql_version)
        else h.fail()
        end

        data = [as U8:
            0x04; 0x00; 0x00; 0x01; 0x0F; 0x00; 0x00; 0x00; 0x04; 0xFF; 0xFF
            0xFF; 0xFF
        ]
        frame = FrameParser(data)?
        
        h.assert_eq[U8](4, frame.version)
        h.assert_eq[U8](0, frame.flags)
        h.assert_eq[U16](1, frame.stream)
        match frame.body
        | let b: AuthResponseRequest val => None
        else h.fail()
        end
