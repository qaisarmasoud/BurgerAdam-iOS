import Foundation
import SwiftUI
import Combine

public struct ShiftInfo: Codable {
    public var isOpen: Bool
    public var cashierName: String
    public var startTime: Date
    public var startingCash: Int // القاصة الافتتاحية
}

public class DataManager: ObservableObject {
    @Published public var menuItems: [MenuItem] = []
    @Published public var orders: [Order] = []
    @Published public var expenses: [Expense] = []
    @Published public var currentShift: ShiftInfo = ShiftInfo(isOpen: true, cashierName: "كاشير 1", startTime: Date(), startingCash: 50000)
    
    private let menuFileName = "adam_menu.json"
    private let ordersFileName = "adam_orders.json"
    private let expensesFileName = "adam_expenses.json"
    private let shiftFileName = "adam_shift.json"

    public init() {
        loadAllData()
    }

    private var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    public static func formatMoney(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formatted = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "\(formatted) د.ع"
    }

    public func loadAllData() {
        // المنيو
        let menuURL = documentsDirectory.appendingPathComponent(menuFileName)
        if let data = try? Data(contentsOf: menuURL),
           let decoded = try? JSONDecoder().decode([MenuItem].self, from: data) {
            self.menuItems = decoded
        } else {
            self.menuItems = MenuItem.defaultMenu
            saveMenu()
        }

        // الطلبات
        let ordersURL = documentsDirectory.appendingPathComponent(ordersFileName)
        if let data = try? Data(contentsOf: ordersURL),
           let decoded = try? JSONDecoder().decode([Order].self, from: data) {
            self.orders = decoded
        } else {
            self.orders = []
        }

        // المصاريف
        let expensesURL = documentsDirectory.appendingPathComponent(expensesFileName)
        if let data = try? Data(contentsOf: expensesURL),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            self.expenses = decoded
        } else {
            self.expenses = []
        }

