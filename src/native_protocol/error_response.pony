use "format"

class val ErrorResponse is Stringable

    let code: I32 val
    let message: String val

    new val create(code': I32 val, message': String val) =>
        code = code'
        message = message'
    
    fun string(): String iso^ =>
        recover
            let result: String ref = String

            result.append("ERROR ")
            result.append(Format.int[I32](code, FormatHex, PrefixDefault, 8))
            result.append(" ")
            result.append(message)

            result
        end
