use cql = "../cql"
use "itertools"
use "ponytest"


actor ResultResponseVisitorTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestResultResponseVisitor)
        test(_TestVoidResultResponseVisitor)
        test(_TestRowsResultResponseVisitor)


class iso _TestResultResponseVisitor is UnitTest

    fun name(): String val =>
        "ResultResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        var r: ResultResponse val = VoidResultResponse
        var actual = ResultResponseVisitor(r)
        var expected = [ as U8: 0; 0; 0; 1 ]

        for (a, b) in Iter[U8 val](expected.values()).zip[U8 val](actual.values()) do
            h.assert_eq[U8](a, b)
        end
        h.assert_eq[USize](expected.size(), actual.size())

        let rows: Array[Array[cql.Type val]] iso = recover
            [ [ as cql.Type: None ] ]
        end
        r = RowsResultResponse(consume rows)
        actual = ResultResponseVisitor(r)
        expected = [ as U8: 0 ]
        for (a, b) in Iter[U8 val](expected.values()).zip[U8 val](actual.values()) do
            h.assert_eq[U8](a, b)
        end
        h.assert_eq[USize](expected.size(), actual.size())
        
        
        // | let r: SetKeyspaceResultResponse val =>
        // | let r: PreparedResultResponse val =>
        // | let r: SchemaChangeResultResponse val =>
        h.fail()


class iso _TestVoidResultResponseVisitor is UnitTest

    fun name(): String val =>
        "VoidResultResponseVisitor.apply"

    fun tag apply(h: TestHelper) =>
        let collector = VoidResultResponseVisitor(VoidResultResponse)
        h.assert_eq[USize](0, collector.size())


class iso _TestRowsResultResponseVisitor is UnitTest

    fun name(): String val =>
        "RowResultResponseVisitor.apply"
    
    fun tag apply(h: TestHelper) =>
        let data = [as U8: 0]
        h.fail()