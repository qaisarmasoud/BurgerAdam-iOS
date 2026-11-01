import SwiftUI

public struct ReportsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedDate: Date = Date()
    @State private var selectedOrderForReceipt: Order?

    private var dayOrders: [Order] {
        dataManager.orders(for: selectedDate)
    }

    private var daySales: Int {
        dataManager.totalSales(for: selectedDate)
    }

    private var dayExpenses: Int {
        dataManager.totalExpenses(for: selectedDate)
    }

    private var dayNetProfit: Int {
        dataManager.netProfit(for: selectedDate)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // شريط اختيار التاريخ
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("تقرير الأرباح والمبيعات")
                            .font(.system(size: 21, weight: .bold))
                            .foregroundColor(AdamTheme.textPrimary)
                        Text("ملخص المبيعات والمصاريف وصافي الربح لليوم المحدد")
                            .font(.system(size: 13))
                            .foregroundColor(AdamTheme.textSecondary)
                    }
                    Spacer()
                    DatePicker("التاريخ", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .padding(8)
                        .background(AdamTheme.bg)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))
                }
                .padding()
                .background(AdamTheme.card)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AdamTheme.border, lineWidth: 1))

                // بطاقات الإحصاءات
                HStack(spacing: 12) {
                    StatCard(
                        title: "إجمالي المبيعات",
                        value: DataManager.formatMoney(daySales),
                        subtitle: "\(dayOrders.count) طلبات",
                        icon: "bag.fill",
                        color: AdamTheme.green
                    )

                    StatCard(
                        title: "إجمالي المصاريف",
                        value: DataManager.formatMoney(dayExpenses),
                        subtitle: "\(dataManager.expenses(for: selectedDate).count) مصروفات",
                        icon: "arrow.down.right.circle.fill",
                        color: AdamTheme.red
                    )

                    StatCard(
                        title: "صافي الأرباح",
                        value: DataManager.formatMoney(dayNetProfit),
                        subtitle: dayNetProfit >= 0 ? "أرباح إيجابية 🎉" : "عجز مالي",
                        icon: dayNetProfit >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                        color: dayNetProfit >= 0 ? AdamTheme.green : AdamTheme.red
                    )
                }

                // تفاصيل مبيعات اليوم
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("سجل طلبات اليوم المحدد")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AdamTheme.textPrimary)
                        Spacer()
                        Text("\(dayOrders.count) طلب")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AdamTheme.textSecondary)
                    }

                    if dayOrders.isEmpty {
                        HStack {
                            Spacer()
                            Text("لا توجد مبيعات مسجلة في هذا التاريخ.")
                                .foregroundColor(AdamTheme.textSecondary)
                                .padding(.vertical, 30)
                            Spacer()
                        }
                    } else {
                        VStack(spacing: 8) {
                            ForEach(dayOrders) { order in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text("طلب #\(order.orderNumber)")
                                                .font(.system(size: 15, weight: .black))
                                                .foregroundColor(.blue)
                                            Text(order.date.formatted(date: .omitted, time: .shortened))
                                                .font(.system(size: 12))
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
