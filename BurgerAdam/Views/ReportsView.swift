import SwiftUI

public enum ReportTab: String, CaseIterable {
    case active = "اليومية الحالية (شغال)"
    case closed = "الأيام السابقة (الأرشيف)"
    case allTime = "الإجمالي الشامل (الكل)"
}

public struct ReportsView: View {
    @ObservedObject var dataManager: DataManager
    @State private var currentTab: ReportTab = .active
    @State private var showingCloseDayAlert = false
    @State private var selectedOrderForReceipt: Order?

    private var currentOrders: [Order] {
        switch currentTab {
        case .active:
            return dataManager.activeOrders
        case .closed:
            return dataManager.closedOrders
        case .allTime:
            return dataManager.orders
        }
    }

    private var currentExpensesList: [Expense] {
        switch currentTab {
        case .active:
            return dataManager.activeExpenses
        case .closed:
            return dataManager.closedExpenses
        case .allTime:
            return dataManager.expenses
        }
    }

    private var currentSales: Int {
        switch currentTab {
        case .active:
            return dataManager.activeSalesTotal
        case .closed:
            return dataManager.closedOrders.reduce(0) { $0 + $1.total }
        case .allTime:
            return dataManager.allTimeSalesTotal
        }
    }

    private var currentExpenses: Int {
        switch currentTab {
        case .active:
            return dataManager.activeExpensesTotal
        case .closed:
            return dataManager.closedExpenses.reduce(0) { $0 + $1.amount }
        case .allTime:
            return dataManager.allTimeExpensesTotal
        }
    }

    private var currentNetProfit: Int {
        currentSales - currentExpenses
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // شريط ترويسة التقارير وزر إغلاق اليومية
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("الأرباح والتقارير المالية")
                                .font(.system(size: 21, weight: .black))
                                .foregroundColor(AdamTheme.textPrimary)
                            Text("إحصائيات دقيقة: صافي الربح = المبيعات − المصاريف")
                                .font(.system(size: 12))
                                .foregroundColor(AdamTheme.textSecondary)
                        }
                        Spacer()

