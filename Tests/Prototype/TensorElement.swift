// Existential type for quick-n-dirty type erasure.
protocol _AnyTensorElement {
    func _anySubscript(at i: Int) -> _AnyTensorElement
    var _count: Int { get }
}

/// Types that can be elements of tensors.
protocol TensorElement : _AnyTensorElement {
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
    func _anySubscript(at i: Int) -> _AnyTensorElement {
        fatalError()
    }
    var _count: Int { 0 }
    
    static func _subscript(_ instance: Self, at i: Int) -> Never {
        fatalError()
    }
    static func _count(_:Self) -> Int { 0 }
}

extension TensorElement where _Element: TensorElement {
    func _anySubscript(at i: Int) -> _AnyTensorElement
    {
        return self[i]
    }
    var _count: Int { count }
    
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

struct AnyTensorElement<Scalar: TensorElement> : TensorElement
    where Scalar._Element == Never
{
    typealias Scalar = Scalar
    typealias _Element = AnyTensorElement

    private let value: _AnyTensorElement
    
    init<Base: TensorElement>(_ value: Base)
    where Base.Scalar == Scalar {
        self.value = value
    }

    private init(value: _AnyTensorElement) {
        self.value = value
    }
    
    static func _subscript(_ self_: Self, at i: Int)
        -> AnyTensorElement<Scalar>
    {
        .init(value: self_.value._anySubscript(at: i))
    }

    static func _count(_ self_: Self) -> Int {
        return self_.value._count
    }
}

