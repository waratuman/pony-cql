use "ponytest"
use "itertools"

actor OptionsRequestVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(OptionsRequestVisitorTest)


class iso OptionsRequestVisitorTest is UnitTest
    fun name(): String => "OptionsRequestVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let request: OptionsRequest val = OptionsRequest
        let result: Array[U8 val] val = recover OptionsRequestVisitor(request) end
        let data = Array[U8 val]
        for (a, b) in Zip2[U8, U8](data.values(), result.values()) do
            h.assert_eq[U8](a, b)
        end
