class val OptionsRequest is Stringable

    new val apply() =>
        None

    new val create() =>
        None

    fun string(): String iso^ =>
        "OPTIONS".string()