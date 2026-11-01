import SwiftUI

public enum ReportFilterMode: String, CaseIterable {
    case currentShift = "اليوم / الشفت الحالي"
    case yesterday = "أمس"
    case allTime = "الإجمالي الشامل (الكل)"
    case custom = "تاريخ مخصص"
}

public struct ReportsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var filterMode: ReportFilterMode = .allTime // يبدأ افتراضياً على الإجمالي الشامل ليرى كل مبيعاته
    @State private var selectedCustomDate: Date = DataManager.restaurantBusinessDate(for: Date())
    @State private var selectedOrderForReceipt: Order?

    private var targetDate: Date {
        switch filterMode {
        case .currentShift:
            return DataManager.restaurantBusinessDate(for: Date())
        case .yesterday:
            return Calendar.current.date(byAdding: .day, value: -1, to: DataManager.restaurantBusinessDate(for: Date())) ?? Date()
        case .custom:
            return selectedCustomDate
        case .allTime:
            return Date()
        }
    }

    private var displayedOrders: [Order] {
        if filterMode == .allTime {
            return dataManager.orders
        } else {
            return dataManager.orders(for: targetDate)
        }
    }

    private var displayedSales: Int {
        if filterMode == .allTime {
            return dataManager.allTimeSalesTotal
        } else {
            return dataManager.totalSales(for: targetDate)
        }
    }

    private var displayedExpenses: Int {
        if filterMode == .allTime {
            return dataManager.allTimeExpensesTotal
        } else {
            return dataManager.totalExpenses(for: targetDate)
        }
    }

    private var displayedNetProfit: Int {
        displayedSales - displayedExpenses
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // شريط تصفية التقارير (فلاتر واضحة ومباشرة)
                VStack(spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("الأرباح والتقارير المالية")
                                .font(.system(size: 21, weight: .black))
                                .foregroundColor(AdamTheme.textPrimary)
                            Text("اختر طريقة العرض لمتابعة أرباحك ومبيعاتك بدقة")
                                .font(.system(size: 13))
                                .foregroundColor(AdamTheme.textSecondary)
                        }
                        Spacer()
                    }

                    // أزرار الفلاتر السريعة
                    HStack(spacing: 6) {
                        ForEach(ReportFilterMode.allCases, id: \.self) { mode in
                            Button(action: {
                                filterMode = mode
                            }) {
                                Text(mode.rawValue)
                                    .font(.system(size: 12, weight: .bold))
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 8)
                                    .background(filterMode == mode ? AdamTheme.amber : AdamTheme.bg)
                                    .foregroundColor(filterMode == mode ? .black : AdamTheme.textPrimary)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(filterMode == mode ? AdamTheme.amber : AdamTheme.border, lineWidth: 1)
                                    )
                            }
                        }
                    }

                    // اختيار تاريخ مخصص إذا تم اختياره
                    if filterMode == .custom {
                        HStack {
                            Text("حدد التاريخ:")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AdamTheme.textSecondary)
                            Spacer()
                            DatePicker("", selection: $selectedCustomDate, displayedComponents: .date)
                                .labelsHidden()
                                .padding(6)
                                .background(AdamTheme.bg)
                                .cornerRadius(8)
                        }
                        .padding(.top, 4)
                    }
                }
                .padding()
                .background(AdamTheme.card)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AdamTheme.border, lineWidth: 1))

                // بطاقات الإحصاءات الثلاثية
                HStack(spacing: 12) {
                    StatCard(
                        title: "إجمالي المبيعات",
                        value: DataManager.formatMoney(displayedSales),
                        subtitle: "\(displayedOrders.count) طلبات مسجلة",
                        icon: "bag.fill",
                        color: AdamTheme.green
                    )

                    StatCard(
                        title: "إجمالي المصاريف",
                        value: DataManager.formatMoney(displayedExpenses),
                        subtitle: filterMode == .allTime ? "\(dataManager.expenses.count) مصروفات" : "\(dataManager.expenses(for: targetDate).count) مصروفات",
                        icon: "arrow.down.right.circle.fill",
                        color: AdamTheme.red
                    )

                    StatCard(
                        title: "صافي الأرباح",
                        value: DataManager.formatMoney(displayedNetProfit),
                        subtitle: displayedNetProfit >= 0 ? "أرباح صافية 🎉" : "عجز مالي",
                        icon: displayedNetProfit >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                        color: displayedNetProfit >= 0 ? AdamTheme.green : AdamTheme.red
                    )
                }

                // قائمة المبيعات المفلترة
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(filterMode == .allTime ? "جميع المبيعات المسجلة" : "مبيعات الفترة المحددة")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AdamTheme.textPrimary)
                        Spacer()
                        Text("\(displayedOrders.count) طلب")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AdamTheme.textSecondary)
                    }

                    if displayedOrders.isEmpty {
                        HStack {
                            Spacer()
                            Text("لا توجد مبيعات في هذا التاريخ.")
                                .foregroundColor(AdamTheme.textSecondary)
                                .padding(.vertical, 24)
                            Spacer()
                        }
                    } else {
                        VStack(spacing: 8) {
                            ForEach(displayedOrders) { order in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text("طلب #\(order.orderNumber)")
                                                .font(.system(size: 15, weight: .black))
                                                .foregroundColor(.blue)
                                            Text(order.date.formatted(date: .abbreviated, time: .shortened))
                                                .font(.system(size: 11))
                                                .foregroundColor(AdamTheme.textSecondary)
                                            Text(order.orderType.rawValue)
                                                .font(.system(size: 11, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AdamTheme.amber.opacity(0.15))
                                                .foregroundColor(AdamTheme.amber)
                                                .cornerRadius(6)
                                            Text(order.paymentMethod.rawValue)
                                                .font(.system(size: 11, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(AdamTheme.green.opacity(0.15))
                                                .foregroundColor(AdamTheme.green)
                                                .cornerRadius(6)
                                        }

                                        Text(order.items.map { "\($0.name) × \($0.quantity)" }.joined(separator: " ، "))
                                            .font(.system(size: 13))
                                            .foregroundColor(AdamTheme.textSecondary)

                                        if !order.note.isEmpty {
                                            Text("ملاحظة: \(order.note)")
                                                .font(.system(size: 12))
                                                .foregroundColor(AdamTheme.textSecondary.opacity(0.8))
                                        }
                                    }

                                    Spacer()

                                    Text(DataManager.formatMoney(order.total))
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundColor(AdamTheme.green)
                                        .padding(.trailing, 8)

                                    Button(action: {
                                        selectedOrderForReceipt = order
                                    }) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .foregroundColor(.blue)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.12))
                                            .cornerRadius(8)
                                    }

                                    Button(action: {
                                        dataManager.deleteOrder(id: order.id)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(AdamTheme.red.opacity(0.7))
                                            .padding(8)
                                    }
                                }
                                .padding(12)
                                .background(AdamTheme.card)
                                .cornerRadius(12)
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(AdamTheme.border, lineWidth: 1))
                            }
                        }
                    }
                }
                .padding()
                .background(AdamTheme.card)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AdamTheme.border, lineWidth: 1))
            }
            .padding()
        }
        .background(AdamTheme.bg)
        .sheet(item: $selectedOrderForReceipt) { order in
            ReceiptView(order: order)
        }
    }
}

// بطاقة إحصاء خفيفة بدون ظلال
public struct StatCard: View {
    public let title: String
    public let value: String
    public let subtitle: String
    public let icon: String
    public let color: Color

    public init(title: String, value: String, subtitle: String, icon: String, color: Color) {
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AdamTheme.textSecondary)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 18))
            }

            Text(value)
                .font(.system(size: 21, weight: .black))
                .foregroundColor(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(AdamTheme.textSecondary)
        }
        .padding(14)
        .background(AdamTheme.card)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AdamTheme.border, lineWidth: 1))
    }
}
