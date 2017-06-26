class iso ReadyResponse is Stringable

    new iso create() =>
        None

    fun box string(): String iso^ =>
        "READY".string()
