//
//  PhoneNumber.swift
//  SecureBlock
//
//  Created by Zach Kagin on 1/26/19.
//  Copyright © 2019 Zach Kagin. All rights reserved.
//

import UIKit
import CallKit

struct PhoneNumber: Codable, Equatable {
    
    static let kDefaultStoredPhoneNumbersKey = "kDefaultStoredPhoneNumbersKey"
    static let kDefaultStoredPhoneNumbersSuiteName = "group.com.secureBlock.shared"
    static let kCallDirectoryExtension = "kagin.SecureBlock.CallDirectoryExtension"
    static let kSupportedCountries = ["US", "CO"]
    
    let countryCode: String
    let phoneNumber: String

    /**
     Generates and returns a set of Int64 phone numbers to block based on the provided PhoneNumber and country.
     Numbers are listed without formatting, appending the country code to the number and generating all possible
     combinations of numbers to make a complete phone number.
     E.g. (US, 612 867 53) would generate numbers from 16128675300 to 16128675399.
     */
    public func generateNumbers() -> [Int64] {
        // NOTE: The 10 comes from the fact that currently supported numbers all have length 10.
        var blockedNumbers: [Int64] = []
        let remainingNumbers = 10 - phoneNumber.count
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = remainingNumbers
        for number in 0 ... Int(truncating: NSDecimalNumber(decimal: pow(10, remainingNumbers))) - 1 {
            let appendedNumber = formatter.string(from: number as NSNumber) ?? ""
            let blockedNumber = remainingNumbers == 0 ? phoneNumber : phoneNumber + appendedNumber 
            if let intNumber = Int64(countryCode + blockedNumber) {
                blockedNumbers.append(intNumber)
            }
            if countryCode != "1", let intNumber = Int64("1" + countryCode + blockedNumber) {
                // iPhones sometimes append a 1 to international numbers because they interpret them as US numbers.
                blockedNumbers.append(intNumber)
            }
        }
        return blockedNumbers.sorted()
    }

    /**
     Retrieves all numbers stored in user defaults.
     TODO: Consider using CoreData here instead.
     */
    public static func retrieveStoredNumbers() -> [PhoneNumber] {
        let userDefaults = UserDefaults(suiteName: kDefaultStoredPhoneNumbersSuiteName)
        if  let userDefaults = userDefaults,
            let storedData = userDefaults.array(forKey: PhoneNumber.kDefaultStoredPhoneNumbersKey) as? [Data] {
            return storedData.map{ try! JSONDecoder().decode(PhoneNumber.self, from: $0)}
        }
        return []
    }

    /**
     Stores all provided numbers in user defaults, overwriting anything that was provided before.
     TODO: This could be more efficient by using add/delete mechanisms instead.
     */
    public static func storeNumbers(_ numbers:[PhoneNumber]) {
        let data = numbers.map({ try! JSONEncoder().encode($0) })
        if let userDefaults = UserDefaults(suiteName: kDefaultStoredPhoneNumbersSuiteName) {
            userDefaults.set(data, forKey: PhoneNumber.kDefaultStoredPhoneNumbersKey)
            userDefaults.synchronize()
            CXCallDirectoryManager.sharedInstance.reloadExtension(withIdentifier: kCallDirectoryExtension) { (error) in
                if let error = error {
                    print("Reloading Extension Error: " + error.localizedDescription)
                } else {
                    print("Successfully Reloaded Extension")
                }
            }
        }
    }

    public static func checkBlockingEnabled(completion: @escaping (Bool) -> Void) {
        CXCallDirectoryManager.sharedInstance.getEnabledStatusForExtension(withIdentifier: kCallDirectoryExtension) { (status, error) in
            DispatchQueue.main.async {
                if (status == .enabled && error == nil) {
                    completion(true)
                    print("CallKit Enabled.")
                } else {
                    completion(false)
                    print("Status: " + String(status.rawValue))
                    print("Error: " + error.debugDescription)
                }
            }
        }
    }

    /**
     Returns an array of tuplets with information on country letter code, country name, and country phone code.
     Includes only supported countries.
     e.g. (US, United States, 1)
     e.g. (CO, Colombia, 57)
     */
    public static func countryInfo() -> [(String, String, String)] {
        if let path = Bundle.main.path(forResource: "countryInfo", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let parsedResult = jsonResult as? Array<Array<String>> {
                    let countryList = parsedResult.map{ ($0[0], $0[1], $0[2]) }.sorted(by: { $0.0 < $1.0 })
                    return countryList.filter{ PhoneNumber.kSupportedCountries.contains($0.0) }
                }
            } catch {
                return []
            }
        }
        return []
    }

    /**
     Formats a provided number into standard format, e.g. +1 (612) 867-5309. Adds *'s for missing digits.
     - Parameters:
        - countryCode: A string with the countryCode number, e.g. 1 or 57
        - phoneNumber: A string with the digits of the phone number, e.g. 6128675309.

     - Returns: A formatted number.
     */
    public static func formatNumber(countryCode: String, phoneNumber: String) -> String {
        let starsToAppend = 10 - phoneNumber.count
        var newNumber = phoneNumber + String(repeating: "*", count: starsToAppend)
        newNumber.insert("-", at: String.Index(utf16Offset: 6, in: "Swift 5"))
        newNumber.insert(" ", at: String.Index(utf16Offset: 3, in: "Swift 5"))
        newNumber.insert(")", at: String.Index(utf16Offset: 3, in: "Swift 5"))
        newNumber.insert("(", at: String.Index(utf16Offset: 0, in: "Swift 5"))
        return "+" + countryCode + " " + newNumber
    }
}
