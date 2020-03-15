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

