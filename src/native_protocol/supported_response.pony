class ref SupportedResponse is Stringable

    let cql_version: Array[String val] ref
    let compression: Array[String val] ref

    new ref create(cql_version': Array[String val] ref, compression': Array[String val] ref) =>
        cql_version = cql_version'
        compression = compression'

    fun box string(): String iso^ =>

        let output: String iso = recover String() end
        output.append("SUPPORTED {")

        if compression.size() > 0 then
            output.append(" \"COMPRESSION\": [\"" + "\", \"".join(compression.values()) + "\"],")
        else
            output.append(" \"COMPRESSION\": [" + "\", \"".join(compression.values()) + "],")
        end
        
        if cql_version.size() > 0 then
            output.append(" \"CQL_VERSION\": [\"" + "\", \"".join(cql_version.values()) + "\"]")
        else
            output.append(" \"CQL_VERSION\": [" + "\", \"".join(cql_version.values()) + "]")
        end
                
        output.append(" }")
        
        consume output
