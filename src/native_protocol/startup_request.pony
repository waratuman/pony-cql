class ref StartupRequest is Stringable

    let cql_version: String val
    let compression: (String val | None val)

    new ref create(cql_version': String, compression': (String val | None val) = None) =>
        cql_version = cql_version'
        compression = compression'

    fun box string(): String iso^ =>
        let output: String iso = recover String() end
        output.append("STARTUP {")

        match compression
        | let c: String => output.append(" \"COMPRESSION\": \"" + c + "\",")
        end
        
        output.append(" \"CQL_VERSION\": \"" + cql_version + "\"")

        output.append(" }")

        consume output
