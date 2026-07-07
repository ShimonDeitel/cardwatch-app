import Foundation

struct CardEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var date: Date = Date()
    var cardName: String
    var balance: String
    var dueDate: String
}
