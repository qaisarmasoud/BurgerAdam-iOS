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
            VStack(spacing: 20) {
                // شريط اختيار التاريخ
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("تقرير الأرباح والمبيعات")
                            .font(.system(size: 22, weight: .bold))
                        Text("اختر أي تاريخ لعرض ملخص المبيعات والمصاريف وصافي الربح")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    DatePicker("التاريخ", selection: $selectedDate, displayedComponents: .date)
                        .labelsHidden()
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)

                // بطاقات الإحصاءات الرئيسية
                HStack(spacing: 14) {
                    StatCard(
                        title: "إجمالي المبيعات",
                        value: DataManager.formatMoney(daySales),
                        subtitle: "\(dayOrders.count) طلبات",
                        icon: "bag.fill",
                        color: .green
                    )

                    StatCard(
                        title: "إجمالي المصاريف",
                        value: DataManager.formatMoney(dayExpenses),
                        subtitle: "\(dataManager.expenses(for: selectedDate).count) مصروفات",
                        icon: "arrow.down.right.circle.fill",
                        color: .red
                    )

                    StatCard(
                        title: "صافي الأرباح",
                        value: DataManager.formatMoney(dayNetProfit),
                        subtitle: dayNetProfit >= 0 ? "أرباح إيجابية 🎉" : "عجز مالي",
                        icon: dayNetProfit >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                        color: dayNetProfit >= 0 ? .green : .red
                    )
                }

                // تفاصيل مبيعات اليوم
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("سجل طلبات اليوم المحدد")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text("\(dayOrders.count) طلب")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.secondary)
                    }

                    if dayOrders.isEmpty {
                        HStack {
                            Spacer()
                            Text("لا توجد مبيعات مسجلة في هذا التاريخ.")
                                .foregroundColor(.secondary)
                                .padding(.vertical, 30)
                            Spacer()
                        }
                    } else {
                        VStack(spacing: 10) {
                            ForEach(dayOrders) { order in
                                HStack {
                                    VStack(alignment: .leading, spacing: 5) {
                                        HStack {
                                            Text("طلب #\(order.orderNumber)")
                                                .font(.system(size: 16, weight: .black))
                                                .foregroundColor(.blue)
                                            Text(order.date.formatted(date: .omitted, time: .shortened))
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                            Text(order.orderType.rawValue)
                                                .font(.system(size: 11, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.orange.opacity(0.12))
                                                .foregroundColor(.orange)
                                                .cornerRadius(6)
                                        }

                                        Text(order.items.map { "\($0.name) × \($0.quantity)" }.joined(separator: " ، "))
                                            .font(.system(size: 13))
                                            .foregroundColor(.secondary)

                                        if !order.note.isEmpty {
                                            Text("ملاحظة: \(order.note)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary.opacity(0.8))
                                        }
                                    }

                                    Spacer()

                                    Text(DataManager.formatMoney(order.total))
                                        .font(.system(size: 17, weight: .black))
                                        .foregroundColor(.green)
                                        .padding(.trailing, 10)

                                    // زر الفاتورة
                                    Button(action: {
                                        selectedOrderForReceipt = order
                                    }) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .foregroundColor(.blue)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }

                                    // زر الحذف
                                    Button(action: {
                                        withAnimation {
                                            dataManager.deleteOrder(id: order.id)
                                        }
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red.opacity(0.7))
                                            .padding(8)
                                    }
                                }
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(12)
                            }
                        }
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(item: $selectedOrderForReceipt) { order in
            ReceiptView(order: order)
        }
    }
}

// بطاقة إحصاء ملونة
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20))
            }

            Text(value)
                .font(.system(size: 22, weight: .black))
                .foregroundColor(color)
                .minimumScaleFactor(0.8)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .padding(16)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(14)
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }
}
