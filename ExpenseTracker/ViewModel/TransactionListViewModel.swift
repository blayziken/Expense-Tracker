//
//  TransactionListViewModel.swift
//  ExpenseTracker
//
//  Created by Blaze on 02/12/2023.
//

import Foundation
import Combine
import Collections

typealias TransactionGroup = OrderedDictionary<String, [Transaction]>
typealias TransactionPrefixSum = [(String, Double)] //string is date, double is the amount

final class TransactionListViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init () {
        getTransactions()
    }
    
    func getTransactions() {
        guard let url = URL(string: "https://designcode.io/data/transactions.json") else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap{ (data, response) -> Data in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    dump(response)
                    throw URLError(.badServerResponse)
                }
                
                return data
            }
            .decode(type: [Transaction].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error) :
                    print("Error fetching transaction", error.localizedDescription)
                case .finished:
                    print("Finished fetching transaction")
                }
                
            } receiveValue: { [weak self] result in
                self?.transactions = result
                dump(self?.transactions)
            }
            .store(in: &cancellables)
    }
    
    func groupTransactionsByMonth() -> TransactionGroup {
        guard !transactions.isEmpty else { return [:] } // Return empty dictionary if transactions is empty
        
        let groupedTransactions = TransactionGroup(grouping: transactions){$0.month}
        return groupedTransactions
    }
    
    func accumulateTransactions() -> TransactionPrefixSum{
        print("accumulateTransactions")
        guard !transactions.isEmpty else { return []}

        let today = "02/17/2022".dateParsed() //Date() use exact date to satisfy json data.
        let dateInterval = Calendar.current.dateInterval(of: .month, for: today)!
        print("dateInterval", dateInterval)

        var sum: Double = .zero//single value
        print("this is sum -> \(sum)")
        var cumulativeSum = TransactionPrefixSum() //set of values
        print("this is sum -> \(cumulativeSum)")

        for date in stride(from: dateInterval.start, to: today, by: 60 * 60 * 24){
            let dailyExpenses = transactions.filter { $0.dateParsed == date && $0.isExpense}
            print("sum in stride \(sum)")
            let dailyTotal = dailyExpenses.reduce(0) {$0 - $1.negOrPosAmount} //@negOrPos is negative, subtract to make it` positive
            sum += dailyTotal
            sum = sum.roundedTo2Digits()
            cumulativeSum.append((date.formatted(), sum))
            print(date.formatted(),"daily total:", dailyTotal, "sum :", sum )
        }
        return cumulativeSum
    }
    
    
}
