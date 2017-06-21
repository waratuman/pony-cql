type ResultResponse is
    ( VoidResultResponse
    // | RowsResultResponse
    // | SetKeyspaceResultResponse
    // | PreparedResultResponse
    // | SchemaChangeResultResponse
    )


class val VoidResultResponse is Stringable

    new val create() =>
        None

    fun string(): String iso^ =>
        "RESULT: VOID".string()
