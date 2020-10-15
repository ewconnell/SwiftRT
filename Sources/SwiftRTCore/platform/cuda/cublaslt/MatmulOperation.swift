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
@_implementationOnly
import SwiftRTCuda

//==============================================================================
// MatmulOperation
public final class MatmulOperation: CustomStringConvertible {
    // properties
    public var desc: cublasLtMatmulDesc_t

    //--------------------------------------------------------------------------
    // initializers
    @inlinable public init(
        accumulatorType: MatmulAccumulatorType,
        scaleType: srtDataType
    ) {
        var temp: cublasLtMatmulDesc_t?
        cudaCheck(cublasLtMatmulDescCreate(&temp, accumulatorType.cublas, 
                                           cudaDataType(scaleType)))
        desc = temp!
    }

    @inlinable deinit {
        cudaCheck(cublasLtMatmulDescDestroy(desc))
    }

    public var description: String {
        """
        \(Self.self)
            compute: \(accumulatorType)
              scale: \(scaleType)
        pointerMode: \(pointerMode)
             transA: \(transA)
             transB: \(transB)
             transC: \(transC)
               fill: \(fill)
           epilogue: \(epilogue)
               bias: \(String(describing: bias))
        """
    }

    //--------------------------------------------------------------------------
    /// getAttribute
    @inlinable public func getAttribute<T>(
        _ attr: cublasLtMatmulDescAttributes_t, 
        _ value: inout T
    ) {
        var written = 0
        cudaCheck(cublasLtMatmulDescGetAttribute(
            desc, attr, &value, MemoryLayout.size(ofValue: value), &written))
    }

    /// setAttribute
    @inlinable public func setAttribute<T>(
        _ attr: cublasLtMatmulDescAttributes_t,
         _ value: T
    ) {
        var newValue = value
        cudaCheck(cublasLtMatmulDescSetAttribute(
            desc, attr, &newValue, MemoryLayout.size(ofValue: newValue)))
    }

