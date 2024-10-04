//
//  Strings+hex.swift
//  LocationTracker
//
//  Created by Thibaud David on 03/10/2024.
//

import Foundation

extension String {
    public func toHextData() -> Data {
        // Prepend '0' if the hex string has an odd number of characters
        let formattedHexString = self.count % 2 != 0 ? "0" + self : self

        var data = Data()

        // Process each byte
        for i in stride(from: 0, to: formattedHexString.count, by: 2) {
            let startIndex = formattedHexString.index(formattedHexString.startIndex, offsetBy: i)
            let endIndex = formattedHexString.index(startIndex, offsetBy: 2)
            let hexByte = String(formattedHexString[startIndex..<endIndex])

            if let byte = UInt8(hexByte, radix: 16) {
                data.append(byte)
            } else {
                // Optionally handle the parsing error
                print("Error converting \(hexByte) to byte")
                break
            }
        }

        return data
    }
}
