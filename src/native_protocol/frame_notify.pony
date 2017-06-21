use "net"
use "logger"

class FrameNotify is TCPConnectionNotify

    let _notify: FrameNotifiee tag
    let _logger: (Logger[String] | None)
    
    var _header: (Array[U8 val] val | None) = None
    var _version: U8 val = 4
    var _flags: U8 val = 0
    var _stream: U16 val = 0
    var _opcode: U8 val = 0
    var _length: I32 val = 0
    
    new iso create(notify: FrameNotifiee tag, logger: (Logger[String] | None) = None) => 
        _notify = notify
        _logger = logger

    fun ref _log(level: LogLevel, message: String val, loc: SourceLoc = __loc) =>
        match _logger
        | let l: Logger[String] => l(level) and l.log(message, loc)
        end
    
    fun ref accepted(conn: TCPConnection ref) =>
        conn.expect(9)
        _notify.accepted(conn)

    fun ref connecting(conn: TCPConnection ref, count: U32 val) =>
        _notify.connecting(conn, count)

    fun ref connected(conn: TCPConnection ref) =>
        conn.expect(9)
        _notify.connected(conn)

    fun ref connect_failed(conn: TCPConnection ref) =>
        _notify.connect_failed(conn)

    fun ref _received_frame(conn: TCPConnection ref, data: Array[U8 val] val) ? =>
        let stack = ParserStack(data)
        let frame: Frame val = FrameParser(stack).parse()
        _notify.received(conn, frame)

    fun ref received(conn: TCPConnection ref, data: Array[U8 val] val, times: USize val): Bool val =>
        // _log(Fine, Bytes.to_hex_string(data))
        try
            let body_present = match _header
            | None =>
                _header = data
                
                _version = data(0) and 0b0111
                _flags = data(1)
                _stream = ((data(2).u16() << 8) or data(3).u16())
                _opcode = data(4)
                _length = (data(5).i32() << 24)
                    or (data(6).i32() << 16)
                    or (data(7).i32() << 8)
                    or data(8).i32()

                _length != 0
            | let h: Array[U8 val] val => false
            else error
            end

            if body_present then
                conn.expect(_length.usize())
                true
            else
                match _header
                | let h: Array[U8 val] val =>
                    let d: Array[U8 val] iso = recover Array[U8 val] end
                    d.append(h)
                    d.append(data)
                    _received_frame(conn, consume d)
                end
                conn.expect(9)
                _header = None
                false
            end
        else
            match _header
            | None =>
                _log(Error, "Error parsing frame header: " + Bytes.to_hex_string(data))
            | let h: Array[U8 val] val => 
                _log(Error, "Error parsing frame body: " + Bytes.to_hex_string(h) + Bytes.to_hex_string(data))
            end
            false
        end

    fun ref closed(conn: TCPConnection ref) =>
        _notify.closed(conn)

    fun ref throttled(conn: TCPConnection ref) =>
        _notify.throttled(conn)

    fun ref unthrottled(conn: TCPConnection ref) =>
        _notify.unthrottled(conn)
