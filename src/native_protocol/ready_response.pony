class ref ReadyResponse is Stringable

    new ref create() =>
        None

    fun box string(): String iso^ =>
        "READY".string()
