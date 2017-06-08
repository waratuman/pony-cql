use collection = "collections" 

// Consistency 
primitive AnyConsistency
    fun value(): U16 => 0x0000
primitive One
    fun value(): U16 => 0x0001
primitive Two
    fun value(): U16 => 0x0002
primitive Three
    fun value(): U16 => 0x0003
primitive Quorum
    fun value(): U16 => 0x0004
primitive All
    fun value(): U16 => 0x0005
primitive LocalQuorum
    fun value(): U16 => 0x0006
primitive EachQuorum
    fun value(): U16 => 0x0007
primitive Serial
    fun value(): U16 => 0x0008
primitive LocalSerial
    fun value(): U16 => 0x0009
primitive LocalOne
    fun value(): U16 => 0x000A

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
