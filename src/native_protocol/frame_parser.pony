primitive FrameParser is Parser[Frame]

    fun box apply(data: Seq[U8 val] ref): Frame iso^ ? =>
        let version: U8 val = (ByteParser(data)? and 0b0111)
        let flags: U8 val = ByteParser(data)?
        let stream: U16 val = ShortParser(data)?
        let opcode: U8 val = ByteParser(data)?
        let length: I32 val = IntParser(data)?

        let message: Message iso = match opcode
        | 0x00 => ErrorResponseParser(data)?
        | 0x01 => StartupRequestParser(data)?
        | 0x02 => ReadyResponseParser(data)
        | 0x03 => AuthenticateResponseParser(data)?
        | 0x05 => OptionsRequestParser(data)
        | 0x06 => SupportedResponseParser(data)?
        | 0x07 => QueryRequestParser(data)?
        // | 0x08 => ResultResponseParser(data)
        // | 0x09 => PrepareRequestParser(data)
        // | 0x0A => ExecuteRequestParser(data)
        // | 0x0B => RegisterRequestParser(data)
        // | 0x0C => EventResponseParser(data)
        // | 0x0D => BatchRequestParser(data)
        // | 0x0E => AuthChallengeResponseParser(data)
        | 0x0F => AuthResponseRequestParser(data)?
        | 0x10 => AuthSuccessResponseParser(data)?
        else error
        end

        Frame(version, flags, stream, consume message)