    //--------------------------------------------------------------------------
    /// Defines data type used for multiply and accumulate operations, 
    /// and the accumulator during the matrix multiplication
    @inlinable public var accumulatorType: MatmulAccumulatorType {
        get {
            var value = CUBLAS_COMPUTE_32F
            getAttribute(CUBLASLT_MATMUL_DESC_COMPUTE_TYPE, &value)
            return MatmulAccumulatorType(value)
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_COMPUTE_TYPE, newValue.cublas)
        }
    }

    //--------------------------------------------------------------------------
    /// Defines the data type of the scaling factors alpha and beta.
    /// The accumulator value and the value from matrix C are typically
    /// converted to scale type before final scaling. Value is then
    /// converted from scale type to the type of matrix D before
    /// storing in memory. The default is the same as `accumulatorType`
    @inlinable public var scaleType: srtDataType {
        get {
            var value = srtDataType(0)
            getAttribute(CUBLASLT_MATMUL_DESC_SCALE_TYPE, &value)
            return value
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_SCALE_TYPE, newValue)
        }
    }

    //--------------------------------------------------------------------------
    /// Specifies alpha and beta are passed by reference, whether they
    /// are scalars on the host or on the device, or device vectors. 
    /// Default value is `host`
    @inlinable public var pointerMode: MatmulPointerMode {
        get {
            var value = CUBLASLT_POINTER_MODE_HOST
            getAttribute(CUBLASLT_MATMUL_DESC_POINTER_MODE, &value)
            return MatmulPointerMode(value)
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_POINTER_MODE, newValue.cublas)
        }
    }

    //--------------------------------------------------------------------------
    /// Specifies the type of transformation operation that
    /// should be performed on matrix A. Default value is `noTranspose`
    @inlinable public var transA: TransposeOp {
        get {
            var value = CUBLAS_OP_N
            getAttribute(CUBLASLT_MATMUL_DESC_TRANSA, &value)
            return TransposeOp(value)
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_TRANSA, newValue.cublas)
        }
    }

    //--------------------------------------------------------------------------
    /// Specifies the type of transformation operation that
    /// should be performed on matrix B. Default value is `noTranspose`
    @inlinable public var transB: TransposeOp {
        get {
            var value = CUBLAS_OP_N
            getAttribute(CUBLASLT_MATMUL_DESC_TRANSB, &value)
            return TransposeOp(value)
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_TRANSB, newValue.cublas)
        }
    }

    //--------------------------------------------------------------------------
    /// Specifies the type of transformation operation that
    /// should be performed on matrix C. Default value is `noTranspose`
    @inlinable public var transC: TransposeOp {
        get {
            var value = CUBLAS_OP_N
            getAttribute(CUBLASLT_MATMUL_DESC_TRANSC, &value)
            return TransposeOp(value)
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_TRANSC, newValue.cublas)
        }
    }

    //--------------------------------------------------------------------------
    /// Indicates whether the lower or upper part of the dense matrix
    /// was filled, and consequently should be used by the function. 
    /// Default value is 'full'
    @inlinable public var fill: MatmulFillMode {
        get {
            var value = CUBLAS_FILL_MODE_FULL
            getAttribute(CUBLASLT_MATMUL_DESC_FILL_MODE, &value)
            return MatmulFillMode(value)
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_FILL_MODE, newValue.cublas)
        }
    }

    //--------------------------------------------------------------------------
    /// specifies the post processing step to perform
    /// Default value is `none`
    @inlinable public var epilogue: MatmulEpilogue {
        get {
            var value = CUBLASLT_EPILOGUE_DEFAULT
            getAttribute(CUBLASLT_MATMUL_DESC_EPILOGUE, &value)
            return MatmulEpilogue(value)
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_EPILOGUE, newValue.cublas)
        }
    }

    //--------------------------------------------------------------------------
    /// Bias vector pointer in the device memory used by epilogue
    @inlinable public var bias: UnsafeRawPointer? {
        get {
            var value = UnsafeRawPointer(nil)
            getAttribute(CUBLASLT_MATMUL_DESC_BIAS_POINTER, &value)
            return value
        }
        set {
            setAttribute(CUBLASLT_MATMUL_DESC_BIAS_POINTER, newValue)
        }
    }
}

//==============================================================================
/// MatmulAccumulatorType
public enum MatmulAccumulatorType {
    /// Float16 default
    case accumulator16F
    /// Float16 precise 
    case accumulator16FPrecise
    /// Float default
    case accumulator32F
    /// Float precise
    case accumulator32FPrecise
    /// Float fast, allows down-converting inputs to half or TF32
    case accumulator32FFast16F
    /// Float fast, allows down-converting inputs to bfloat16 or TF32
    case accumulator32FFast16BF
    /// Float fast, allows down-converting inputs to TF32
    case accumulator32FFastTF32
    /// Double default
    case accumulator64F
    /// Double precise
    case accumulator64FPrecise
    /// Int32 default
    case accumulator32I
    /// Int32 precise
    case accumulator32IPrecise
}

extension MatmulAccumulatorType {
    @inlinable public init(_ type: cublasComputeType_t) {
        switch type {
        case CUBLAS_COMPUTE_16F: self = .accumulator16F
        case CUBLAS_COMPUTE_16F_PEDANTIC: self = .accumulator16FPrecise
        case CUBLAS_COMPUTE_32F: self = .accumulator32F
        case CUBLAS_COMPUTE_32F_PEDANTIC: self = .accumulator32FPrecise
        case CUBLAS_COMPUTE_32F_FAST_16F: self = .accumulator32FFast16F
        case CUBLAS_COMPUTE_32F_FAST_16BF: self = .accumulator32FFast16BF
        case CUBLAS_COMPUTE_32F_FAST_TF32: self = .accumulator32FFastTF32
        case CUBLAS_COMPUTE_64F: self = .accumulator64F
        case CUBLAS_COMPUTE_64F_PEDANTIC: self = .accumulator64FPrecise
        case CUBLAS_COMPUTE_32I: self = .accumulator32I
        case CUBLAS_COMPUTE_32I_PEDANTIC: self = .accumulator32IPrecise
        default: fatalError("unrecognized cublasComputeType_t")
        }
    }

