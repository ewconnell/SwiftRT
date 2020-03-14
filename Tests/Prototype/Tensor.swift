/// Types that determine compatibility of tensors for use in binary operations.
///
/// Every type conforming to `TensorProtocol` has an associated
/// `CompatibilityClass` that can be used to restrict the tensors it interacts
/// with to have matching rank and possibly other properties, such as device
/// class.
///
/// Compatibility classes can be compared at runtime with `==` to dynamically
/// check that the details of their shapes match.
protocol TensorCompatibility : Equatable {
    /// A type whose values can hold the shape of the tensor.
    ///
    /// Binary operations that require their operands have matching rank can
    /// statically require that they have the same `Rank` type.
    associatedtype Rank: FixedSizeArray where Rank.Element == Int
    
    /// The shape of the tensor.
    var dimensions: Rank { get }
}

/// Types whose values represent mathematical tensors objects
protocol Tensor {
    associatedtype CompatibilityClass: TensorCompatibility
    var compatibilityClass: CompatibilityClass { get }

    associatedtype Scalar
}

