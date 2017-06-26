class SupportedResponseParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): SupportedResponse iso^ ? =>
        let map = stack.take_string_multimap()

        let compression: Array[String val] val = if map.contains("COMPRESSION") then
            map("COMPRESSION")
        else
             recover Array[String val] end
        end

        let cql_version: Array[String val] val = if map.contains("CQL_VERSION") then
            map("CQL_VERSION")
        else
             recover Array[String val] end
        end

        SupportedResponse(cql_version, compression)