                        // زر إغلاق اليومية اليدوي (وقت التعزيل)
                        Button(action: {
                            showingCloseDayAlert = true
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "lock.shield.fill")
                                    .font(.system(size: 15))
                                Text("إغلاق اليومية وبدء يوم جديد")
                                    .font(.system(size: 14, weight: .black))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(AdamTheme.amber)
                            .cornerRadius(12)
                        }
                    }

                    // أزرار التبديل بين اليومية الحالية والأرشيف والإجمالي
                    HStack(spacing: 8) {
                        ForEach(ReportTab.allCases, id: \.self) { tab in
                            Button(action: {
                                currentTab = tab
                            }) {
                                Text(tab.rawValue)
                                    .font(.system(size: 13, weight: currentTab == tab ? .black : .medium))
                                    .foregroundColor(currentTab == tab ? .white : AdamTheme.textSecondary)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(currentTab == tab ? AdamTheme.red : AdamTheme.card)
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(currentTab == tab ? Color.clear : AdamTheme.border, lineWidth: 1)
                                    )
                            }
                        }
                        Spacer()
                    }
                }
                .padding()
                .background(AdamTheme.card)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AdamTheme.border, lineWidth: 1))

                // بطاقات الإحصاءات الثلاثية (المبيعات - المصاريف = صافي الربح)
                HStack(spacing: 12) {
                    StatCard(
                        title: currentTab == .active ? "مبيعات اليومية" : "إجمالي المبيعات",
                        value: DataManager.formatMoney(currentSales),
                        subtitle: "\(currentOrders.count) طلبات",
                        icon: "bag.fill",
                        color: AdamTheme.green
                    )

                    StatCard(
                        title: currentTab == .active ? "مصاريف اليومية" : "إجمالي المصاريف",
                        value: DataManager.formatMoney(currentExpenses),
                        subtitle: currentTab == .active ? "\(dataManager.activeExpenses.count) مشتريات اليوم" : "\(currentExpensesList.count) مشتريات",
                        icon: "arrow.down.right.circle.fill",
                        color: AdamTheme.red
                    )

                    StatCard(
                        title: "صافي الأرباح",
                        value: DataManager.formatMoney(currentNetProfit),
                        subtitle: currentNetProfit >= 0 ? "أرباح صافية 🎉" : "عجز مالي",
                        icon: currentNetProfit >= 0 ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis",
                        color: currentNetProfit >= 0 ? AdamTheme.green : AdamTheme.red
                    )
                }

                // تفاصيل طلبات هذا القسم
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(currentTab == .active ? "طلبات اليومية الحالية (قيد العمل)" : (currentTab == .closed ? "سجل طلبات الأيام السابقة المغلقة" : "جميع الطلبات المسجلة"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AdamTheme.textPrimary)
                        Spacer()
                        Text("\(currentOrders.count) طلب")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AdamTheme.textSecondary)
                    }

                    if currentOrders.isEmpty {
                        VStack(spacing: 8) {
                            Text(currentTab == .active ? "اليومية الحالية فارغة أو تم إغلاقها حديثاً." : "لا توجد طلبات في هذا القسم.")
                                .foregroundColor(AdamTheme.textSecondary)
                                .font(.system(size: 14))

                            if currentTab == .active && !dataManager.closedOrders.isEmpty {
                                Button("عرض طلبات ومصاريف الأيام السابقة") {
                                    currentTab = .closed
                                }
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AdamTheme.amber)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(currentOrders) { order in
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
                                            if order.isClosed ?? false {
                                                Text("مغلق")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .padding(.horizontal, 5)
                                                    .padding(.vertical, 2)
                                                    .background(Color.gray.opacity(0.2))
                                                    .foregroundColor(.gray)
                                                    .cornerRadius(4)
                                            }
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

                // تفاصيل مصاريف هذا القسم
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(currentTab == .active ? "مصاريف اليومية الحالية" : (currentTab == .closed ? "سجل مصاريف الأيام السابقة المغلقة" : "جميع المصاريف المسجلة"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AdamTheme.textPrimary)
                        Spacer()
                        Text("\(currentExpensesList.count) مشتريات")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AdamTheme.textSecondary)
                    }

                    if currentExpensesList.isEmpty {
                        VStack(spacing: 8) {
                            Text(currentTab == .active ? "لا توجد مصاريف مسجلة لليومية الحالية بعد." : "لا توجد مصاريف في هذا القسم.")
                                .foregroundColor(AdamTheme.textSecondary)
                                .font(.system(size: 14))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(currentExpensesList) { exp in
                                HStack {
                                    VStack(alignment: .leading, spacing: 3) {
                                        HStack(spacing: 6) {
                                            Text(exp.name)
                                                .font(.system(size: 15, weight: .bold))
                                                .foregroundColor(AdamTheme.textPrimary)

                                            if exp.isClosed ?? false {
                                                Text("مؤرشف")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .padding(.horizontal, 5)
                                                    .padding(.vertical, 2)
                                                    .background(Color.gray.opacity(0.2))
                                                    .foregroundColor(.gray)
                                                    .cornerRadius(4)
                                            }
                                        }

                                        HStack(spacing: 8) {
                                            Text(exp.category)
                                                .font(.system(size: 11, weight: .bold))
                                                .padding(.horizontal, 6)
                                                .padding(.vertical, 2)
                                                .background(Color.blue.opacity(0.18))
                                                .foregroundColor(.blue)
                                                .cornerRadius(6)
                                            Text(exp.date.formatted(date: .abbreviated, time: .omitted))
                                                .font(.system(size: 12))
                                                .foregroundColor(AdamTheme.textSecondary)
                                            if !exp.note.isEmpty {
                                                Text("• \(exp.note)")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(AdamTheme.textSecondary)
                                            }
                                        }
                                    }

                                    Spacer()

                                    Text(DataManager.formatMoney(exp.amount))
                                        .font(.system(size: 16, weight: .black))
                                        .foregroundColor(AdamTheme.red)

                                    Button(action: {
                                        dataManager.deleteExpense(id: exp.id)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(AdamTheme.red.opacity(0.7))
                                            .padding(8)
                                    }
                                    .buttonStyle(PlainButtonStyle())
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
        .alert(isPresented: $showingCloseDayAlert) {
            Alert(
                title: Text("إغلاق اليومية"),
                message: Text("هل أنت متأكد أنك تريد إغلاق يوم العمل الحالي؟\nسيتم حفظ مبيعات ومصاريف هذا اليوم في الأرشيف لتبقى ثابتة، وتبدأ اليومية الجديدة برصيد صفر."),
                primaryButton: .destructive(Text("نعم، إغلاق وبدء يوم جديد")) {
                    dataManager.closeCurrentDay()
                    currentTab = .closed
                },
                secondaryButton: .cancel(Text("إلغاء"))
            )
        }
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
                .font(.system(size: 20, weight: .black))
                .foregroundColor(color)
                .minimumScaleFactor(0.75)
                .lineLimit(1)

            Text(subtitle)
                .font(.system(size: 11))
                .foregroundColor(AdamTheme.textSecondary)
        }
        .padding(14)
        .background(AdamTheme.card)
        .cornerRadius(14)
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(AdamTheme.border, lineWidth: 1))
    }
}
