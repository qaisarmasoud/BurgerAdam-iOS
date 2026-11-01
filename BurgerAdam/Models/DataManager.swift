import Foundation
import SwiftUI
import Combine

public class DataManager: ObservableObject {
    @Published public var menuItems: [MenuItem] = []
    @Published public var orders: [Order] = []
    @Published public var expenses: [Expense] = []
    
    private let menuFileName = "adam_menu.json"
    private let ordersFileName = "adam_orders.json"
    private let expensesFileName = "adam_expenses.json"

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
        let decoder = JSONDecoder()

        // 1. تحميل المنيو
        let menuURL = documentsDirectory.appendingPathComponent(menuFileName)
        if FileManager.default.fileExists(atPath: menuURL.path),
           let data = try? Data(contentsOf: menuURL),
           let decoded = try? decoder.decode([MenuItem].self, from: data) {
            self.menuItems = decoded
        } else {
            self.menuItems = MenuItem.defaultMenu
            saveMenu()
        }

        // 2. تحميل الطلبات
        let ordersURL = documentsDirectory.appendingPathComponent(ordersFileName)
        if FileManager.default.fileExists(atPath: ordersURL.path),
           let data = try? Data(contentsOf: ordersURL),
           let decoded = try? decoder.decode([Order].self, from: data) {
            self.orders = decoded
        } else if let savedData = UserDefaults.standard.data(forKey: "adam_orders_backup"),
                  let decoded = try? decoder.decode([Order].self, from: savedData) {
            self.orders = decoded
            saveOrders()
        } else {
            self.orders = []
        }

        // 3. تحميل المصاريف (بدون استرجاع أي عناصر محذوفة)
        let expensesURL = documentsDirectory.appendingPathComponent(expensesFileName)
        if FileManager.default.fileExists(atPath: expensesURL.path),
           let data = try? Data(contentsOf: expensesURL),
           let decoded = try? decoder.decode([Expense].self, from: data) {
            self.expenses = decoded
        } else if let savedData = UserDefaults.standard.data(forKey: "adam_expenses_backup"),
                  let decoded = try? decoder.decode([Expense].self, from: savedData) {
            self.expenses = decoded
            saveExpenses()
        } else {
            self.expenses = []
        }
    }

    public func saveMenu() {
        let menuURL = documentsDirectory.appendingPathComponent(menuFileName)
        if let encoded = try? JSONEncoder().encode(menuItems) {
            try? encoded.write(to: menuURL, options: .atomic)
        }
    }

    public func saveOrders() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(orders) {
            let ordersURL = documentsDirectory.appendingPathComponent(ordersFileName)
            try? encoded.write(to: ordersURL, options: .atomic)
            UserDefaults.standard.set(encoded, forKey: "adam_orders_backup")
        }
    }

    public func saveExpenses() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(expenses) {
            let expensesURL = documentsDirectory.appendingPathComponent(expensesFileName)
            try? encoded.write(to: expensesURL, options: .atomic)
            UserDefaults.standard.set(encoded, forKey: "adam_expenses_backup")
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
            total: total,
            isClosed: false
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
        let expense = Expense(
            name: name,
            amount: amount,
            category: category,
            date: date,
            note: note,
            isClosed: false
        )
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

    // --- منطق اليومية الحالية والأرشيف (يدوي بالكامل وبدون أي تصفير زمني) ---

    // 1. طلبات اليومية الحالية المفتوحة
    public var activeOrders: [Order] {
        orders.filter { !($0.isClosed ?? false) }
    }

    // الطلبات السابقة المؤرشفة
    public var closedOrders: [Order] {
        orders.filter { ($0.isClosed ?? false) }
    }

    // 2. مصاريف اليومية الحالية المفتوحة (التي سجلت لهذا اليوم فقط)
    public var activeExpenses: [Expense] {
        expenses.filter { !($0.isClosed ?? false) }
    }

    // المصاريف السابقة المؤرشفة
    public var closedExpenses: [Expense] {
        expenses.filter { ($0.isClosed ?? false) }
    }

    // مبيعات اليومية الحالية
    public var activeSalesTotal: Int {
        activeOrders.reduce(0) { $0 + $1.total }
    }

    // مصاريف اليومية الحالية (خاصة بهذا اليوم فقط ولا تعود مصاريف الأمس)
    public var activeExpensesTotal: Int {
        activeExpenses.reduce(0) { $0 + $1.amount }
    }

    // صافي ربح اليومية الحالية (مبيعات اليوم - مصاريف اليوم)
    public var activeNetProfit: Int {
        activeSalesTotal - activeExpensesTotal
    }

    // الإجماليات الشاملة التراكمية (لكل الأيام منذ بداية التطبيق)
    public var allTimeSalesTotal: Int {
        orders.reduce(0) { $0 + $1.total }
    }

    public var allTimeExpensesTotal: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    public var allTimeNetProfit: Int {
        allTimeSalesTotal - allTimeExpensesTotal
    }

    // إغلاق اليومية الحالية (عندما يعزل صاحب المطعم)
    // يُقفل مبيعات ومصاريف هذا اليوم معاً ويحفظهما في الأرشيف، لتبدأ اليومية الجديدة نظيفة بـ 0
    public func closeCurrentDay() {
        let now = Date()
        for i in 0..<orders.count {
            if !(orders[i].isClosed ?? false) {
                orders[i].isClosed = true
                orders[i].closedDate = now
            }
        }
        for i in 0..<expenses.count {
            if !(expenses[i].isClosed ?? false) {
                expenses[i].isClosed = true
                expenses[i].closedDate = now
            }
        }
        saveOrders()
        saveExpenses()
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
            version: 5,
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
        try? data.write(to: tempURL, options: .atomic)
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
