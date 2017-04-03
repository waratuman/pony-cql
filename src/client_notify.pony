use "./native_protocol"

interface ClientNotify

    fun ref authenticate(client: Client ref, authenticator: Authenticator iso): Authenticator iso^ =>
        """
        Called when the connection has requested authentication. The
        authenticator requested by the connection is passed as the second
        argument.

        fun ref authenticate(client: Client ref, authenticator: Authenticator iso): Authenticator iso =>
            match authenticator
            | let a: PasswordAuthenticator => a("username", "password")
            end
            consume a
        """
        consume authenticator

    fun ref authenticate_failed(client: Client): None val =>
        None

    fun ref authenticated(client: Client ref): None val =>
        """
        Called after the connection has been authenticated.
        """
        None

    fun ref closed(client: Client ref): None val =>
        None

    fun ref connect_failed(client: Client ref): None val =>
        None
    
    fun ref connecting(client: Client ref, count: U32 val): None val =>
        None
    
    fun ref connected(client: Client ref): None val =>
        None

    fun ref received(client: Client ref, response: Response val): None val =>
        None
