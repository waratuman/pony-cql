interface Authenticator

    new iso create()

    fun box name(): String val

    fun box token(): (Array[U8 val] val | None val)


class iso PasswordAuthenticator is Authenticator

    var _token: (Array[U8 val] val | None val)

    new iso create() =>
        _token = None

    fun box name(): String val =>
        "org.apache.cassandra.auth.PasswordAuthenticator"

    fun ref apply(username: String val, password: String val) =>        
        _token = recover
            let t: Array[U8 val] ref = Array[U8 val](2 + username.size() + password.size())
            t.push(0x00)
            t.append(username.array())
            t.push(0x00)
            t.append(password.array())
            t
        end

    fun box token(): (Array[U8 val] val | None val) =>
        _token
