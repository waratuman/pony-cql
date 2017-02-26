use "format"
use collection = "collections" 

class Request

    let version: U8 val = 4
    let opcode: OpCode
    let flags: U8 = 0
    let stream: U16 val
    let body: Body
    
    new create(opcode': OpCode, id': U16, body': Body = None) =>
        opcode = opcode'
        stream = id'
        body = body'

    fun encode(): Array[U8 val] val ? =>
        recover
            let encodedBody = _encodeBody(body)
            let encodedBodyLength = _encodedBodyLength(encodedBody)
            let encodedHeader = _encodeHeader(encodedBodyLength)

            let result = Array[U8 val](encodedBodyLength.usize() + encodedHeader.size())
            result.append(encodedHeader)
            match encodedBody
            | let b: Array[U8 val] val => result.append(b)
            end
            result
        end

    fun _encodeHeader(length: U32): Array[U8 val] val =>
        recover
            let header = Array[U8 val](9)
            
            header.push(version)
            header.push(flags)

            for byte in Bytes.from_u16(stream).values() do
                header.push(byte)
            end

            header.push(opcode.value())

            for byte in Bytes.from_u32(length).values() do
                header.push(byte)
            end
            header
        end


    fun _encodeBody(data: None val): EncodedBody val => None
    fun _encodeBody(data: Array[U8 val] val): EncodedBody val => data
    fun _encodeBody(data: String val): EncodedBody val =>
        recover
            let result = Array[U8 val](2 + data.size())
            result.append(Bytes.from_u16(data.size().u16()))
            result.append(data.array())
            result
        end
    fun _encodeBody(data: collection.Map[String val, String val] val): EncodedBody val =>
        recover
            let result = Array[U8 val]()

            for byte in Bytes.from_u16(data.size().u16()).values() do
                result.push(byte)
            end

            for (k, v) in data.pairs() do
                for byte in Bytes.from_u16(k.size().u16()).values() do
                    result.push(byte)
                end
                for byte in k.values() do
                    result.push(byte)
                end
                for byte in Bytes.from_u16(v.size().u16()).values() do
                    result.push(byte)
                end
                for byte in v.values() do
                    result.push(byte)
                end
            end
        end

    fun tag _encodedBodyLength(data: (None | Array[U8 val] val)): U32 ? =>
        match data
        | let d: Array[U8 val] val =>
            if (d.size() > U32.max_value().usize()) then
                error
            else
                d.size().u32()
            end
        else
            0
        end
        
    
    fun string(): String val =>
        recover
            let output: String ref = String()
            
            output.append("[" + stream.string() + "] " + opcode.string().upper())

            match body
            | let b: collection.Map[String val, String val] val =>
                output.append(" { ")
                for (k, v) in b.pairs() do
                    output.append("\"" + k + "\"" + ": \"" + v + "\" ")
                end
                output.append("}")
            end

            output
        end
