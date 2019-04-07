//
//  PhoneNumberTests.swift
//  SecureBlockTests
//
//  Created by Zach Kagin on 1/26/19.
//  Copyright © 2019 Zach Kagin. All rights reserved.
//

import XCTest

class PhoneNumberTests: XCTestCase {
    
    func testCountryInfo() {
        let countryInfo = PhoneNumber.countryInfo()
        XCTAssertNotNil(countryInfo)
        XCTAssertEqual(countryInfo.count, 2)
        XCTAssertEqual(countryInfo[1].0, "US")
    }

    func testFormatNumber() {
        XCTAssertEqual(PhoneNumber.formatNumber(countryCode: "1", phoneNumber: "1234567890"), "+1 (123) 456-7890")
        XCTAssertEqual(PhoneNumber.formatNumber(countryCode: "1", phoneNumber: "12345678"), "+1 (123) 456-78**")
        XCTAssertEqual(PhoneNumber.formatNumber(countryCode: "888", phoneNumber: "1234567890"), "+888 (123) 456-7890")
        XCTAssertEqual(PhoneNumber.formatNumber(countryCode: "888", phoneNumber: "12345678"), "+888 (123) 456-78**")
        XCTAssertEqual(PhoneNumber.formatNumber(countryCode: "1", phoneNumber: "23"), "+1 (23*) ***-****")
    }

    func testGenerateSingleUSNumber() {
        let phoneNumber = PhoneNumber(countryCode: "1", phoneNumber: "1234567890")
        let generatedNumbers = phoneNumber.generateNumbers()
        XCTAssertEqual(generatedNumbers.count, 1)
        XCTAssertEqual(generatedNumbers[0], 11234567890)
    }

    func testGenerateSingleNonUSNumber() {
        let phoneNumber = PhoneNumber(countryCode: "888", phoneNumber: "1234567890")
        let generatedNumbers = phoneNumber.generateNumbers()
        XCTAssertEqual(generatedNumbers.count, 2)
        XCTAssertEqual(generatedNumbers[0], 8881234567890)
        XCTAssertEqual(generatedNumbers[1], 18881234567890)
    }

    func testGenerateNumbers200() {
        let phoneNumber = PhoneNumber(countryCode: "888", phoneNumber: "12345678")
        let generatedNumbers = phoneNumber.generateNumbers()
        XCTAssertEqual(generatedNumbers.count, 200)
        XCTAssertEqual(generatedNumbers[0], 8881234567800)
        XCTAssertEqual(generatedNumbers[5], 8881234567805)
        XCTAssertEqual(generatedNumbers[37], 8881234567837)
        XCTAssertEqual(generatedNumbers[99], 8881234567899)
        XCTAssertEqual(generatedNumbers[100], 18881234567800)
        XCTAssertEqual(generatedNumbers[105], 18881234567805)
        XCTAssertEqual(generatedNumbers[137], 18881234567837)
        XCTAssertEqual(generatedNumbers[199], 18881234567899)
    }

    func testGenerateNumbers2000() {
        let phoneNumber = PhoneNumber(countryCode: "888", phoneNumber: "1234567")
        let generatedNumbers = phoneNumber.generateNumbers()
        XCTAssertEqual(generatedNumbers.count, 2000)
        XCTAssertEqual(generatedNumbers[0], 8881234567000)
        XCTAssertEqual(generatedNumbers[5], 8881234567005)
        XCTAssertEqual(generatedNumbers[37], 8881234567037)
        XCTAssertEqual(generatedNumbers[999], 8881234567999)
        XCTAssertEqual(generatedNumbers[1000], 18881234567000)
        XCTAssertEqual(generatedNumbers[1005], 18881234567005)
        XCTAssertEqual(generatedNumbers[1037], 18881234567037)
        XCTAssertEqual(generatedNumbers[1999], 18881234567999)
    }

    func testGenerateNumberCounts() {
        XCTAssertEqual(PhoneNumber(countryCode: "1", phoneNumber: "1234567890").generateNumbers().count, 1)
        XCTAssertEqual(PhoneNumber(countryCode: "888", phoneNumber: "1234567890").generateNumbers().count, 2)
        XCTAssertEqual(PhoneNumber(countryCode: "1", phoneNumber: "123456789").generateNumbers().count, 10)
        XCTAssertEqual(PhoneNumber(countryCode: "888", phoneNumber: "123456789").generateNumbers().count, 20)
        XCTAssertEqual(PhoneNumber(countryCode: "1", phoneNumber: "12345678").generateNumbers().count, 100)
        XCTAssertEqual(PhoneNumber(countryCode: "888", phoneNumber: "12345678").generateNumbers().count, 200)
        XCTAssertEqual(PhoneNumber(countryCode: "1", phoneNumber: "1234567").generateNumbers().count, 1000)
        XCTAssertEqual(PhoneNumber(countryCode: "888", phoneNumber: "1234567").generateNumbers().count, 2000)
        XCTAssertEqual(PhoneNumber(countryCode: "1", phoneNumber: "123456").generateNumbers().count, 10000)
        XCTAssertEqual(PhoneNumber(countryCode: "888", phoneNumber: "123456").generateNumbers().count, 20000)
    }

    func testGenerateNumberTime() {
        measure {
            let _ = PhoneNumber(countryCode: "888", phoneNumber: "1234567").generateNumbers()
        }
    }

    func testGenerateNumberTime20000() {
        measure {
            let _ = PhoneNumber(countryCode: "888", phoneNumber: "123456").generateNumbers()
        }
    }
}
