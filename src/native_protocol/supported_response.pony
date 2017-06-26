class iso SupportedResponse is Stringable

    let cql_version: Array[String val] val
    let compression: Array[String val] val

    new iso create(cql_version': Array[String val] val, compression': Array[String val] val) =>
        cql_version = cql_version'
        compression = compression'

    fun box string(): String iso^ =>

        let output: String iso = recover String() end
        output.append("SUPPORTED {")

        if compression.size() > 0 then
            output.append(" \"COMPRESSION\": [\"" + "\", \"".join(compression) + "\"],")
        else
            output.append(" \"COMPRESSION\": [" + "\", \"".join(compression) + "],")
        end
        
        if cql_version.size() > 0 then
            output.append(" \"CQL_VERSION\": [\"" + "\", \"".join(cql_version) + "\"]")
        else
            output.append(" \"CQL_VERSION\": [" + "\", \"".join(cql_version) + "]")
        end
                
        output.append(" }")
        
        consume output
