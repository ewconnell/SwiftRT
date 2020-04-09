//******************************************************************************
// Copyright 2020 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import Foundation

// gyb utility docs
// https://nshipster.com/swift-gyb/

//******************************************************************************
//
// DO NOT EDIT. THIS FILE IS GENERATED FROM .swift.gyb file
//
//******************************************************************************

//==============================================================================
/// array
/// Return a new tensor of given shape and type, without initializing entries.
/// - Parameters:
///  - elements: a collection of elements used to initialize storage
///  - shape: Int or tuple of Int describing the dimensions of the array
///  - dtype: data-type, optional
///    Desired output data-type for the array, e.g, Int8. Default is DType.
///  - order: { .C, .F }, optional, default .C
///    Whether to store multi-dimensional data in row-major (C-style)
///    or column-major (Fortran-style) order in memory.
/// - Returns: Tensor of uninitialized (arbitrary) data of the given shape,
///   dtype, and order. Elements will not be initialized.

//------------------------------------------------------------------------------
// Rank1 array from a flat collection where shape is implied by count
// same type
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor1<C.Element> where C: Collection
{
    Tensor1(elements, Shape1(elements.count), order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor1<DType> where C: Collection, C.Element: BinaryInteger
{
    Tensor1(elements, Shape1(elements.count), order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor1<Element>
    where C: Collection, C.Element: BinaryInteger, Element: Numeric
{
    Tensor1<Element>(elements, Shape1(elements.count), order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor1<Element>
    where C: Collection, C.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    Tensor1<Element>(elements, Shape1(elements.count), order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor1<Element>
    where C: Collection, C.Element: BinaryFloatingPoint, Element: BinaryFloatingPoint
{
    Tensor1<Element>(elements, Shape1(elements.count), order: order)
}

//------------------------------------------------------------------------------
// Rank2 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape2.Tuple,
    order: StorageOrder = .C
) -> Tensor2<C.Element> where C: Collection
{
    Tensor2(elements, Shape2(shape), order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape2.Tuple,
    order: StorageOrder = .C
) -> Tensor2<DType> where C: Collection, C.Element: BinaryInteger
{
    Tensor2(elements, Shape2(shape), order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape2.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor2<Element>
    where C: Collection, C.Element: BinaryInteger, Element: Numeric
{
    Tensor2<Element>(elements, Shape2(shape), order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape2.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor2<Element>
    where C: Collection, C.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    Tensor2<Element>(elements, Shape2(shape), order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape2.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor2<Element>
    where C: Collection, C.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    Tensor2<Element>(elements, Shape2(shape), order: order)
}

//------------------------------------------------------------------------------
// Rank3 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape3.Tuple,
    order: StorageOrder = .C
) -> Tensor3<C.Element> where C: Collection
{
    Tensor3(elements, Shape3(shape), order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape3.Tuple,
    order: StorageOrder = .C
) -> Tensor3<DType> where C: Collection, C.Element: BinaryInteger
{
    Tensor3(elements, Shape3(shape), order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape3.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor3<Element>
    where C: Collection, C.Element: BinaryInteger, Element: Numeric
{
    Tensor3<Element>(elements, Shape3(shape), order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape3.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor3<Element>
    where C: Collection, C.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    Tensor3<Element>(elements, Shape3(shape), order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape3.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor3<Element>
    where C: Collection, C.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    Tensor3<Element>(elements, Shape3(shape), order: order)
}

//------------------------------------------------------------------------------
// Rank4 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape4.Tuple,
    order: StorageOrder = .C
) -> Tensor4<C.Element> where C: Collection
{
    Tensor4(elements, Shape4(shape), order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape4.Tuple,
    order: StorageOrder = .C
) -> Tensor4<DType> where C: Collection, C.Element: BinaryInteger
{
    Tensor4(elements, Shape4(shape), order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape4.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor4<Element>
    where C: Collection, C.Element: BinaryInteger, Element: Numeric
{
    Tensor4<Element>(elements, Shape4(shape), order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape4.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor4<Element>
    where C: Collection, C.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    Tensor4<Element>(elements, Shape4(shape), order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape4.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor4<Element>
    where C: Collection, C.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    Tensor4<Element>(elements, Shape4(shape), order: order)
}

//------------------------------------------------------------------------------
// Rank5 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape5.Tuple,
    order: StorageOrder = .C
) -> Tensor5<C.Element> where C: Collection
{
    Tensor5(elements, Shape5(shape), order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape5.Tuple,
    order: StorageOrder = .C
) -> Tensor5<DType> where C: Collection, C.Element: BinaryInteger
{
    Tensor5(elements, Shape5(shape), order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape5.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor5<Element>
    where C: Collection, C.Element: BinaryInteger, Element: Numeric
{
    Tensor5<Element>(elements, Shape5(shape), order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape5.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor5<Element>
    where C: Collection, C.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    Tensor5<Element>(elements, Shape5(shape), order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape5.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor5<Element>
    where C: Collection, C.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    Tensor5<Element>(elements, Shape5(shape), order: order)
}

//------------------------------------------------------------------------------
// Rank6 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape6.Tuple,
    order: StorageOrder = .C
) -> Tensor6<C.Element> where C: Collection
{
    Tensor6(elements, Shape6(shape), order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    _ shape: Shape6.Tuple,
    order: StorageOrder = .C
) -> Tensor6<DType> where C: Collection, C.Element: BinaryInteger
{
    Tensor6(elements, Shape6(shape), order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape6.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor6<Element>
    where C: Collection, C.Element: BinaryInteger, Element: Numeric
{
    Tensor6<Element>(elements, Shape6(shape), order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape6.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor6<Element>
    where C: Collection, C.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    Tensor6<Element>(elements, Shape6(shape), order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    _ shape: Shape6.Tuple,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor6<Element>
    where C: Collection, C.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    Tensor6<Element>(elements, Shape6(shape), order: order)
}


//------------------------------------------------------------------------------
// Rank2 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor2<C.Element.Element>
    where
    C: Collection,
    C.Element: Collection
{
    let shape = Shape2(
        elements.count,
        elements.first!.count)

    let flatElements = elements.joined()
    return Tensor2<C.Element.Element>(
        flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor2<DType>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: BinaryInteger
{
    let shape = Shape2(
        elements.count,
        elements.first!.count)

    let flatElements = elements.joined()
    return Tensor2<DType>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor2<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: BinaryInteger, Element: Numeric
{
    let shape = Shape2(
        elements.count,
        elements.first!.count)

    let flatElements = elements.joined()
    return Tensor2<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor2<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    let shape = Shape2(
        elements.count,
        elements.first!.count)

    let flatElements = elements.joined()
    return Tensor2<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor2<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    let shape = Shape2(
        elements.count,
        elements.first!.count)

    let flatElements = elements.joined()
    return Tensor2<Element>(flatElements, shape, order: order)
}

//------------------------------------------------------------------------------
// Rank3 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor3<C.Element.Element.Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection
{
    let shape = Shape3(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count)

    let flatElements = elements.joined().joined()
    return Tensor3<C.Element.Element.Element>(
        flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor3<DType>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: BinaryInteger
{
    let shape = Shape3(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count)

    let flatElements = elements.joined().joined()
    return Tensor3<DType>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor3<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: BinaryInteger, Element: Numeric
{
    let shape = Shape3(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count)

    let flatElements = elements.joined().joined()
    return Tensor3<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor3<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    let shape = Shape3(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count)

    let flatElements = elements.joined().joined()
    return Tensor3<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor3<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    let shape = Shape3(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count)

    let flatElements = elements.joined().joined()
    return Tensor3<Element>(flatElements, shape, order: order)
}

//------------------------------------------------------------------------------
// Rank4 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor4<C.Element.Element.Element.Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection
{
    let shape = Shape4(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined()
    return Tensor4<C.Element.Element.Element.Element>(
        flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor4<DType>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: BinaryInteger
{
    let shape = Shape4(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined()
    return Tensor4<DType>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor4<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: BinaryInteger, Element: Numeric
{
    let shape = Shape4(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined()
    return Tensor4<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor4<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    let shape = Shape4(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined()
    return Tensor4<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor4<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    let shape = Shape4(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined()
    return Tensor4<Element>(flatElements, shape, order: order)
}

//------------------------------------------------------------------------------
// Rank5 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor5<C.Element.Element.Element.Element.Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection
{
    let shape = Shape5(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined()
    return Tensor5<C.Element.Element.Element.Element.Element>(
        flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor5<DType>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: BinaryInteger
{
    let shape = Shape5(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined()
    return Tensor5<DType>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor5<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: BinaryInteger, Element: Numeric
{
    let shape = Shape5(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined()
    return Tensor5<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor5<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    let shape = Shape5(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined()
    return Tensor5<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor5<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    let shape = Shape5(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined()
    return Tensor5<Element>(flatElements, shape, order: order)
}

//------------------------------------------------------------------------------
// Rank6 shaped array from a flat collection
// same type
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor6<C.Element.Element.Element.Element.Element.Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: Collection
{
    let shape = Shape6(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count,
        elements.first!.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined().joined()
    return Tensor6<C.Element.Element.Element.Element.Element.Element>(
        flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> DType
@inlinable public func array<C>(
    _ elements: C,
    order: StorageOrder = .C
) -> Tensor6<DType>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element.Element: BinaryInteger
{
    let shape = Shape6(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count,
        elements.first!.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined().joined()
    return Tensor6<DType>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element integer -> Element
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor6<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element.Element: BinaryInteger, Element: Numeric
{
    let shape = Shape6(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count,
        elements.first!.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined().joined()
    return Tensor6<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element integer
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor6<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element.Element: BinaryFloatingPoint, Element: BinaryInteger
{
    let shape = Shape6(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count,
        elements.first!.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined().joined()
    return Tensor6<Element>(flatElements, shape, order: order)
}

/// implicitly casts from C.Element float -> Element float
@inlinable public func array<C, Element>(
    _ elements: C,
    dtype: Element.Type,
    order: StorageOrder = .C
) -> Tensor6<Element>
    where
    C: Collection,
    C.Element: Collection,
    C.Element.Element: Collection,
    C.Element.Element.Element: Collection,
    C.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element: Collection,
    C.Element.Element.Element.Element.Element.Element: BinaryFloatingPoint,
    Element: BinaryFloatingPoint
{
    let shape = Shape6(
        elements.count,
        elements.first!.count,
        elements.first!.first!.count,
        elements.first!.first!.first!.count,
        elements.first!.first!.first!.first!.count,
        elements.first!.first!.first!.first!.first!.count)

    let flatElements = elements.joined().joined().joined().joined().joined()
    return Tensor6<Element>(flatElements, shape, order: order)
}
