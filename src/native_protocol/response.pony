use "format"

type Response is
    ( ErrorResponse
    | ReadyResponse
    | AuthenticateResponse
    | SupportedResponse
    | ResultResponse
    | AuthSuccessResponse
)

class val ErrorResponse

    let code: I32 val
    let message: String val

    new val create(code': I32 val, message': String val) =>
        code = code'
        message = message'
    
    fun string(): String val =>
        "ERROR " + Format.int[I32](code, FormatHex, PrefixDefault, 8) + " " + message


class val ReadyResponse

    new val apply() =>
        None

    new val create() =>
        None

    fun string(): String val =>
        "READY"


class val AuthenticateResponse

    let authenticator_name: String val

    new val create(authenticator_name': String val) =>
        authenticator_name = authenticator_name'

    fun string(): String val =>
        "AUTHENTICATE " + authenticator_name


class val SupportedResponse

    let cql_version: Array[String val] val
    let compression: Array[String val] val

    new val create(cql_version': Array[String val] val, compression': Array[String val] val) =>
        cql_version = cql_version'
        compression = compression'

    fun string(): String val =>
        recover
            let output: String ref = String()
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
            output
        end


type ResultResponse is
    ( VoidResultResponse
    // | RowsResultResponse
    // | SetKeyspaceResultResponse
    // | PreparedResultResponse
    // | SchemaChangeResultResponse
    )


class val VoidResultResponse

    new val create() =>
        None

    fun string(): String val =>
        "RESULT: VOID"


// class val RowsResultResponse

//     new val create() =>
//         None
    
//     fun string(): String val =>
//         "RESULT: "


class val AuthSuccessResponse

    let token: (Array[U8 val] val | None)

    new val create(token': (Array[U8 val] val | None) = None) =>
        token = token'
    
    fun string(): String val =>
        "AUTH_SUCCESS"
