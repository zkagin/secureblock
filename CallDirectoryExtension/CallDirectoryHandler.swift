//
//  CallDirectoryHandler.swift
//  CallDirectoryExtension
//
//  Created by Zach Kagin on 1/26/19.
//  Copyright © 2019 Zach Kagin. All rights reserved.
//

import Foundation
import CallKit

class CallDirectoryHandler: CXCallDirectoryProvider {

    override func beginRequest(with context: CXCallDirectoryExtensionContext) {
        print ("beginRequest Called")
        context.delegate = self
        // TODO: For performance improvement, this should check whether this is an incremental update or not, and then
        // provide only the delta between the last check and this one.
        if context.isIncremental {
            context.removeAllBlockingEntries()
            context.removeAllIdentificationEntries()
        }
        let allPhoneNumbers: [CXCallDirectoryPhoneNumber] = PhoneNumber.retrieveStoredNumbers().flatMap{ $0.generateNumbers() }.sorted()
        print("All Phone Numbers:" + allPhoneNumbers.description)
        for phoneNumber in allPhoneNumbers {
            context.addBlockingEntry(withNextSequentialPhoneNumber: phoneNumber)
        }

//        context.addBlockingEntry(withNextSequentialPhoneNumber: 573127662155)
//        context.addBlockingEntry(withNextSequentialPhoneNumber: 1573127662155)

        context.completeRequest { (expired) in
            print("context.completeRequest Completed. Expired = " + String(expired))
        }
    }
}

extension CallDirectoryHandler: CXCallDirectoryExtensionContextDelegate {

    func requestFailed(for extensionContext: CXCallDirectoryExtensionContext, withError error: Error) {
        // An error occurred while adding blocking or identification entries, check the NSError for details.
        // For Call Directory error codes, see the CXErrorCodeCallDirectoryManagerError enum in <CallKit/CXError.h>.
        //
        // This may be used to store the error details in a location accessible by the extension's containing app, so that the
        // app may be notified about errors which occured while loading data even if the request to load data was initiated by
        // the user in Settings instead of via the app itself.
        print("CallKit requestFailed. Error: " + error.localizedDescription)
    }

}
