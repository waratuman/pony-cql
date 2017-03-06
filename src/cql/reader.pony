// interface MessageReaderListener
//     fun ref messageRead(message: Message val)

// class MessageReader

//     let listener: MessageReaderListener

//     var _dataSize: USize = 0
//     embed _data: collections.List[(Array[U8 val] val, USize)] = collections.List[(Array[U8 val] val, USize)]()

//     var _frameVersion:  (U8 val | None val)
//     var _frameFlags: (U8 val | None val)
//     var _frameStream: (U16 val | None val)
//     var _frameMessage: (Request val | Response val | None val)
//     var _frameLength: (I32 val | None val)

//     new create(listener': MessageReaderListener) =>
//         listener = listener'

//     fun ref write(data: Array[U8 val] val) =>
//         _data.push((data, 0))
//         _dataSize = _dataSize + data.size()
//         _readFrame()

//     fun ref _readFrame() =>

//     fun ref _consume(n: USize): Array[U8 val] iso^ ? =>
//         if _dataSize < n then
//             error
//         end

//         _dataSize = _dataSize - n

//         var i = USize(0)
//         var output = recover Array[U8].>undefined(len) end

//         while i < n do
//             let node = _data.head()
//             (let datum, let offset) = node()

//             let available = data.size() - offset
//             let need = n - i
//             let copy_size = need.min(available)

//             out = recover
//                 let 
//             end
//         end

//         consume output