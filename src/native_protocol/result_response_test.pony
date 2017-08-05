use "ponytest"
use cql = "../cql"


actor ResultResponseTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestVoidResultResponseString)
        test(_TestRowsResultResponseString)


class iso _TestVoidResultResponseString is UnitTest

    fun name(): String val =>
        "VoidResultResponse.string"

    fun tag apply(h: TestHelper) =>
        let response = VoidResultResponse
        h.assert_eq[String val]("VOID RESULT", response.string())


class iso _TestRowsResultResponseString is UnitTest

    fun name(): String val =>
        "RowsResultResponse.string"

    fun tag apply(h: TestHelper) =>
        let rows = recover iso
            [[ as cql.Type: None]]
        end
        let response = RowsResultResponse(consume rows)
        h.assert_eq[String val]("ROW RESULTS", response.string())

