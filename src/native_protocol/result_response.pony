use cql = "../cql"

type ResultResponse is
    ( VoidResultResponse
    | RowsResultResponse
    // | SetKeyspaceResultResponse
    // | PreparedResultResponse
    // | SchemaChangeResultResponse
    )




class iso VoidResultResponse is Stringable

    new iso create() =>
        None

    fun box string(): String iso^ =>
        "VOID RESULT".string()


class iso RowsResultResponse is Stringable

    let rows: Array[Array[cql.Type val] val] ref
    let columns: Array[(String val, String val, String val, U16 val)] ref
    let paging_state: (Array[U8 val] iso | None)

    new iso create(
        columns': Array[(String val, String val, String val, U16 val)] iso,
        rows': Array[Array[cql.Type val] val] iso
        )
    =>
        rows = consume rows'
        columns = consume columns'
        paging_state = None
    
    fun box string(): String iso^ =>
        let result = recover iso String end
        result.append("ROW RESULTS\n")

        for row in rows.values() do
            for column in row.values() do
                match column
                | let x: Stringable => result.append(x.string())
                else result.append("unsupported")
                end

                result.append(" | ")
            end
            result.append("\n")
        end
        
        result
