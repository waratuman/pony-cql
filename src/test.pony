use "logger"
use "ponytest"
use np = "./native_protocol"

actor Main is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
        // try
        //     let logger = StringLogger(Fine, env.out)
        //     Client(env.root as AmbientAuth, ClientNotifyTest.create(), "", "9042", logger)
        // end


    fun tag tests(test: PonyTest) =>
        np.Main.make().tests(test)
        AuthenticatorTestList.make().tests(test)
        ClientTestList.make().tests(test)
        ClientNotifyTestList.make().tests(test)

class ClientNotifyTest is ClientNotify

    fun ref authenticate(client: Client ref, authenticator: Authenticator iso): Authenticator iso^ =>
        recover
            let a: Authenticator ref = consume authenticator
            match a
            | let b: PasswordAuthenticator ref => b("cassandra", "cassandra")
            end
            a
        end

    fun ref connected(client: Client ref): None val =>
        let query = np.QueryRequest("LIST USERS;")
        client.query(query)
