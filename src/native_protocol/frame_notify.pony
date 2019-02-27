use "net"
use "logger"


class FrameNotify is TCPConnectionNotify

    let _notify: FrameNotifiee tag
    let _logger: (Logger[String] | None)
    
    var _header: (Array[U8 val] iso | None) = None
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

    fun ref _received_frame(conn: TCPConnection ref, data: Array[U8 val] iso) ? =>
        _notify.received(conn, FrameParser(consume data)?)?

    fun ref received(conn: TCPConnection ref, data: Array[U8 val] iso, times: USize val): Bool val =>    
        match _header = None
        | let h: Array[U8 val] iso =>
            let data2 = recover iso
                let y: Array[U8 val] ref = consume data
                y
            end
            h.append(consume data2)
            try
                _received_frame(conn, consume h)?
            else
                _log(Error, "Error parsing frame body.")
            end
            conn.expect(9)
            true
        | None =>
            try
                _version = data(0)? and 0b0111
                _flags = data(1)?
                _stream = ((data(2)?.u16() << 8) or data(3)?.u16())
                _opcode = data(4)?
                _length = (data(5)?.i32() << 24)
                    or (data(6)?.i32() << 16)
                    or (data(7)?.i32() << 8)
                    or data(8)?.i32()

                if (_length == 0) then
                    conn.expect(9)
                    _received_frame(conn, consume data)?
                else
                    _header = consume data
                    conn.expect(_length.usize())
                end
                true
            else
                _log(Error, "Error parsing frame header.")
                false
            end
        end

    fun ref closed(conn: TCPConnection ref) =>
        _notify.closed(conn)

    fun ref throttled(conn: TCPConnection ref) =>
        _notify.throttled(conn)

    fun ref unthrottled(conn: TCPConnection ref) =>
        _notify.unthrottled(conn)
