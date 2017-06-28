primitive FrameVisitor is Visitor[Frame val]

    fun box apply(frame: Frame val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
        let version: U8 = match frame.body
        | let b: Request val => 0x7F and frame.version
        else frame.version
        end

        let opcode: U8 = match frame.body
        | let b: StartupRequest val => 0x01
        | let b: ReadyResponse val => 0x02
        | let b: AuthenticateResponse val => 0x03
        | let b: OptionsRequest val => 0x05
        | let b: SupportedResponse val => 0x06
        | let b: QueryRequest val => 0x07
        // | let b: ResultResponse => 0x08
        // | let b:  => 0x09
        // | let b:  => 0x0A
        // | let b:  => 0x0B
        // | let b:  => 0x0C
        // | let b:  => 0x0D
        // | let b:  => 0x0E
        | let b: AuthResponseRequest val => 0x0F
        | let b: AuthSuccessResponse val => 0x10
        else 0
        end
    
        let body = Array[U8 val]()
        FrameBodyVisitor(frame.body, body)
        
        ByteVisitor(version, c)
        ByteVisitor(frame.flags, c)
        ShortVisitor(frame.stream, c)
        ByteVisitor(opcode, c)
        IntVisitor(body.size().i32(), c)
        c.append(body)

        c

primitive FrameBodyVisitor is Visitor[Message val]

        fun box apply(msg: Message val, c: Array[U8 val] ref = Array[U8 val]): Array[U8 val] ref =>
            match msg
            | let r: ErrorResponse val => OldVisitor.visitErrorResponse(r, c)      
            | let r: StartupRequest val => StartupRequestVisitor(r, c)
            | let r: ReadyResponse val => OldVisitor.visitReadyResponse(r, c)
            | let r: AuthenticateResponse val => OldVisitor.visitAuthenticateResponse(r, c)
            | let r: OptionsRequest val => OldVisitor.visitOptionsRequest(r, c)
            | let r: SupportedResponse val => OldVisitor.visitSupportedResponse(r, c)
            | let r: QueryRequest val => OldVisitor.visitQueryRequest(r, c)
            // | let r: ResultResponse val => OldVisitor.OldVisitor.visitResultResponse(r, c)
            // | let r: PrepareRequest val => OldVisitor.visitPrepareRequest(r, c)
            // | let r: ExecuteRequest val => OldVisitor.visitExecuteRequest(r, c)
            // | let r: RegisterRequest val => OldVisitor.visitRegisterRequest(r, c)
            // | let r: EventResponse val => OldVisitor.visitEventResponse(r, c)
            // | let r: BatchRequest val => OldVisitor.visitBatchRequest(r, c)
            // | let r: AuthChallengeResponse val => OldVisitor.visitAuthChallengeResponse(r, c)
            | let r: AuthResponseRequest val => OldVisitor.visitAuthResponseRequest(r, c)
            | let r: AuthSuccessResponse val => OldVisitor.visitAuthSuccessResponse(r, c)
            else c
            end
            c
