class iso QueryRequest is Stringable

    let query: String val
    let binding: (Array[QueryParameter val] val | None val)
    let consistency: Consistency val
    let metadata: Bool val
    let page_size: (None val | I32 val)
    let paging_state: (None val | Array[U8 val] val)
    let serial_consistency: (None val | Serial val | LocalSerial val)
    let timestamp: (None val | I64 val)

    new iso create(
        query': String val,
        binding': (Array[QueryParameter val] val | None val) = None,
        consistency': Consistency val = Quorum,
        metadata': Bool val = true,
        page_size': (None val | I32 val) = None,
        paging_state': (None val | Array[U8 val] val) = None,
        serial_consistency': (None val | Serial val | LocalSerial val) = None,
        timestamp': (None val | I64 val) = None
    ) =>
        query = query'
        binding = binding'
        consistency = consistency'
        metadata = metadata'
        page_size = page_size'
        paging_state = paging_state'
        serial_consistency = serial_consistency'
        timestamp = timestamp'

    fun box string(): String iso^ =>
        ("QUERY \"" + query + "\"").string()
