use collection = "collections" 

type Consistency is
    ( AnyConsistency
    | One
    | Two
    | Three
    | Quorum
    | All
    | LocalQuorum
    | EachQuorum
    | Serial
    | LocalSerial
    | LocalOne
    )

primitive AnyConsistency is Equatable[Consistency]
    
    fun value(): U16 =>
        0x0000

    fun string(): String iso^ =>
        "Any".string()

primitive One is Equatable[Consistency]

    fun value(): U16 =>
        0x0001

    fun string(): String iso^ =>
        "One".string()

primitive Two is Equatable[Consistency]
    
    fun value(): U16 =>
        0x0002

    fun string(): String iso^ =>
        "Two".string()

primitive Three is Equatable[Consistency]

    fun value(): U16 =>
        0x0003

    fun string(): String iso^ =>
        "Three".string()

primitive Quorum is Equatable[Consistency]

    fun value(): U16 =>
        0x0004

    fun string(): String iso^ =>
        "Quorum".string()

primitive All is Equatable[Consistency]
    
    fun value(): U16 =>
        0x0005

    fun string(): String iso^ =>
        "All".string()

primitive LocalQuorum is Equatable[Consistency]
    
    fun value(): U16 =>
        0x0006

    fun string(): String iso^ =>
        "LocalQuorum".string()

primitive EachQuorum is Equatable[Consistency]
    
    fun value(): U16 =>
        0x0007

    fun string(): String iso^ =>
        "EachQuorum".string()

primitive Serial is Equatable[Consistency]
    
    fun value(): U16 =>
        0x0008

    fun string(): String iso^ =>
        "Serial".string()

primitive LocalSerial is Equatable[Consistency]

    fun value(): U16 =>
        0x0009

    fun string(): String iso^ =>
        "LocalSerial".string()

primitive LocalOne is Equatable[Consistency]

    fun value(): U16 => 0x000A

    fun string(): String iso^ =>
        "LocalOne".string()


type QueryFlags is collection.Flags[
    ( Values
    | SkipMetadata
    | PageSize
    | WithPagingState
    | WithSerialConsistency
    | WithDefaultTimestamp
    | WithNamesForValues
    ), U8]

primitive Values is collection.Flag[U8]
    fun value(): U8 => 0x01
    fun string(): String => "Values"

primitive SkipMetadata is collection.Flag[U8]
    fun value(): U8 => 0x02
    fun string(): String => "SkipMetadata"

primitive PageSize is collection.Flag[U8]
    fun value(): U8 => 0x04
    fun string(): String => "PageSize"

primitive WithPagingState is collection.Flag[U8]
    fun value(): U8 => 0x08
    fun string(): String => "WithPagingState"

primitive WithSerialConsistency is collection.Flag[U8]
    fun value(): U8 => 0x10
    fun string(): String => "WithSerialConsistency"

primitive WithDefaultTimestamp is collection.Flag[U8]
    fun value(): U8 => 0x20
    fun string(): String => "WithDefaultTimestamp"

primitive WithNamesForValues is collection.Flag[U8]
    fun value(): U8 => 0x40
    fun string(): String => "WithNamesForValues"
