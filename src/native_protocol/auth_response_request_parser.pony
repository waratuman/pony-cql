primitive AuthResponseRequestParser is Parser[AuthResponseRequest]

    fun box apply(data: Seq[U8 val] ref): AuthResponseRequest iso^ ? =>
        let token = BytesParser(data)?
        recover iso AuthResponseRequest(consume token) end
