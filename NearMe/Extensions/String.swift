//
//  String.swift
//  NearMe
//
//  Created by Sameer  on 19/08/25.
//

import Foundation

extension String {
    
    var formatPhoneForCall: String {
        self.replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "+", with: "")
    }
}
