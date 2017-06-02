// primitive Visitor

//     fun apply(type: Type val, c: String ref = String): String val =>
//         match type
//         | let t: Type => visitType(t, c)
//         end
//         recover c end
    
//     fun ref visitType(type: Type val, c: String ref = String): String ref =>
//         match type
//         | let t: NativeType val => visitNativeType(t, c)
//         // | let t: CollectionType val => visitCollectionType(t, c)
//         // | let t: TupleType val => visitTupleType(t, c)
//         end
//         c

//     fun ref visitNativeType(type: NativeType val, c: String ref = String): String ref =>
//         match type
//         | let t: String val => visitString(t, c)
//         // | let t: I64 val => visitBigInt(t, c)
//         end
    
//     fun ref visitString()