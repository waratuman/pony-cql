use collections = "collections"

primitive SupportedResponseParser is Parser[SupportedResponse]

    fun box apply(data: Seq[U8 val] ref): SupportedResponse iso^ ? =>
        let isomap: collections.Map[String val, Array[String val] ref] iso = StringMultiMapParser(data)

        recover iso
            let map: collections.Map[String val, Array[String val] ref] ref = consume isomap

            let compression: Array[String val] ref = if map.contains("COMPRESSION") then
                map("COMPRESSION")
            else
                Array[String val]
            end

            let cql_version: Array[String val] ref = if map.contains("CQL_VERSION") then
                map("CQL_VERSION")
            else
                Array[String val]
            end

            SupportedResponse(cql_version, compression)
        end
