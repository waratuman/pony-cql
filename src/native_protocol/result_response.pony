type ResultResponse is
    ( VoidResultResponse
    // | RowsResultResponse
    // | SetKeyspaceResultResponse
    // | PreparedResultResponse
    // | SchemaChangeResultResponse
    )


class iso VoidResultResponse is Stringable

    new iso create() =>
        None

    fun box string(): String iso^ =>
        "RESULT: VOID".string()
