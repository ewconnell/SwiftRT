// Existential type for quick-n-dirty type erasure.
protocol _AnyTensorElement {
    func _anySubscript(_ i: Int) -> _AnyTensorElement
    var _count: Int { get }
}

/// Types that can be elements of tensors.
protocol TensorElement : _AnyTensorElement {
    /// Every `TensorElement` is a balanced tree of zero or more
    /// `TensorElement`s, with `Scalar` instances at the leaves.
    ///
    /// The default Scalar type is `Self`.
    associatedtype Scalar: TensorElement = Self
        where Scalar._Element == Never

    associatedtype _Element = Never
    func _subscript(_ i: Int) -> _Element
}

extension TensorElement where _Element == Never {
    func _anySubscript(_ i: Int) -> _AnyTensorElement {
        fatalError()
    }
    
    func _subscript(_ i: Int) -> Never {
        fatalError()
    }
    
    var _count: Int { 0 }
}

extension TensorElement where _Element: TensorElement {
    typealias Element = _Element
    
    subscript(i: Int) -> Element { _subscript(i) }
    var count: Int { _count }
    
    func _anySubscript(_ i: Int) -> _AnyTensorElement {
        return self[i]
    }    
}

extension Int : TensorElement {}
extension UInt : TensorElement {}
extension Float : TensorElement {}
extension Double : TensorElement {}

struct AnyTensorElement<Scalar: TensorElement> : TensorElement
    where Scalar._Element == Never
{
    typealias Scalar = Scalar
    typealias _Element = AnyTensorElement<Scalar>

    private let value: _AnyTensorElement
    
    init<Base: TensorElement>(_ value: Base)
    where Base.Scalar == Scalar {
        self.value = value
    }

    private init(value: _AnyTensorElement) {
        self.value = value
    }
    
    func _subscript(_ i: Int) -> AnyTensorElement<Scalar> {
        .init(value: value._anySubscript(i))
    }

    var _count: Int { value._count }
}

