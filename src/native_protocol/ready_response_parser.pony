primitive ReadyResponseParser is Parser[ReadyResponse]

    fun box apply(data: Seq[U8 val] ref): ReadyResponse iso^ =>
        recover iso ReadyResponse end
