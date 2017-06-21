use "ponytest"

actor AuthResponseRequestParserTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(AuthResponseRequestParserTest)


class iso AuthResponseRequestParserTest is UnitTest

    fun name(): String =>
        "AuthResponseRequestParser.parse"
    
    fun tag apply(h: TestHelper) ? =>
        var data: Array[U8 val] val = recover [as U8: 0xFF; 0xFF; 0xFF; 0xFF] end
        var stack = ParserStack(data)
        var request: AuthResponseRequest val = AuthResponseRequestParser(stack).parse()

        match request.token
        | let t: None => h.assert_eq[None val](None, t)
        else h.fail()
        end

        data = recover [as U8: 0x00; 0x00; 0x00; 0x02; 0xAB; 0xCD] end
        stack = ParserStack(data)
        request = AuthResponseRequestParser(stack).parse()

        match request.token
        | let t: Array[U8 val] val =>
            h.assert_eq[U8](0xAB, t(0))
            h.assert_eq[U8](0xCD, t(1))
        else h.fail()
        end
