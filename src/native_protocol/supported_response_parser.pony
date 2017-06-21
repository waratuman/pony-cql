class SupportedResponseParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): SupportedResponse val ? =>
        let map = stack.string_multimap()

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
