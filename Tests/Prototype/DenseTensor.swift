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
