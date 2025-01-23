package Macro_JsonSerializable

import serialization.serialization.*
import encoding.json.*
import Macro_JsonSerializable.macros.*

@JsonSerializable[private]
public struct S0 <: Serializable<S0> & ToString & ToJson {
    let name: String
}

@JsonSerializable[protected]
public struct S1<T> <: Serializable<S1<T>> & ToString & ToJson where T <: Serializable<T> {
    let name: String
    let t: T
}

@JsonSerializable[internal]
public struct S2<T, Q> <: Serializable<S2<T, Q>> & ToString & ToJson where T <: Serializable<T>, Q <: Serializable<Q> {
    let t: T
    let q: Q
}

@JsonSerializable[public]
public struct S3<T, Q> <: Serializable<S3<T, Q>> & ToString & ToJson where T <: Serializable<T>, Q <: Serializable<Q> {
    let t: Option<T>
    let q: ????Q
}

main() {
    println(S3(t: "T", q: "Q")) // {"t":"T","q":"Q"}
}