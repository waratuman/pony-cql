use "net"
use "collections"
use "chrono"

type ASCII is String

type BigInt is I64

type Blob is Array[U8 val] val

type Boolean is Bool
    
type Type is (
    NativeType val
    | CollectionType val
)

type NativeType is (
    String val              // ascii
    | I64 val               // bigint
    | Array[U8 val] val     // blob
    | Bool val              // boolean
                            // counter
    | Date val              // date
                            // decimal
    | F64 val               // double
    | F32 val               // float
    | NetAddress val        // inet
    | I32 val               // int
    | I16 val               // smallint
                            // time
    | Time val              // timestamp
                            // timeuuid
    | I8 val                // tinyint
                            // uuid
                            // varchar
                            // varint
)

type CollectionType is (
    Seq[NativeType val] val     // list
    | SetType val
    | MapType val
)

type SetType is (
    Set[String val] val
    | Set[I64 val] val
    // | Set[Array[U8 val] val] val
    // | Set[Bool val] val
    // | Set[Date val] val
    | Set[F64 val] val
    | Set[F32 val] val
    // | Set[NetAddress val] val
    | Set[I32 val] val
    | Set[I16 val] val
    // | Set[Time val] val
    | Set[I8 val] val
)

type MapType is (
    Map[String val, NativeType val] val
    | Map[I64 val, NativeType val] val
    // | Map[Array[U8 val] val, NativeType val] val
    // | Map[Bool val, NativeType val] val
    // | Map[Date val, NativeType val] val
    | Map[F64 val, NativeType val] val
    | Map[F32 val, NativeType val] val
    // | Map[NetAddress val, NativeType val] val
    | Map[I32 val, NativeType val] val
    | Map[I16 val, NativeType val] val
    // | Map[Time val, NativeType val] val
    | Map[I8 val, NativeType val] val
)