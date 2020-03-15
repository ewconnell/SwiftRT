 /// A "dumb" eager implementation for Dynamic Tensors
struct EagerCPU<Scalar: TensorElement> : DynamicTensorClass
    where Scalar._Element == Never
{
    var storage: [Scalar]
    
    /// Does nothing, as EagerCPU tensors are always compatible.
    func checkOperationalCompatibility(with other: Self) {}
    
    /// Returns `l` + `r`.
    static func plus<Shape: TensorShape>(
        _ l: Self, _ r: Self, shape: Shape
    ) -> Self {
        fatalError("implement me")
    }

    /// Returns `l`×`r``.
    ///
    /// - Requires: `lshape[1] == rshape[0]`
    static func matmul(
        _ l: Self, shape lshape: Rank2, _ r: Self, shape rshape: Rank2
    ) -> Self {
        fatalError("implement me")
    }

    /// Returns true iff `l` = `r`.
    static func equals<Shape: TensorShape>(
        _ l: Self, _ r: Self, shape: Shape
    ) -> Self {
        fatalError("implement me")
    }

    /// Returns the element at `index`.
    func subscript_<Shape: TensorShape>(
        shape: Shape, at index: Shape) -> AnyTensorElement<Scalar>
    {
        fatalError("implement me")
    }
}
