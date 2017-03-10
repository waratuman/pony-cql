use "ponytest"

actor ClientNotifyTestList is TestList
    
    new create(env: Env) =>
        PonyTest(env, this)
    
    new make() => None

    fun tag tests(test: PonyTest) =>
        None


// class _TestClientNotifyAuthenticate is UnitTest

// class _TestClientNotifyAuthenticateFailed is UnitTest

// class _TestClientNotifyAuthenticated is UnitTest

// class _TestClientNotifyClosed is UnitTest

// class _TestClientNotifyConnect is UnitTest

// class _TestClientNotifyConnectFailed is UnitTest

// class _TestClientNotifyConnecting is UnitTest

// class _TestClientNotifyConnected is UnitTest

// class _TestClientNotifyReceived is UnitTest

// class _TestClientNotifyThrottled is UnitTest

// class _TestClientNotifyUnthrottled is UnitTest
