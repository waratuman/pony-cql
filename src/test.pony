use "ponytest"
use np = "./native_protocol"

actor Main is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)

    fun tag tests(test: PonyTest) =>
        np.Main.make().tests(test)
        AuthenticatorTestList.make().tests(test)
        ClientTestList.make().tests(test)
        ClientNotifyTestList.make().tests(test)

