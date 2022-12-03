//
//  JsonSchemaTests.swift
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
