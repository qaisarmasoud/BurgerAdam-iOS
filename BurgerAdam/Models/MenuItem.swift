import Foundation

public struct MenuItem: Identifiable, Codable, Equatable, Hashable {
    public var id: UUID
    public var name: String
    public var price: Int // بالدينار العراقي
    public var category: String
    public var emoji: String
    public var isAvailable: Bool

    public init(id: UUID = UUID(), name: String, price: Int, category: String, emoji: String, isAvailable: Bool = true) {
        self.id = id
        self.name = name
        self.price = price
        self.category = category
        self.emoji = emoji
        self.isAvailable = isAvailable
    }

    public static let defaultMenu: [MenuItem] = [
        MenuItem(name: "همبركر لحم", price: 3000, category: "بركر لحم", emoji: "🍔"),
        MenuItem(name: "همبركر دبل", price: 5000, category: "بركر لحم", emoji: "🍔"),
        MenuItem(name: "همبركر لحم بالجبن", price: 3500, category: "بركر لحم", emoji: "🧀"),
        MenuItem(name: "همبركر دجاج", price: 2500, category: "بركر دجاج", emoji: "🍗"),
        MenuItem(name: "همبركر دجاج بالجبن", price: 3000, category: "بركر دجاج", emoji: "🧀"),
        MenuItem(name: "همبركر دبل دجاج", price: 4000, category: "بركر دجاج", emoji: "🍗"),
        MenuItem(name: "وجبة همبركر ادم", price: 4500, category: "وجبات خاصة", emoji: "🍟"),
        MenuItem(name: "بطاطا مقلية (فنغر)", price: 1500, category: "إضافات", emoji: "🍟"),
        MenuItem(name: "مشروب غازي", price: 500, category: "مشروبات", emoji: "🥤"),
        MenuItem(name: "عصير طبيعي", price: 1500, category: "مشروبات", emoji: "🧃"),
        MenuItem(name: "ماء معدني", price: 250, category: "مشروبات", emoji: "💧")
    ]
}
