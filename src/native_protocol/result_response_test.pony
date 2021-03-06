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
        let columns: Array[(String val, String val, String val, U16 val)] iso = recover iso
            [("keyspace", "table", "column", 0x0009)]
        end
        let rows: Array[Array[cql.Type val] val ] iso = recover iso
            [[ as cql.Type: None ]]
        end
        let response = RowsResultResponse(consume columns, consume rows)
        h.assert_eq[String val]("ROW RESULTS", response.string())

