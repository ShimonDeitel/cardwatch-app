import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    static let freeLimit = 8

    @Published var items: [CardEntry] = []
    @Published var isPro: Bool = false

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("cardwatch_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: CardEntry) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: CardEntry) {
        if let idx = items.firstIndex(where: { $0.id == item.id }) {
            items[idx] = item
            save()
        }
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: CardEntry) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([CardEntry].self, from: data) else {
            items = Store.seedData()
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [CardEntry] {
        [
        CardEntry(date: Date().addingTimeInterval(-86400), cardName: "Chase Sapphire", balance: "1240.55", dueDate: "14th"),
        CardEntry(date: Date().addingTimeInterval(-172800), cardName: "Amex Gold", balance: "540.00", dueDate: "3rd"),
        CardEntry(date: Date().addingTimeInterval(-259200), cardName: "Discover It", balance: "89.30", dueDate: "22nd")
        ]
    }
}