    @inlinable public var cublas: cublasComputeType_t {
        let types: [MatmulAccumulatorType: cublasComputeType_t] = [
            .accumulator16F: CUBLAS_COMPUTE_16F,
            .accumulator16FPrecise: CUBLAS_COMPUTE_16F_PEDANTIC,
            .accumulator32F: CUBLAS_COMPUTE_32F,
            .accumulator32FPrecise: CUBLAS_COMPUTE_32F_PEDANTIC,
            .accumulator32FFast16F: CUBLAS_COMPUTE_32F_FAST_16F,
            .accumulator32FFast16BF: CUBLAS_COMPUTE_32F_FAST_16BF,
            .accumulator32FFastTF32: CUBLAS_COMPUTE_32F_FAST_TF32,
            .accumulator64F: CUBLAS_COMPUTE_64F,
            .accumulator64FPrecise: CUBLAS_COMPUTE_64F_PEDANTIC,
            .accumulator32I: CUBLAS_COMPUTE_32I,
            .accumulator32IPrecise: CUBLAS_COMPUTE_32I_PEDANTIC,
        ]        
        return types[self]!
    }
}

//==============================================================================
/// MatmulPointerMode
public enum MatmulPointerMode {
    case host, device, deviceVector, alphaDeviceVectorBetaZero
}

extension MatmulPointerMode {
    @inlinable public init(_ type: cublasLtPointerMode_t) {
        switch type {
        case CUBLASLT_POINTER_MODE_HOST: self = .host
        case CUBLASLT_POINTER_MODE_DEVICE: self = .device
        case CUBLASLT_POINTER_MODE_DEVICE_VECTOR: self = .deviceVector
        case CUBLASLT_POINTER_MODE_ALPHA_DEVICE_VECTOR_BETA_ZERO:
            self = .alphaDeviceVectorBetaZero
        default: fatalError("unrecognized type")
        }
    }

    @inlinable public var cublas: cublasLtPointerMode_t {
        let types: [MatmulPointerMode: cublasLtPointerMode_t] = [
            .host: CUBLASLT_POINTER_MODE_HOST,
            .device: CUBLASLT_POINTER_MODE_DEVICE,
            .deviceVector: CUBLASLT_POINTER_MODE_DEVICE_VECTOR,
            .alphaDeviceVectorBetaZero:
                 CUBLASLT_POINTER_MODE_ALPHA_DEVICE_VECTOR_BETA_ZERO,
        ]        
        return types[self]!
    }
}


//==============================================================================
/// MatmulPointerModeOptions
public struct MatmulPointerModeOptions: OptionSet, CustomStringConvertible {
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ value: cublasLtPointerModeMask_t) {
        self.rawValue = value.rawValue
    }
    public let rawValue: UInt32

    public static let host = MatmulPointerModeOptions(CUBLASLT_POINTER_MODE_MASK_HOST)
    public static let device = MatmulPointerModeOptions(CUBLASLT_POINTER_MODE_MASK_DEVICE)
    public static let deviceVector = MatmulPointerModeOptions(CUBLASLT_POINTER_MODE_MASK_DEVICE_VECTOR)
    public static let alphaDeviceVectorBetaZero = MatmulPointerModeOptions(
        CUBLASLT_POINTER_MODE_MASK_ALPHA_DEVICE_VECTOR_BETA_ZERO)
    public static let all: MatmulPointerModeOptions = [
        .host, .device, .deviceVector, .alphaDeviceVectorBetaZero
    ]

    public var description: String {
        var string = "["

        if contains(.all) {
            string += ".all"
        } else {
            if contains(.host) { string += ".host, " }
            if contains(.device) { string += ".device, " }
            if contains(.deviceVector) { string += ".deviceVector, " }
            if contains(.alphaDeviceVectorBetaZero) { string += ".alphaDeviceVectorBetaZero, " }

            // trim
            if let index = string.lastIndex(of: ",") {
                string = String(string[..<index])
            }
        }
        return string + "]"            
    }
}

