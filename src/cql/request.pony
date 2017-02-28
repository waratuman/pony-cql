use "format"
use collection = "collections" 

trait Request is MessageBody

class StartupRequest is Request

    let cqlVersion: String val
    let compression: (String val | None val)

    new create(cqlVersion': String, compression': (String val | None val) = None) =>
        cqlVersion = cqlVersion'
        compression = compression'

    new decode(data: Array[U8 val] val) ? =>
        let pairs: U16 = Bytes.u16(recover data.slice(0, 2) end)

        var foundCqlVersion: String = ""
        var foundCompression: (String | None) = None
        var dataIndex: U16 = 2
        var processedPairs: U16 = 0
        while processedPairs < pairs do
            let keyLength = Bytes.u16(recover data.slice((dataIndex = dataIndex + 2).usize(), dataIndex.usize()) end)
            let key: String = String.from_array(recover data.slice((dataIndex = dataIndex + keyLength).usize(), dataIndex.usize()) end)
            let valueLength = Bytes.u16(recover data.slice((dataIndex = dataIndex + 2).usize(), dataIndex.usize()) end)
            let value: String = String.from_array(recover data.slice((dataIndex = dataIndex + valueLength).usize(), dataIndex.usize()) end)

            if key == "CQL_VERSION" then
                foundCqlVersion = value
            elseif key == "COMPRESSION" then
                foundCompression = value
            end
            
            processedPairs = processedPairs + 1
        end

        cqlVersion = foundCqlVersion
        compression = foundCompression

    fun encode(): Array[U8 val] val =>
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
        
    
    fun string(): String val =>
        recover
            let output: String ref = String()
            output.append("STARTUP {")

            match compression
            | let c: String => output.append(" \"COMPRESSION\": \"" + c + "\",")
            end
            
            output.append(" \"CQL_VERSION\": \"" + cqlVersion + "\"")

            output.append(" }")
            output
        end

class AuthResponseRequest is Request
    
    let token: (Array[U8 val] val | None)

    new create(token': (Array[U8 val] val | None) = None) =>
        token = token'
    
    new decode(data: Array[U8 val] val) ? =>
        let length: I32 = Bytes.i32(recover data.slice(0, 4) end)

        if (length < 0) then
            token = None
        else
            token = recover data.slice(4, 4 + length.usize()) end
        end
    
    fun encode(): Array[U8 val] val =>
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
    
    fun string(): String val =>
        "AUTH_RESPONSE"

class OptionsRequest is Request

    new create() =>
        None
    
    new decode(data: Array[U8 val] val) => 
        None

    fun encode(): Array[U8 val] val =>
        recover Array[U8 val]() end
    
    fun string(): String val =>
        "OPTIONS"

