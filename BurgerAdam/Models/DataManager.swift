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

    // حساب يوم عمل المطعم (إذا كان الوقت بعد منتصف الليل وقبل 4:30 فجراً، يُعتبر تابعاً لشفت ليلة الأمس)
    public static func restaurantBusinessDate(for date: Date = Date()) -> Date {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        if hour < 4 { // بين 12 ليلاً و 4 صباحاً
            return calendar.date(byAdding: .day, value: -1, to: date) ?? date
        }
        return date
    }

    public func loadAllData() {
        let decoder = JSONDecoder()

        // 1. تحميل المنيو
        let menuURL = documentsDirectory.appendingPathComponent(menuFileName)
        if let data = try? Data(contentsOf: menuURL),
           let decoded = try? decoder.decode([MenuItem].self, from: data) {
            self.menuItems = decoded
        } else {
            self.menuItems = MenuItem.defaultMenu
            saveMenu()
        }

        // 2. تحميل الطلبات (مع حماية واسترجاع من الذاكرة الاحتياطية إن وُجدت)
        let ordersURL = documentsDirectory.appendingPathComponent(ordersFileName)
        if let data = try? Data(contentsOf: ordersURL),
           let decoded = try? decoder.decode([Order].self, from: data) {
            self.orders = decoded
        } else if let savedData = UserDefaults.standard.data(forKey: "adam_orders_backup"),
                  let decoded = try? decoder.decode([Order].self, from: savedData) {
            self.orders = decoded
            saveOrders()
        } else {
            self.orders = []
        }

        // 3. تحميل المصاريف
        let expensesURL = documentsDirectory.appendingPathComponent(expensesFileName)
        if let data = try? Data(contentsOf: expensesURL),
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
            // حفظ نسخة احتياطية إضافية فورية في UserDefaults لضمان عدم الضياع نهائياً
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

    // فلترة الطلبات والمصاريف بحسب يوم عمل المطعم
    public func orders(for date: Date) -> [Order] {
        let calendar = Calendar.current
        return orders.filter { order in
            let orderBizDate = DataManager.restaurantBusinessDate(for: order.date)
            let targetBizDate = DataManager.restaurantBusinessDate(for: date)
            return calendar.isDate(orderBizDate, inSameDayAs: targetBizDate)
        }
    }

    public func expenses(for date: Date) -> [Expense] {
        let calendar = Calendar.current
        return expenses.filter { exp in
            let expBizDate = DataManager.restaurantBusinessDate(for: exp.date)
            let targetBizDate = DataManager.restaurantBusinessDate(for: date)
            return calendar.isDate(expBizDate, inSameDayAs: targetBizDate)
        }
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

    // الإجماليات الشاملة لكل الأوقات (All-Time)
    public var allTimeSalesTotal: Int {
        orders.reduce(0) { $0 + $1.total }
    }

    public var allTimeExpensesTotal: Int {
        expenses.reduce(0) { $0 + $1.amount }
    }

    public var allTimeNetProfit: Int {
        allTimeSalesTotal - allTimeExpensesTotal
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