//==============================================================================
/// MatmulFillMode
/// The type indicates which part (lower or upper) of the dense matrix was
/// filled and consequently should be used by the function. Its values
/// correspond to Fortran characters ‘L’ or ‘l’ (lower) and
/// ‘U’ or ‘u’ (upper) that are often used as parameters to
/// legacy BLAS implementations.
public enum MatmulFillMode {
    /// the lower part of the matrix is filled
    case lower
    /// the upper part of the matrix is filled
    case upper
    /// the full matrix is filled
    case full
}

extension MatmulFillMode {
    @inlinable public init(_ type: cublasFillMode_t) {
        switch type {
        case CUBLAS_FILL_MODE_LOWER: self = .lower
        case CUBLAS_FILL_MODE_UPPER: self = .upper
        case CUBLAS_FILL_MODE_FULL: self = .full
        default: fatalError("unrecognized type")
        }
    }

    @inlinable public var cublas: cublasFillMode_t {
        let types: [MatmulFillMode: cublasFillMode_t] = [
            .lower: CUBLAS_FILL_MODE_LOWER,
            .upper: CUBLAS_FILL_MODE_UPPER,
            .full: CUBLAS_FILL_MODE_FULL,
        ]        
        return types[self]!
    }
}

//==============================================================================
/// MatmulEpilogue
///
/// An enum type to set matmul postprocessing options
public enum MatmulEpilogue {
    case none
    case relu
    case bias
    case biasRelu
}

extension MatmulEpilogue {
    @inlinable public init(_ type: cublasLtEpilogue_t) {
        switch type {
        case CUBLASLT_EPILOGUE_DEFAULT: self = .none
        case CUBLASLT_EPILOGUE_RELU: self = .relu
        case CUBLASLT_EPILOGUE_BIAS: self = .bias
        case CUBLASLT_EPILOGUE_RELU_BIAS: self = .biasRelu
        default: fatalError("unrecognized type")
        }
    }

    @inlinable public var cublas: cublasLtEpilogue_t {
        let types: [MatmulEpilogue: cublasLtEpilogue_t] = [
            .none: CUBLASLT_EPILOGUE_DEFAULT,
            .relu: CUBLASLT_EPILOGUE_RELU,
            .bias: CUBLASLT_EPILOGUE_BIAS,
            .biasRelu: CUBLASLT_EPILOGUE_RELU_BIAS,
        ]        
        return types[self]!
    }
}

//==============================================================================
/// MatmulEpilogueOptions
///
/// An option set used to specify algorithm search preferences
public struct MatmulEpilogueOptions: OptionSet, CustomStringConvertible {
    public init(rawValue: UInt32) { self.rawValue = rawValue }
    public init(_ value: cublasLtEpilogue_t) {
        self.rawValue = value.rawValue
    }
    public let rawValue: UInt32

    public static let none = MatmulEpilogueOptions(CUBLASLT_EPILOGUE_DEFAULT)
    public static let relu = MatmulEpilogueOptions(CUBLASLT_EPILOGUE_RELU)
    public static let bias = MatmulEpilogueOptions(CUBLASLT_EPILOGUE_BIAS)
    public static let biasRelu = MatmulEpilogueOptions(CUBLASLT_EPILOGUE_RELU_BIAS)

    public var description: String {
        var string = "["

        if contains(.none)  { string += ".none, " }
        if contains(.bias) { string += ".bias, " }
        if contains(.relu) { string += ".relu, " }

        // trim
        if let index = string.lastIndex(of: ",") {
            string = String(string[..<index])
        }
        return string + "]"            
    }
}
