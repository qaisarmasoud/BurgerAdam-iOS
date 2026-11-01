import Foundation

public struct Expense: Identifiable, Codable, Equatable {
    public var id: UUID
    public var name: String
    public var amount: Int // بالدينار العراقي
    public var category: String
    public var date: Date
    public var note: String
    public var isClosed: Bool?
    public var closedDate: Date?

    public init(
        id: UUID = UUID(),
        name: String,
        amount: Int,
        category: String = "مواد غذائية",
        date: Date = Date(),
        note: String = "",
        isClosed: Bool? = false,
        closedDate: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.amount = amount
        self.category = category
        self.date = date
        self.note = note
        self.isClosed = isClosed
        self.closedDate = closedDate
    }

    public static let categories = [
        "مواد غذائية (لحوم، خبز)",
        "غاز وكهرباء",
        "تعبئة وتغليف",
        "أجور عمال ومكافآت",
        "صيانة ونظافة",
        "إيجار ومصاريف عامة",
        "أخرى"
    ]
}
