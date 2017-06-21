use cql = "../cql"

type Request is
    ( StartupRequest
    | AuthResponseRequest
    | OptionsRequest
    | QueryRequest
    )

type QueryParameter is cql.Type
