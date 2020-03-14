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

/// Types that can be elements of tensors.
protocol TensorElement {
    /// Every `TensorElement` is a balanced tree of zero or more
    /// `TensorElement`s, with `Scalar` instances at the leaves.
    ///
    /// The default Scalar type is `Self`.
    associatedtype Scalar = Self

    associatedtype _Element = Never

    static func _subscript(_ instance: Self, at i: Int) -> _Element
    static func _count(_ instance: Self) -> Int
}

extension TensorElement where _Element == Never {
    static func _subscript(_ instance: Self, at i: Int) -> _Element {
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
