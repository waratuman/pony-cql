primitive Visitor
    
    fun apply(message: Request box): Array[U8 val] val =>
        visitRequest(message)
    
    fun visit(message: Request box): Array[U8 val] val => 
        visitRequest(message)

    fun visitRequest(request: Request box): Array[U8 val] val =>
        match request
        | let r: StartupRequest box => visitStartupRequest(r)
        | let r: AuthResponseRequest box => visitAuthResponseRequest(r)
        else
            recover Array[U8 val]() end
        end

    fun visitStartupRequest(request: StartupRequest box): Array[U8 val] val =>
        let compression = request.compression
        let cqlVersion = request.cqlVersion
        
        recover
            let data = Array[U8 val]()
            var pairs: U16 = 1

            match compression
            | let c: String => 
                pairs = pairs + 1
                let compressionLength: U16 = 11
                for byte in Bytes.of[U16](compressionLength).values() do
                    data.push(byte)
                end
                for byte in "COMPRESSION".array().values() do
                    data.push(byte)
                end
        
                for byte in Bytes.of[U16](c.array().size().u16()).values() do
                    data.push(byte)
                end
                for byte in c.array().values() do
                    data.push(byte)
                end
            end

            let cqlVersionLength: U16 = 11
            for byte in Bytes.of[U16](cqlVersionLength).values() do
                data.push(byte)
            end
            for byte in "CQL_VERSION".array().values() do
                data.push(byte)
            end

            for byte in Bytes.of[U16](cqlVersion.array().size().u16()).values() do
                data.push(byte)
            end
            for byte in cqlVersion.array().values() do
                data.push(byte)
            end

            for byte in Bytes.of[U16](pairs).reverse().values() do
                data.unshift(byte)
            end

            data
        end

    fun visitAuthResponseRequest(request: AuthResponseRequest box): Array[U8 val] val =>
        let token = request.token

        recover
            let data = Array[U8 val]()

            match token
            | None =>
                let x: I32 = -1
                for byte in Bytes.of[I32](x).values() do
                    data.push(byte)
                end
            | let t: Array[U8 val] val =>
                for byte in Bytes.of[I32](t.size().i32()).values() do
                    data.push(byte)
                end
                for byte in t.values() do
                    data.push(byte)
                end
            end
            
            data
        end