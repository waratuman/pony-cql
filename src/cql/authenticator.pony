interface Authenticator
    fun ref token(): (Array[U8 val] val | None)
    fun ref name(): String val

class PasswordAuthenticator is Authenticator

    let username: String val
    let password: String val

    new create(username': String val, password': String val) =>
        username = username'
        password = password'

    fun ref name(): String val =>
        "org.apache.cassandra.auth.PasswordAuthenticator"

    fun ref token(): Array[U8 val] val =>
        recover
            let t = Array[U8 val](2 + username.size() + password.size())
            t.push(0x00)
            t.append(username.array())
            t.push(0x00)
            t.append(password.array())
            t
        end
