//
//  JsonSchemaTests.swift
//
//  Copyright © 2022 Sage Bionetworks. All rights reserved.
//
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
//
// 1.  Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// 2.  Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation and/or
// other materials provided with the distribution.
//
// 3.  Neither the name of the copyright holder(s) nor the names of any contributors
// may be used to endorse or promote products derived from this software without
// specific prior written permission. No license is granted to the trademarks of
// the copyright holders even if such marks are included in this software.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

@testable import MotorControlV1
import XCTest
import JsonModel

class JsonSchemaTests: XCTestCase {
    
    override func setUp() {
        super.setUp()

        // Use a statically defined timezone.
        ISO8601TimestampFormatter.timeZone = TimeZone(secondsFromGMT: Int(-2.5 * 60 * 60))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testMCTTappingSample() {
        
        guard let object = MCTTappingSample.examples().first else {
            XCTFail("Failed to return an example of a tapping sample.")
            return
        }
        
        let factory = MCTFactory()
        let encoder = factory.createJSONEncoder()
        let decoder = factory.createJSONDecoder()
        
        do {
            let json = try encoder.encode(object)
            let decodedObject = try decoder.decode(MCTTappingSample.self, from: json)
            XCTAssertEqual(object, decodedObject)
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testMCTTappingResultObject() {
        
        guard let object = MCTTappingResultObject.examples().first else {
            XCTFail("Failed to return an example of a tapping sample.")
            return
        }
        
        let factory = MCTFactory()
        let encoder = factory.createJSONEncoder()
        let decoder = factory.createJSONDecoder()
        
        do {
            let json = try encoder.encode(object)
            let decodedObject = try decoder.decode(MCTTappingResultObject.self, from: json)
            
            XCTAssertEqual(object.identifier, decodedObject.identifier)
            XCTAssertEqual(object.serializableType, decodedObject.serializableType)
            XCTAssertEqual(object.startDate.timeIntervalSinceReferenceDate, decodedObject.startDate.timeIntervalSinceReferenceDate, accuracy: 1)
            XCTAssertEqual(object.endDate.timeIntervalSinceReferenceDate, decodedObject.endDate.timeIntervalSinceReferenceDate, accuracy: 1)
            XCTAssertEqual(object.tapCount, decodedObject.tapCount)
            XCTAssertEqual(object.buttonRect1, decodedObject.buttonRect1)
            XCTAssertEqual(object.buttonRect2, decodedObject.buttonRect2)
            XCTAssertEqual(object.stepViewSize, decodedObject.stepViewSize)
            XCTAssertEqual(object.samples, decodedObject.samples)
            
        } catch let err {
            XCTFail("Failed to decode/encode object: \(err)")
            return
        }
    }
    
    func testBuildDocs() {
        let factory = MCTFactory()
        let docs = JsonDocumentBuilder(factory: factory)
        do {
            let _ = try docs.buildSchemas()
        } catch {
            XCTFail("Failed to build JSON schema docs.")
        }
    }
}
