class OptionsRequestParser is NewParser[OptionsRequest]

    fun box apply(data: Seq[U8 val] ref): OptionsRequest iso^ =>
        OptionsRequest
