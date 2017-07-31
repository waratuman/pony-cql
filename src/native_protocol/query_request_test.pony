use "ponytest"

actor QueryRequestTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() =>
        None

    fun tag tests(test: PonyTest) =>
        test(_TestQueryRequestCreate)
        test(_TestQueryRequestString)


class iso _TestQueryRequestCreate is UnitTest

    fun name(): String val =>
        "QueryRequest.create"

    fun tag apply(h: TestHelper) ? =>
        let query = "SELECT * FROM example WHERE visible = ?"
        let binding: Array[QueryParameter val] val = recover [as QueryParameter val: true] end
        let request = QueryRequest(query
            , binding
            , Three
            , false
            , 10
            , recover [as U8: 1] end
            , LocalSerial
            , 0
            )

        h.assert_eq[String val](query, request.query as String)
        h.assert_eq[Bool val](true, (request.binding as Array[QueryParameter val] val)(0)? as Bool)
        h.assert_eq[Consistency val](Three, request.consistency)
        h.assert_eq[Bool val](false, request.metadata as Bool val)
        h.assert_eq[I32 val](10, request.page_size as I32 val)
        h.assert_eq[U8 val](1, (request.paging_state as Array[U8 val] val)(0)?)
        h.assert_eq[Consistency val](LocalSerial, request.serial_consistency as Consistency val)
        h.assert_eq[I64 val](0, request.timestamp as I64)


class iso _TestQueryRequestString is UnitTest

    fun name(): String val =>
        "QueryRequest.string"

    fun tag apply(h: TestHelper) =>
        let request = QueryRequest.create("SELECT * FROM example;")
        h.assert_eq[String val]("QUERY \"SELECT * FROM example;\"", request.string())
