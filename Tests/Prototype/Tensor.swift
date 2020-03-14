/// Types whose instances can represent the shape of, or an index of, a tensor.
///
// If Swift supported constrained typealiases, this would be one, and… 
protocol TensorShape: FixedSizeArray where Element == Int, Self: Equatable {}
// …these conformances wouldn't need to be declared.
extension Array1 : TensorShape where Element == Int {}
extension ArrayN : TensorShape where Tail : TensorShape {}

typealias Rank1 = Array1<Int>
typealias Rank2 = Array2<Int>
typealias Rank3 = Array3<Int>
typealias Rank4 = Array4<Int>
typealias Rank5 = Array5<Int>
typealias Rank6 = Array6<Int>
typealias Rank7 = Array7<Int>

/// Types that can be used to index tensors of a given shape.
typealias TensorIndex<Shape: TensorShape> = Shape

/// Types that implement core tensor operations.
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

struct DynamicTensor<Class: DynamicTensorClass, Shape: TensorShape> {
    var implementation: Class
    var shape: Shape
    
    typealias Scalar = Class.Scalar
    
    init(_ implementation: Class, shape: Shape) {
        self.implementation = implementation
        self.shape = shape
    }

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

/// Types whose values represent mathematical tensor objects
protocol TensorValue {
    associatedtype Scalar
    associatedtype Shape: TensorShape

    var shape: Shape { get }
    typealias Index = Shape
    subscript(i: Index) -> Scalar { get }
}

extension TensorValue {
    var rank: Int { shape.count }
    var count: Int { shape.reduce(1, &*) }
}

/// A dense tensor view of some underlying `Base` collection.
///
/// The base collection's elements are mapped into ranks in row-major order: in
/// the base collection, the tensor element at (i₀, i₁, ...i₅+1) immediately
/// follows the one at (i₀, i₁, ...i₅).
struct DenseTensor<Base: RandomAccessCollection, Shape: TensorShape>
    : TensorValue
{
    var base: Base
    let shape: Shape

    
    init(_ base: Base, shape: Shape) {
        self.base = base
        self.shape = shape
    }

    private func baseIndex(_ i: Index) -> Base.Index {
        let baseOffset = zip(i, shape).reduce(0) { r, id in
            r * id.1 + id.0
        }
        return base.index(base.startIndex, offsetBy: baseOffset)
    }

    typealias Index = Shape
    subscript(i: Index) -> Base.Element {
        return base[baseIndex(i)]
    }
}
