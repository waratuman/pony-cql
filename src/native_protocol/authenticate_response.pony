class iso AuthenticateResponse is Stringable

    let authenticator_name: String val

    new iso create(authenticator_name': String val) =>
        authenticator_name = authenticator_name'

    fun box string(): String iso^ =>
        recover
            let result: String ref = String
            result.append("AUTHENTICATE ")
            result.append(authenticator_name)
            result
        end
