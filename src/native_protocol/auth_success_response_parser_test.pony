use "ponytest"

actor AuthSuccessResponseParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthSuccessResponseParserTest)


class iso AuthSuccessResponseParserTest is UnitTest

    fun name(): String =>
        "AuthSuccessResponseParser.parse"
    
    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover [as U8:
            0xFF; 0xFF; 0xFF; 0xFF
        ] end
        var stack = Stack(data)
        var response: AuthSuccessResponse val = AuthSuccessResponseParser(stack).parse()
        match response.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        data = recover [as U8:
            0x00; 0x00; 0x00; 0x02; 0xAB; 0xCD
        ] end
        stack = Stack(data)
        response = AuthSuccessResponseParser(stack).parse()

        match response.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end
