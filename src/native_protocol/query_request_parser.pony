class QueryRequestParser is Parser

    let stack: ParserStack ref

    new create(stack': ParserStack ref) =>
        stack = stack'

    fun ref parse(): QueryRequest val ? =>
        let query_string: String val = stack.long_string()
        let consistency: Consistency val = stack.consistency()

        let flag = stack.byte()
        let flags: QueryFlags ref = QueryFlags


        if (flag and Values.value()) == Values.value() then
            flags.set(Values)
        end

        if (flag and SkipMetadata.value()) == SkipMetadata.value() then
            flags.set(SkipMetadata)
        end

        if (flag and PageSize.value()) == PageSize.value() then
            flags.set(PageSize)
        end

        if (flag and WithPagingState.value()) == WithPagingState.value() then
            flags.set(WithPagingState)
        end

        if (flag and WithSerialConsistency.value()) == WithSerialConsistency.value() then
            flags.set(WithSerialConsistency)
        end

        if (flag and WithDefaultTimestamp.value()) == WithDefaultTimestamp.value() then 
            flags.set(WithDefaultTimestamp)
        end

        if (flag and WithNamesForValues.value()) == WithNamesForValues.value() then
            flags.set(WithNamesForValues)
        end

        let binding: (Array[QueryParameter val] val | None val) = if flags(Values) then
            let n: U16 val = stack.short()
            var i: U16 val = 0
            let result: Array[QueryParameter val] iso = recover Array[QueryParameter val] end
            while i < n do
                let value_size = stack.int()
                result.push(if value_size < 0 then
                    None
                else
                    stack.shiftN(value_size.usize())
                end)
                i = i + 1
            end
            consume result
        else
            None
        end

        let page_size: (None val | I32 val) = if flags(PageSize) then
            stack.int()
        else
            None
        end

        let paging_state: (None val | Array[U8 val] val) = if flags(WithPagingState) then
            stack.bytes()
        else
            None
        end

        let serial_consistency: (None val | Serial val | LocalSerial val) = if flags(WithSerialConsistency) then
            stack.consistency() as (Serial val | LocalSerial val)
        else
            None
        end

        let timestamp: (None val | I64 val) = if flags(WithDefaultTimestamp) then
            stack.long()
        else
            None
        end

        // let query_parameters: Array[QueryParameter val] val
        QueryRequest(query_string, binding, consistency, not flags(SkipMetadata), page_size, paging_state, serial_consistency, timestamp)

