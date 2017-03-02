use collection = "collections" 

type Request is (
    StartupRequest
    | AuthResponseRequest
    | OptionsRequest
)

class StartupRequest

    let cqlVersion: String val
    let compression: (String val | None val)

    new create(cqlVersion': String, compression': (String val | None val) = None) =>
        cqlVersion = cqlVersion'
        compression = compression'

    fun string(): String val =>
        recover
            let output: String ref = String()
            output.append("STARTUP {")

            match compression
            | let c: String => output.append(" \"COMPRESSION\": \"" + c + "\",")
            end
            
            output.append(" \"CQL_VERSION\": \"" + cqlVersion + "\"")

            output.append(" }")
            output
        end

class AuthResponseRequest
    
    let token: (Array[U8 val] val | None)

    new create(token': (Array[U8 val] val | None) = None) =>
        token = token'
    
    fun string(): String val =>
        "AUTH_RESPONSE"

class OptionsRequest

    new apply() =>
        None

    new create() =>
        None

    fun string(): String val =>
        "OPTIONS"

// class QueryRequest is Request

//     let query: String val
//     let consistency: Consistency val
//     let metadata: Bool val = true
//     let pageSize: None val | U32 val = None
//     let pagingState None val | Array[U8 val] val
//     let serialConsistency: None val | Serial val | LocalSerial val = None
//     let timestamp: None val | U64 val

//     new create(query: String val) =>
