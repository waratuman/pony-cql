// interface ClientNotify

//     fun ref authenticate(client: Client ref, authenticator: Authenticator iso): (Array[U8 val] val | None val) =>
//         """
//         Called when the connection has requested authentication. The
//         authenticator requested by the connection is passed as the second
//         argument.
//         """
//         None

//     fun ref authenticated(client: Client ref): None val =>
//         """
//         Called after the connection has been authenticated.
//         """
//         None

//     fun ref connect_failed(client: Client ref): None val =>
//         None
    
//     fun ref connected(client: Client ref): None val =>
//         None

//     fun ref received(client: Client ref, response: Response val): None val =>
//         None

//     fun ref sent(client: Client ref, request: Request val): None val =>
//         None
