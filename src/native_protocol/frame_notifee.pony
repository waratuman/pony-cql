use "net"

interface FrameNotifiee

    be accepted(conn: TCPConnection tag)

    be closed(conn: TCPConnection tag)

    be connecting(conn: TCPConnection tag, count: U32 val)

    be connect_failed(conn: TCPConnection tag)

    be connected(conn: TCPConnection tag)

    be received(conn: TCPConnection tag, frame: Frame iso)

    be throttled(conn: TCPConnection tag)

    be unthrottled(conn: TCPConnection tag)