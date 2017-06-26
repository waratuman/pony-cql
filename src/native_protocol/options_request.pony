class iso OptionsRequest is Stringable

    new iso create() =>
        None

    fun box string(): String iso^ =>
        "OPTIONS".string()