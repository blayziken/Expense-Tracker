//
//  Transaction.swift
//  ExpenseTracker
//
//  Created by Blaze on 26/11/2023.
//

import Foundation

struct Transaction: Identifiable, Decodable {
    let id: Int
    let date: String
    let institution: String
    let account: String
    var merchant: String
    let amount: Double
    let type: TransactionType.RawValue
    var categoryId: Int
    var category: String
    let isPending: Bool
    var isTransfer: Bool
    var isExpense: Bool
    var isEdited: Bool
    
    var dateParsed: Date {
        date.dateParsed()
    }
    
    //MARK :- show negative or postive balance.
    var negOrPosAmount: Double {
        return type == TransactionType.credit.rawValue ? amount : -amount
    }
    
    var month: String {
        dateParsed.formatted(.dateTime.year().month(.wide)) //.wide will show full month title
    }
}


enum TransactionType: String {
    case debit = "debit"
    case credit = "credit"
}
