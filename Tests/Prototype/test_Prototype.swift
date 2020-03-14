//******************************************************************************
// Copyright 2019 Google LLC
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
import XCTest
import Foundation

class test_FixedSizeArray: XCTestCase {
    func test_all() {
        let x = Array6(0..<6)
        XCTAssert(x.elementsEqual(0..<6))
        XCTAssertEqual(x, .init(0..<6))
        XCTAssertLessThan(x, .init(1..<7))

        for i in x.indices {
            // Test removing at each position
            let d = x.removing(at: i)
            XCTAssert(d.elementsEqual([x[..<i], x[(i+1)...]].joined()))

            // Test insertion at each position
            
            // A 1-element slice of d, but with x[i] as its only element.  
            let xi = ArrayN(head: x[i], tail: d.removing(at: 0))[0...0]

            // Try reinserting the element 1 place further along (wrapping to count).
            let j = (i + 1) % d.count
            let e = d.inserting(x[i], at: j)
            XCTAssert(e.elementsEqual([d[..<j], xi, d[j...]].joined()))

            XCTAssert(type(of: x) == type(of: e))
        }
    }
}

// ======== Some functions whose disassembly to inspect ===========
func testMe2(_ a: Array2<Int>) -> Array1<Int> {
    return a.removing(at: 1)
}
func testMe3(_ a: Array3<Int>) -> Array2<Int> {
    return a.removing(at: 1)
}
func testMe4(_ a: Array4<Int>) -> Array3<Int> {
    return a.removing(at: 1)
}
func testMe6a(_ a: Array6<Int>) -> Array5<Int> {
    return a.removing(at: 4)
}

func testMe6b(_ a: Array6<Int>, i: Int) -> Array5<Int> {
    // Because i is a variable, this one has to handle all the cases, so it
    // generates more complicated (but still excellent) code.
    return a.removing(at: i)
}

func testMe7a(_ a: Array7<Int>) -> Array6<Int> {
    return a.removing(at: 6)
}

func testMe7b(_ a: Array7<Int>) -> ArrayN<Array7<Int>> {
    return a.inserting(9, at: 7)
}

func testMe7c(_ a: Array7<Int>) -> Array7<Int> {
    // How well does the sequence initializer specialize when count is static?
    return .init(a)
}

func testMe7d(_ a: Array<Int>) -> Array7<Int> {
    // How well does the sequence initializer specialize when count is dynamic?
    return .init(a)
}

func testMe2b(_ a: Array2<Int>) -> Array3<Int> {
    return a.inserting(9, at: 2)
}
