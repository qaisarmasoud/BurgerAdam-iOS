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
    public var selectedAddOns: [CustomAddOn]
    public var selectedPreferences: [String]

    public init(
        id: UUID = UUID(),
        menuItemId: UUID,
        name: String,
        unitPrice: Int,
        quantity: Int = 1,
        selectedAddOns: [CustomAddOn] = [],
        selectedPreferences: [String] = []
    ) {
        self.id = id
        self.menuItemId = menuItemId
        self.name = name
        self.unitPrice = unitPrice
        self.quantity = quantity
        self.selectedAddOns = selectedAddOns
        self.selectedPreferences = selectedPreferences
    }

    public var addOnsTotal: Int {
        selectedAddOns.reduce(0) { $0 + $1.price }
    }

    public var singleItemTotal: Int {
        unitPrice + addOnsTotal
    }

    public var totalPrice: Int {
        singleItemTotal * quantity
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
