class val ReadyResponse is Stringable

    new val apply() =>
        None

    new val create() =>
        None

    fun string(): String iso^ =>
        "READY".string()
