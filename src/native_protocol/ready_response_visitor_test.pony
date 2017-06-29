use "ponytest"

actor ReadyResponseVisitorTestList is TestList

    new create(env: Env) =>
        PonyTest(env, this)

    new make() =>
        None
    
    fun tag tests(test: PonyTest) =>
        test(ReadyResponseVisitorTest)


class iso ReadyResponseVisitorTest is UnitTest
    
    fun name(): String =>
        "ReadyResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let collector = Array[U8 val]()
        ReadyResponseVisitor(recover iso ReadyResponse end, collector)
        h.assert_eq[USize](0, collector.size())

