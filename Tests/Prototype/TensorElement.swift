/// Types that can be elements of tensors.
protocol TensorElement {
    /// Every `TensorElement` is a balanced tree of zero or more
    /// `TensorElement`s, with `Scalar` instances at the leaves.
    ///
    /// The default Scalar type is `Self`.
    associatedtype Scalar: TensorElement  = Self
        where Scalar._Element == Never

    associatedtype _Element = Never

    static func _subscript(_ instance: Self, at i: Int) -> _Element
    static func _count(_ instance: Self) -> Int
}

extension TensorElement where _Element == Never {
    static func _subscript(_ instance: Self, at i: Int) -> Never {
        fatalError()
    }
    static func _count(_:Self) -> Int { 0 }
}

extension TensorElement where _Element: TensorElement {
    typealias Element = _Element
    
    subscript(i: Int) -> Element {
        Self._subscript(self, at: i)
    }
    var count: Int { Self._count(self) }
}

extension Int : TensorElement {}
extension UInt : TensorElement {}
extension Float : TensorElement {}
extension Double : TensorElement {}

/*
struct AnyTensorElement<Scalar: TensorElement>
    where Scalar._Element == Never
{
    private enum Storage {
        case scalar(Scalar)
        case vector(AnyTensorElementVector_<Scalar>)
    }
    private let storage: Storage
    
    init(scalar base: Scalar) {
        storage = .scalar(base)
    }

    init<Base: TensorElement>(vector base: Base)
        where Base._Element : TensorElement,
              Base.Scalar == Scalar,
              Base._Element == Scalar
    {
        storage = .vector(AnyTensorElementVector(base))
    }
    
    init<Base: TensorElement>(vector base: Base)
        where Base._Element : TensorElement, Base.Scalar == Scalar
    {
        storage = .vector(AnyTensorElementVector(base))
    }
    
    subscript(i: Int) -> AnyTensorElement<Scalar> {
        guard case .vector(let impl) = storage else {
            fatalError("Can't subscript a scalar.")
        }
        return impl[i]
    }
}

fileprivate class AnyTensorElementVector_<Scalar: TensorElement>
    where Scalar._Element == Never
{
    subscript(i: Int) -> AnyTensorElement<Scalar> {
        fatalError("should be unreachable.")
    }
}

fileprivate class AnyTensorElementVector<Base: TensorElement>
    : AnyTensorElementVector_<Base.Scalar>
    where Base._Element: TensorElement
{
    let base: Base
    
    init(_ base: Base) { self.base = base }

    override subscript(i: Int) -> AnyTensorElement<Base.Scalar> {
       return Base._Element == Base.Scalar
           ? .init(scalar: base[i] as! Base.Scalar)
           : .init(vector: base[i])
    }

    override subscript(i: Int) -> AnyTensorElement<Base.Scalar>
        where Base.Scalar == Base._Element.Scalar
    {
        .init(vector: base[i])
    }
}

*/
