// use collections = "collections"
use cql = "../cql"


class ResultResponseParser is Parser[ResultResponse]

    fun box apply(data: Seq[U8 val] ref): ResultResponse iso^ ? =>
        match IntParser(data)?
        | 0x0001 => VoidResultResponseParser(data)
        | 0x0002 => RowsResultResponseParser(data)?
        // | 0x0003 => SetKeyspaceResultResponseParser(data)?
        // | 0x0004 => PreparedResultResponseParser(data)?
        // | 0x0005 => SchemaChangeResultResponseParser(data)?
        else error end


class VoidResultResponseParser is Parser[VoidResultResponse]

    fun box apply(data: Seq[U8 val] ref): VoidResultResponse iso^ =>
        VoidResultResponse


class RowsResultResponseParser is Parser[RowsResultResponse]

    fun box apply(data: Seq[U8 val] ref): RowsResultResponse iso^ ? =>
        let flags = IntParser(data)?
        let columns_count = IntParser(data)?.usize()
        
        var keyspace: (String val | None) = None
        var table_name: (String val | None) = None

        if (flags and 0x0001) == 0x0001 then
            keyspace = StringParser(data)?
            table_name = StringParser(data)?
        end

        let paging_state = if (flags and 0x0002) == 0x0002 then
            BytesParser(data)?
        else
            None
        end

        let metadata = if (flags and 0x0004) == 0x0004 then
            false
        else
            true
        end

        let column_types = recover iso Array[(String val, String val, String val, U16 val)] end
        var i: USize val = 0
        if metadata then            
            while i < columns_count do
                (let ks: String val, let tn: String val) = if keyspace is None then
                    (StringParser(data)?, StringParser(data)?)
                else
                    (keyspace as String val, table_name as String val)
                end

                
                let cn: String val = StringParser(data)?
                (let t: U16 val, let value: (Array[U8 val] ref | None)) = OptionParser(data)?
                
                column_types.push((ks, tn, cn, t))
                i = i + 1
            end
        else
            None
        end

        let rows_count = IntParser(data)?.usize()

        let rows_content: Array[Array[cql.Type val] val] iso = recover
            Array[Array[cql.Type val] val](rows_count)
        end

        i = 0

        while i < rows_count do
            let content = recover Array[cql.Type val](columns_count) end
            
            var j: USize val = 0
            while j < columns_count do
                content.push(
                    _parse_row_column_content(
                        column_types(j)?._4,
                        BytesParser(data)?
                    )?
                )
                j = j + 1
            end

            rows_content.push(consume content)
            i = i - 1
        end

        RowsResultResponse(consume column_types, consume rows_content)



    fun box _parse_row_column_content(type': U16, data': (Seq[U8 val] ref | None)): cql.Type ? =>
        match data'
        | None => None
        | let data: Seq[U8 val] ref =>
            match type'
            | 0x0000 => error
            | 0x0001 => cql.ASCIIParser(data)?
            | 0x0002 => cql.BigIntParser(data)?
            | 0x0004 => cql.BooleanParser(data)?
            | 0x000D => cql.VarCharParser(data)
            | 0x0013 => cql.SmallIntParser(data)?
            else error end
        end

        //     0x0003    Blob
        //     0x0005    Counter
        //     0x0006    Decimal
        //     0x0007    Double
        //     0x0008    Float
        //     0x0009    Int
        //     0x000B    Timestamp
        //     0x000C    Uuid
        //     0x000D    Varchar
        //     0x000E    Varint
        //     0x000F    Timeuuid
        //     0x0010    Inet
        //     0x0011    Date
        //     0x0012    Time
        //     0x0014    Tinyint
        //     0x0020    List: the value is an [option], representing the type
        //                     of the elements of the list.
        //     0x0021    Map: the value is two [option], representing the types of the
        //                    keys and values of the map
        //     0x0022    Set: the value is an [option], representing the type
        //                     of the elements of the set
        //     0x0030    UDT: the value is <ks><udt_name><n><name_1><type_1>...<name_n><type_n>
        //                    where:
        //                       - <ks> is a [string] representing the keyspace name this
        //                         UDT is part of.
        //                       - <udt_name> is a [string] representing the UDT name.
        //                       - <n> is a [short] representing the number of fields of
        //                         the UDT, and thus the number of <name_i><type_i> pairs
        //                         following
        //                       - <name_i> is a [string] representing the name of the
        //                         i_th field of the UDT.
        //                       - <type_i> is an [option] representing the type of the
        //                         i_th field of the UDT.
        //     0x0031    Tuple: the value is <n><type_1>...<type_n> where <n> is a [short]
        //                      representing the number of values in the type, and <type_i>
        //                      are [option] representing the type of the i_th component
        //                      of the tuple

