/// Types that can represent the shape, dimensions, or index of a tensor.
///
// If Swift supported constrained typealiases, this would be one, and… 
protocol TensorShape: FixedSizeArray where Element == Int, Self: Equatable {}
// …these conformances wouldn't need to be declared.
extension Array1 : TensorShape where Element == Int {}
extension ArrayN : TensorShape where Tail : TensorShape {}

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
    associatedtype Dimensions: TensorShape
    
    /// The shape of the tens,or.
    var dimensions: Dimensions { get }
}

/// Types whose values represent mathematical tensor objects
protocol Tensor {
    associatedtype CompatibilityClass: TensorCompatibility
    var compatibilityClass: CompatibilityClass { get }

    associatedtype Scalar
    
    subscript(i: Index) -> Scalar { get }
}

extension Tensor {
    typealias Index = CompatibilityClass.Dimensions
    typealias Shape = Index
    var rank: Int { compatibilityClass.dimensions.count }
}

typealias Rank1 = Array1<Int>
typealias Rank2 = Array2<Int>
typealias Rank3 = Array3<Int>
typealias Rank4 = Array4<Int>
typealias Rank5 = Array5<Int>
typealias Rank6 = Array6<Int>
typealias Rank7 = Array7<Int>

struct RankCompatibility<D: TensorShape> : TensorCompatibility
{
    var dimensions: D
}

/// A dense tensor view of some underlying `Base` collection.
///
/// The base collection's elements are mapped into ranks in row-major order: in
/// the base collection, the tensor element at (i₀, i₁, ...i₅+1) immediately
/// follows the one at (i₀, i₁, ...i₅).
struct DenseTensor<Base: RandomAccessCollection, Shape: TensorShape>
    : Tensor
{
    var base: Base
    let shape: Shape

    var compatibilityClass: RankCompatibility<Shape> {
        .init(dimensions: shape)
    }
    
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
