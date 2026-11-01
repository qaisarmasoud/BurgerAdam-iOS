import SwiftUI

public struct ReportsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedDate: Date = Date()
    @State private var selectedOrderForReceipt: Order?
    @State private var csvURL: URL?
    @State private var showingCSVShare = false

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

    private var topItems: [(name: String, qty: Int, total: Int)] {
        dataManager.topSellingItems(for: selectedDate)
    }

    private var hourlyData: [(hour: Int, total: Int, count: Int)] {
        dataManager.hourlySales(for: selectedDate)
    }

    private var maxHourlyTotal: Int {
        max(hourlyData.map { $0.total }.max() ?? 1, 1)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // شريط اختيار التاريخ وأزرار التصدير
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("التقارير والإحصائيات الذكية")
                            .font(.system(size: 22, weight: .black))
                        Text("تحليلات المبيعات، ساعات الذروة، والوجبات الأكثر طلباً")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()

                    // زر تصدير Excel CSV
                    Button(action: exportCSV) {
                        HStack {
                            Image(systemName: "tablecells.badge.ellipsis")
                            Text("تصدير إكسل (CSV)")
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.12))
                        .cornerRadius(10)
                    }

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
                        subtitle: "\(dayOrders.count) طلبات اليوم",
                        icon: "bag.fill",
                        color: .green
                    )

                    StatCard(
                        title: "إجمالي المصاريف",
                        value: DataManager.formatMoney(dayExpenses),
                        subtitle: "\(dataManager.expenses(for: selectedDate).count) بنود مصروفات",
                        icon: "arrow.down.right.circle.fill",
                        color: .red
                    )

                    StatCard(
                        title: "صافي الأرباح",
                        value: DataManager.formatMoney(dayNetProfit),
                        subtitle: dayNetProfit >= 0 ? "أرباح ممتازة 🎉" : "عجز مالي",
                        icon: dayNetProfit >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                        color: dayNetProfit >= 0 ? .green : .red
                    )
                }

                // قسم الرسوم البيانية الذكية (ساعات الذروة + الأصناف الأكثر مبيعاً)
                HStack(alignment: .top, spacing: 14) {
                    // مخطط ساعات الذروة (Peak Hours)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.blue)
                            Text("ساعات الذروة (توزيع المبيعات)")
                                .font(.system(size: 16, weight: .bold))
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .bottom, spacing: 10) {
                                ForEach(hourlyData, id: \.hour) { h in
                                    VStack(spacing: 6) {
                                        let heightFraction = CGFloat(h.total) / CGFloat(maxHourlyTotal)
                                        let barHeight = max(heightFraction * 110, 4)

                                        ZStack(alignment: .bottom) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(h.total > 0 ? Color.blue : Color(UIColor.secondarySystemBackground))
                                                .frame(width: 24, height: barHeight)
                                        }

                                        Text("\(h.hour):00")
                                            .font(.system(size: 10, weight: .bold))
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)

                    // قائمة الوجبات الأكثر مبيعاً (Top Sellers)
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.orange)
                            Text("الوجبات الأكثر مبيعاً")
                                .font(.system(size: 16, weight: .bold))
                        }

                        if topItems.isEmpty {
                            Text("لا توجد مبيعات بهذا التاريخ")
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 8) {
                                ForEach(Array(topItems.prefix(5).enumerated()), id: \.element.name) { rank, item in
                                    HStack {
                                        Text("#\(rank + 1)")
                                            .font(.system(size: 12, weight: .black))
                                            .foregroundColor(rank == 0 ? .orange : .secondary)
                                            .frame(width: 24)

                                        Text(item.name)
                                            .font(.system(size: 14, weight: .bold))

                                        Spacer()

                                        Text("\(item.qty) وجبة")
                                            .font(.system(size: 12, weight: .bold))
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 3)
                                            .background(Color.green.opacity(0.12))
                                            .foregroundColor(.green)
                                            .cornerRadius(6)

                                        Text(DataManager.formatMoney(item.total))
                                            .font(.system(size: 13, weight: .bold))
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                }

                // سجل طلبات اليوم
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
                                            Text(order.paymentMethod.rawValue)
                                                .font(.system(size: 11, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.green.opacity(0.12))
                                                .foregroundColor(.green)
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

                                    Button(action: {
                                        selectedOrderForReceipt = order
                                    }) {
                                        Image(systemName: "doc.text.magnifyingglass")
                                            .foregroundColor(.blue)
                                            .padding(8)
                                            .background(Color.blue.opacity(0.1))
                                            .cornerRadius(8)
                                    }

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
        .sheet(isPresented: $showingCSVShare) {
            if let url = csvURL {
                ShareSheet(activityItems: [url])
            }
        }
    }

    private func exportCSV() {
        if let url = dataManager.exportCSVURL() {
            csvURL = url
            showingCSVShare = true
        }
    }
}


// بطاقة إحصاء ملونة
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
