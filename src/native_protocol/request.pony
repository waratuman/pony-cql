use cql = "../cql"
use collection = "collections" 

type Request is
    ( StartupRequest
    | AuthResponseRequest
    | OptionsRequest
    | QueryRequest
    )

class val StartupRequest

    let cqlVersion: String val
    let compression: (String val | None val)

    new val create(cqlVersion': String, compression': (String val | None val) = None) =>
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


class val AuthResponseRequest
    
    let token: (Array[U8 val] val | None val)

    new val create(token': (Array[U8 val] val | None val) = None) =>
        token = token'
    
    fun string(): String val =>
        "AUTH_RESPONSE"

class val OptionsRequest

    new val apply() =>
        None

    new val create() =>
        None

    fun string(): String val =>
        "OPTIONS"

type QueryParameter is cql.Type

class val QueryRequest

    let query: String val
    let query_parameters: (Array[QueryParameter val] val | None val)
    let consistency: Consistency val
    let metadata: Bool val
    let page_size: (None val | I32 val)
    let paging_state: (None val | Array[U8 val] val)
    let serial_consistency: (None val | Serial val | LocalSerial val)
    let timestamp: (None val | I64 val)

    new val create(
        query': String val,
        query_parameters': (Array[QueryParameter val] val | None val) = None,
        consistency': Consistency val = Quorum,
        metadata': Bool val = true,
        page_size': (None val | I32 val) = None,
        paging_state': (None val | Array[U8 val] val) = None,
        serial_consistency': (None val | Serial val | LocalSerial val) = None,
        timestamp': (None val | I64 val) = None
    ) =>
        query = query'
        query_parameters = query_parameters'
        consistency = consistency'
        metadata = metadata'
        page_size = page_size'
        paging_state = paging_state'
        serial_consistency = serial_consistency'
        timestamp = timestamp'

    fun string(): String val =>
        "QUERY \"" + query + "\""
