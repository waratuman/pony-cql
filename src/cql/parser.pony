use collections = "collections"

class Parser

    var _offset: USize = 0
    let data: Array[U8 val] box

    new create(data': Array[U8 val] box) =>
        data = data'

    fun ref shift(): U8 val ? =>
        data(_offset = _offset + 1)
    
    fun ref shiftN(length: USize): Array[U8 val] val ? =>
        if ((_offset + length) > data.size()) then
            error
        end

        let start = _offset
        let finish = _offset + length
        
        recover
            let result = Array[U8 val]()
            while _offset < finish do
                result.push(shift())
            end
            result
         end

    fun ref apply(): Frame val ? =>
        parseFrame()

    fun ref parseFrame(): Frame val ? =>
        let version: U8 val = shift() and 0b0111
        let flags: U8 val = shift()
        let stream: U16 val = parseShort()

        let opcode = shift()
        let length: I32 val = parseInt()

        let body: (Request | Response) = match opcode
        | 0x00 => parseErrorResponse()
        | 0x01 => parseStartupRequest()
        | 0x02 => parseReadyResponse()
        | 0x03 => parseAuthenticateResponse()
        | 0x05 => parseOptionsRequest()
        | 0x0F => parseAuthResponseRequest()
        else error
        end

        Frame(version, flags, stream, body)

    fun ref parseErrorResponse(): ErrorResponse val ? =>
        ErrorResponse(parseInt(), parseString())

    fun ref parseStartupRequest(): StartupRequest val ? =>
        let map = parseStringMap()

        if map.contains("COMPRESSION") then
            StartupRequest(map("CQL_VERSION"), map("COMPRESSION"))
        else
            StartupRequest(map("CQL_VERSION"))
        end

    fun ref parseAuthResponseRequest(): AuthResponseRequest val ? =>
        let token = parseBytes()
        AuthResponseRequest(token)
    
    fun ref parseOptionsRequest(): OptionsRequest val =>
        OptionsRequest()
    
    fun ref parseReadyResponse(): ReadyResponse val =>
        ReadyResponse()

    fun ref parseAuthenticateResponse(): AuthenticateResponse val ? =>
        let authenticator_name: String = parseString()
        AuthenticateResponse(authenticator_name)

    fun ref parseAuthSuccessResponse(): AuthSuccessResponse val ? =>
        let token = parseBytes()
        AuthSuccessResponse(token)

    fun ref parseString(): String val ? =>
        let length = parseShort().usize()
        String.from_array(shiftN(length))

    fun ref parseShort(): U16 val ? =>
        let a = shift().u16()
        let b = shift().u16()
        ((a << 8) or b)

    fun ref parseInt(): I32 val ? =>
        let a = shift().i32()
        let b = shift().i32()
        let c = shift().i32()
        let d = shift().i32()
        (a << 24) or (b << 16) or (c << 8) or d

    fun ref parseStringMap(): collections.Map[String val, String val] val ? =>
        recover
            let pairs = parseShort()
            let result = collections.Map[String val, String val](pairs.usize())
            var i: U16 = 0
            while i < pairs do
                let key = parseString()
                let value = parseString()
                result.insert(key, value)
                i = i + 1
            end
            result
        end

    fun ref parseBytes(): (Array[U8 val] val | None) ? =>
        let length = parseInt()
        if (length < 0) then
            None
        else
            shiftN(length.usize())
        end
