/// Existential for types that can be elements of tensors.
///
/// This type should be considered an implementation detail.
protocol _AnyTensorElement {
    /// Return the element at index `i`, if `self` is logically a vector; traps
    /// otherwise.
    func _anySubscript(_ i: Int) -> _AnyTensorElement
    
    /// The number of subscriptable elements in `self` .
    var _count: Int { get }
}

/// Types that can be elements of tensors (i.e. the tensor's `Scalar` type and
/// vectors of vectors of… of that `Scalar` type)
protocol TensorElement : _AnyTensorElement {
    /// Every `TensorElement` is a balanced tree of one or more
    /// `TensorElement`s, with `Scalar` instances at the leaves.
    ///
    /// The default Scalar type is `Self`.
    associatedtype Scalar: TensorElement = Self
        where Scalar._Element == Never

    /// The type of this tensor's elements, if it is a vector.
    associatedtype _Element = Never
    
    /// Return the element at index `i`, if `self` is logically a vector; traps
    /// otherwise.
    func _subscript(_ i: Int) -> _Element
}

/// Default implementations for scalars.
extension TensorElement where _Element == Never {
    /// Traps, because `Self` is not a vector of elements.
    func _anySubscript(_ i: Int) -> _AnyTensorElement {
        fatalError("Unreachable through observable APIs.")
    }
    
    /// Traps, because `Self` is not a vector of elements.
    func _subscript(_ i: Int) -> Never {
        fatalError("Unreachable through observable APIs.")
    }
    
    /// The number of subscriptable elements in `self` (0).
    var _count: Int { 0 }
}

/// Default implementations for vectors.
extension TensorElement where _Element: TensorElement {
    typealias Element = _Element
    
    /// Returns the element at index `i`.
    subscript(i: Int) -> Element { _subscript(i) }

    /// The number of subscriptable elements in `self` (always at least 1).
    var count: Int {
        assert(_count > 0)
        return _count
    }
    
    /// Returns the element at index `i`.
    func _anySubscript(_ i: Int) -> _AnyTensorElement {
        return self[i]
    }    
}

// == Scalar Conformances ==
extension Int : TensorElement {}
extension UInt : TensorElement {}
extension Float : TensorElement {}
extension Double : TensorElement {}

/// A type-erasing wrapper for any `TensorElement` having the given `Scalar`
/// type.
struct AnyTensorElement<Scalar: TensorElement> : TensorElement
    where Scalar._Element == Never
{
    typealias Scalar = Scalar
    typealias _Element = AnyTensorElement<Scalar>

    /// The wrapped value.
    private let value: _AnyTensorElement

    /// Creates an instance with the given valuee.
    init<Base: TensorElement>(_ value: Base)
    where Base.Scalar == Scalar {
        self.value = value
    }

    /// Creates an instance with the given value.
    ///
    /// - Requires: `value`'s type conforms to `TensorElement` and its `Scalar`
    ///   type is `Self.Scalar`.
    private init(value: _AnyTensorElement) {
        self.value = value
    }
    
    /// Return the element at index `i`, if `self` is logically a vector; traps
    /// otherwise.
    func _subscript(_ i: Int) -> AnyTensorElement<Scalar> {
        .init(value: value._anySubscript(i))
    }

    /// Returns the scalar value of `self`, or `nil` if `self` is a vector.
    subscript() -> Scalar? { value as? Scalar }
    
    /// The number of subscriptable elements in `self` .
    var _count: Int { value._count }
}

extension AnyTensorElement : CustomStringConvertible {
    var description: String { String(describing: value) }
}