        // الشفت
        let shiftURL = documentsDirectory.appendingPathComponent(shiftFileName)
        if let data = try? Data(contentsOf: shiftURL),
           let decoded = try? JSONDecoder().decode(ShiftInfo.self, from: data) {
            self.currentShift = decoded
        }
    }

    public func saveMenu() {
        let menuURL = documentsDirectory.appendingPathComponent(menuFileName)
        if let encoded = try? JSONEncoder().encode(menuItems) {
            try? encoded.write(to: menuURL)
        }
    }

    public func saveOrders() {
        let ordersURL = documentsDirectory.appendingPathComponent(ordersFileName)
        if let encoded = try? JSONEncoder().encode(orders) {
            try? encoded.write(to: ordersURL)
        }
    }

    public func saveExpenses() {
        let expensesURL = documentsDirectory.appendingPathComponent(expensesFileName)
        if let encoded = try? JSONEncoder().encode(expenses) {
            try? encoded.write(to: expensesURL)
        }
    }

    public func saveShift() {
        let shiftURL = documentsDirectory.appendingPathComponent(shiftFileName)
        if let encoded = try? JSONEncoder().encode(currentShift) {
            try? encoded.write(to: shiftURL)
        }
    }

    public func addOrder(items: [OrderItem], note: String, orderType: OrderType, paymentMethod: PaymentMethod) -> Order {
        let total = items.reduce(0) { $0 + $1.totalPrice }
        let nextOrderNumber = (orders.map { $0.orderNumber }.max() ?? 0) + 1
        let newOrder = Order(
            orderNumber: nextOrderNumber,
            date: Date(),
            items: items,
            note: note,
            orderType: orderType,
            paymentMethod: paymentMethod,
            total: total
        )
        orders.insert(newOrder, at: 0)
        saveOrders()
        return newOrder
    }

    public func deleteOrder(id: UUID) {
        orders.removeAll { $0.id == id }
        saveOrders()
    }

    public func addExpense(name: String, amount: Int, category: String, date: Date, note: String) {
        let expense = Expense(name: name, amount: amount, category: category, date: date, note: note)
        expenses.insert(expense, at: 0)
        saveExpenses()
    }

    public func deleteExpense(id: UUID) {
        expenses.removeAll { $0.id == id }
        saveExpenses()
    }

    public func addMenuItem(name: String, price: Int, category: String, emoji: String) {
        let item = MenuItem(name: name, price: price, category: category, emoji: emoji)
        menuItems.append(item)
        saveMenu()
    }

    public func deleteMenuItem(id: UUID) {
        menuItems.removeAll { $0.id == id }
        saveMenu()
    }

    public func resetMenuToDefaults() {
        menuItems = MenuItem.defaultMenu
        saveMenu()
    }

    // فلترة التواريخ
    public func orders(for date: Date) -> [Order] {
        let calendar = Calendar.current
        return orders.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    public func expenses(for date: Date) -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    public func totalSales(for date: Date) -> Int {
        orders(for: date).reduce(0) { $0 + $1.total }
    }

    public func totalExpenses(for date: Date) -> Int {
        expenses(for: date).reduce(0) { $0 + $1.amount }
    }

    public func netProfit(for date: Date) -> Int {
        totalSales(for: date) - totalExpenses(for: date)
    }

    // إحصائيات طرق الدفع لليوم
    public func salesByPaymentMethod(for date: Date) -> (cash: Int, zainCash: Int, card: Int) {
        let dayOrders = orders(for: date)
        var cash = 0
        var zainCash = 0
        var card = 0
        for o in dayOrders {
            switch o.paymentMethod {
            case .cash: cash += o.total
            case .zainCash: zainCash += o.total
            case .card: card += o.total
            }
        }
        return (cash, zainCash, card)
    }

    // إحصائيات الأصناف الأكثر مبيعاً
    public func topSellingItems(for date: Date) -> [(name: String, qty: Int, total: Int)] {
        let dayOrders = orders(for: date)
        var counts: [String: (qty: Int, total: Int)] = [:]
        for o in dayOrders {
            for i in o.items {
                let existing = counts[i.name] ?? (0, 0)
                counts[i.name] = (existing.qty + i.quantity, existing.total + i.totalPrice)
            }
        }
        return counts.map { (name: $0.key, qty: $0.value.qty, total: $0.value.total) }
            .sorted { $0.qty > $1.qty }
    }

    // إحصائيات المبيعات بالساعات (ساعات الذروة)
    public func hourlySales(for date: Date) -> [(hour: Int, total: Int, count: Int)] {
        let dayOrders = orders(for: date)
        var hoursMap: [Int: (total: Int, count: Int)] = [:]
        let calendar = Calendar.current
        for h in 10...23 { // من 10 صباحاً لـ 11 ليلاً
            hoursMap[h] = (0, 0)
        }
        for o in dayOrders {
            let h = calendar.component(.hour, from: o.date)
            let curr = hoursMap[h] ?? (0, 0)
            hoursMap[h] = (curr.total + o.total, curr.count + 1)
        }
        return hoursMap.map { (hour: $0.key, total: $0.value.total, count: $0.value.count) }
            .sorted { $0.hour < $1.hour }
    }

    // بدء وإغلاق الشفت (Z-Report)
    public func startNewShift(cashierName: String, startingCash: Int) {
        currentShift = ShiftInfo(isOpen: true, cashierName: cashierName, startTime: Date(), startingCash: startingCash)
        saveShift()
    }

    public func shiftExpectedCash() -> Int {
        let todayOrders = orders(for: Date())
        let cashSales = todayOrders.filter { $0.paymentMethod == .cash }.reduce(0) { $0 + $1.total }
        let dayExpenses = totalExpenses(for: Date())
        return currentShift.startingCash + cashSales - dayExpenses
    }

    // تصدير ملف Excel / CSV
    public func exportCSVURL() -> URL? {
        var csv = "رقم الطلب,التاريخ,الوقت,نوع الطلب,طريقة الدفع,الأصناف,الملاحظات,المجموع بالدينار\n"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        for o in orders {
            let d = dateFormatter.string(from: o.date)
            let t = timeFormatter.string(from: o.date)
            let itemsStr = o.items.map { "\($0.name) x\($0.quantity)" }.joined(separator: " + ")
            let cleanNote = o.note.replacingOccurrences(of: ",", with: " ")
            csv += "\(o.orderNumber),\(d),\(t),\(o.orderType.rawValue),\(o.paymentMethod.rawValue),\"\(itemsStr)\",\"\(cleanNote)\",\(o.total)\n"
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("تقرير_مبيعات_بركر_ادم.csv")
        try? csv.write(to: tempURL, atomically: true, encoding: .utf8)
        return tempURL
    }

    // تصدير واستيراد النسخة الاحتياطية
    public struct BackupData: Codable {
        public var app: String
        public var version: Int
        public var exportedAt: Date
        public var menu: [MenuItem]
        public var orders: [Order]
        public var expenses: [Expense]
    }

    public func exportBackupURL() -> URL? {
        let backup = BackupData(
            app: "بركر ادم",
            version: 3,
            exportedAt: Date(),
            menu: menuItems,
            orders: orders,
            expenses: expenses
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(backup) else { return nil }
        
        let dateString = ISO8601DateFormatter().string(from: Date()).prefix(10)
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("BurgerAdam-Backup-\(dateString).json")
        try? data.write(to: tempURL)
        return tempURL
    }

    public func importBackup(from url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url) else { return false }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let backup = try? decoder.decode(BackupData.self, from: data) else { return false }
        
        self.menuItems = backup.menu
        self.orders = backup.orders
        self.expenses = backup.expenses
        saveMenu()
        saveOrders()
        saveExpenses()
        return true
    }
}
