// trait Response


//     let version: U8 val
//     let opcode: OpCode val
//     let flags: U8 val
//     let stream: U16 val
//     let body: Body

//     new create(version': U8 val, opcode': OpCode val, flags': U8 val, stream': U16 val, body': Body) =>
//         version = version'
//         opcode = opcode'
//         flags = flags'
//         stream = stream'
//         body = body'

//     new decode(data: Array[U8 val] val) ? =>

//     fun tag decodeAuthenticateBody(data: Array[U8 val] val): String val ? =>
//         recover
//             let length: U16 = Bytes.to_u16(recover data.slice(0,2) end)
//             String.from_array(recover data.slice(2, (2 + length).usize()) end)
//         end

//     fun string(): String val =>
//         let bodyString = match body
//         | let b: String => " " + b
//         else
//             ""
//         end

//         "[" + stream.string() + "] " + opcode.string().upper() + bodyString
        
