class FrameParser is Parser

    let stack: Stack ref

    new create(stack': Stack ref) =>
        stack = stack'

    fun ref parse(): Frame iso^ ? =>
        let version: U8 val = (stack.byte() and 0b0111)
        let flags: U8 val = stack.byte()
        let stream: U16 val = stack.take_short()
        let opcode: U8 val = stack.byte()
        let length: I32 val = stack.take_int()

        let message: Message val = match opcode
        | 0x00 => ErrorResponseParser.create(stack).parse()
        | 0x01 => StartupRequestParser.create(stack).parse()
        | 0x02 => ReadyResponseParser.create(stack).parse()
        | 0x03 => AuthenticateResponseParser.create(stack).parse()
        | 0x05 => OptionsRequestParser.create(stack).parse()
        | 0x06 => SupportedResponseParser.create(stack).parse()
        | 0x07 => QueryRequestParser.create(stack).parse()
        // | 0x08 => ResultResponseParser.create(stack).parse()
        // | 0x09 => PrepareRequestParser.create(stack).parse()
        // | 0x0A => ExecuteRequestParser.create(stack).parse()
        // | 0x0B => RegisterRequestParser.create(stack).parse()
        // | 0x0C => EventResponseParser.create(stack).parse()
        // | 0x0D => BatchRequestParser.create(stack).parse()
        // | 0x0E => AuthChallengeResponseParser.create(stack).parse()
        | 0x0F => AuthResponseRequestParser.create(stack).parse()
        | 0x10 => AuthSuccessResponseParser.create(stack).parse()
        else error
        end

        Frame(version, flags, stream, message)
