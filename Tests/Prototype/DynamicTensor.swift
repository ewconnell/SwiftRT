/// Types that implement core operations for dynamic tensors.
///
/// Only tensors having the same tensor class can interoperate in operations
/// like `+` or `matmul`.
protocol DynamicTensorClass {
    associatedtype Scalar

    /// Traps with an appropriate message iff `self` cannot be combined with
    /// `other` in computations for a reasons *other than* a shape mismatch.
    ///
    /// May be used to dynamically check that two tensors are on the same
    /// device.
    func checkOperationalCompatibility(with other: Self)
    
    /// Returns `l` + `r`.
    static func plus<Shape: TensorShape>(
        _ l: Self, _ r: Self, shape: Shape
    ) -> Self

    /// Returns `l`×`r``.
    ///
    /// - Requires: `lshape[1] == rshape[0]`
    static func matmul(
        _ l: Self, shape lshape: Rank2, _ r: Self, shape rshape: Rank2
    ) -> Self

    /// Returns true iff `l` = `r`.
    static func equals<Shape: TensorShape>(
        _ l: Self, _ r: Self, shape: Shape
    ) -> Self
}

/// A tensor whose type depends only on its rank and Scalar type.
struct DynamicTensor<Class: DynamicTensorClass, Shape: TensorShape> {
    var implementation: Class
    var shape: Shape
    
    typealias Scalar = Class.Scalar
    
    init(_ implementation: Class, shape: Shape) {
        self.implementation = implementation
        self.shape = shape
    }

    /// Traps iff `self` and `other` are incompatible for pointwise operations
    /// such as `+`.
    func checkPointwiseCompatibility(with other: Self) {
        implementation.checkOperationalCompatibility(with: other.implementation)
        precondition(shape == other.shape, "shape \(shape) != \(other.shape)")
    }
    
    static func + (l: Self, r: Self) -> Self {
        l.checkPointwiseCompatibility(with: r)
        return DynamicTensor(
            Class.plus(l.implementation, r.implementation, shape: l.shape),
            shape: l.shape)
    }
}

/// Returns `l`×`r``.
///
/// - Requires: `l.shape[1] == r.shape[0]`
func matmul<Class: DynamicTensorClass>(
    _ l: DynamicTensor<Class, Rank2>, _ r: DynamicTensor<Class, Rank2>
) -> DynamicTensor<Class, Rank2> {
    l.implementation.checkOperationalCompatibility(with: r.implementation)
    precondition(
        l.shape[1] == r.shape[0],
        "inner dimensions \(l.shape[1]) != \(r.shape[0])")
    return DynamicTensor(
        Class.matmul(
            l.implementation, shape: l.shape,
            r.implementation, shape: r.shape),
        shape: Rank2(l.shape[0], r.shape[1]))
}
