import Foundation

public enum OrderType: String, Codable, CaseIterable {
    case takeaway = "سفري"
    case dineIn = "صالة"
    case delivery = "توصيل"
}

public enum PaymentMethod: String, Codable, CaseIterable {
    case cash = "نقداً"
    case zainCash = "زين كاش"
    case card = "بطاقة مصرفية"
}

public struct OrderItem: Identifiable, Codable, Equatable {
    public var id: UUID
    public var menuItemId: UUID
    public var name: String
    public var unitPrice: Int
    public var quantity: Int

    public init(id: UUID = UUID(), menuItemId: UUID, name: String, unitPrice: Int, quantity: Int = 1) {
        self.id = id
        self.menuItemId = menuItemId
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
    }

    public var totalPrice: Int {
        unitPrice * quantity
    }
}

public struct Order: Identifiable, Codable, Equatable {
    public var id: UUID
    public var orderNumber: Int
    public var date: Date
    public var items: [OrderItem]
    public var note: String
    public var orderType: OrderType
    public var paymentMethod: PaymentMethod
    public var total: Int

    public init(
        id: UUID = UUID(),
        orderNumber: Int,
        date: Date = Date(),
        items: [OrderItem],
        note: String = "",
        orderType: OrderType = .takeaway,
        paymentMethod: PaymentMethod = .cash,
        total: Int
    ) {
        self.id = id
        self.orderNumber = orderNumber
        self.date = date
        self.items = items
        self.note = note
        self.orderType = orderType
        self.paymentMethod = paymentMethod
        self.total = total
    }
}
