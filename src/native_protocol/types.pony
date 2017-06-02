use collection = "collections" 

// Consistency 
primitive AnyConsistency
primitive One
primitive Two
primitive Three
primitive Quorum
primitive All
primitive LocalQuorum
primitive EachQuorum
primitive Serial
primitive LocalSerial
primitive LocalOne

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

type QueryFlags is collection.Flags[(
    Values | SkipMetadata | PageSize | WithPagingState | WithSerialConsistency
    | WithDefaultTimestamp | WithNamesForValues
), U8]
