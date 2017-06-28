class OptionsRequestParser is Parser[OptionsRequest]

    fun box apply(data: Seq[U8 val] ref): OptionsRequest iso^ =>
        OptionsRequest
