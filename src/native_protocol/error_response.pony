use "format"

class iso ErrorResponse is Stringable

    let code: I32 val
    let message: String val

    new iso create(code': I32 val, message': String val) =>
        code = code'
        message = message'
    
    fun box string(): String iso^ =>
        recover
            let result: String ref = String

            result.append("ERROR ")
            result.append(Format.int[I32](code, FormatHex, PrefixDefault, 8))
            result.append(" ")
            result.append(message)

            result
        end
