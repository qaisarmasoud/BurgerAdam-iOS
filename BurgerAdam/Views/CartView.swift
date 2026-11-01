import SwiftUI

public struct CartView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var cartItems: [UUID: Int]
    @State private var orderNote = ""
    @State private var orderType: OrderType = .takeaway
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var completedOrder: Order?

    private var itemsList: [(item: MenuItem, qty: Int)] {
        cartItems.compactMap { (id, qty) in
            guard qty > 0, let menuItem = dataManager.menuItems.first(where: { $0.id == id }) else { return nil }
            return (menuItem, qty)
        }.sorted { $0.item.name < $1.item.name }
    }

    private var totalAmount: Int {
        itemsList.reduce(0) { $0 + ($1.item.price * $1.qty) }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // ترويسة السلة
            HStack {
                Text("الطلب الحالي")
                    .font(.system(size: 19, weight: .bold))
                    .foregroundColor(AdamTheme.textPrimary)
                Spacer()
                if !itemsList.isEmpty {
                    Button(action: {
                        cartItems.removeAll()
                    }) {
                        Text("تفريغ")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AdamTheme.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(AdamTheme.red.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
            }
            .padding(14)
            .background(AdamTheme.card)

            // شريط إحصائي سريع للكاشير
            HStack {
                Text("اليومية الحالية: \(DataManager.formatMoney(dataManager.activeSalesTotal)) (\(dataManager.activeOrders.count) طلب)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AdamTheme.green)
                Spacer()
                Text("العدد الكلي: #\(dataManager.orders.count)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AdamTheme.amber)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(AdamTheme.bg)

            Divider().background(AdamTheme.border)

            if itemsList.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 46))
                        .foregroundColor(AdamTheme.textSecondary.opacity(0.5))
                    Text("السلة فارغة")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(AdamTheme.textSecondary)
                    Text("اضغط على أي وجبة أو مشروب من القائمة لإضافتها للطلب")
                        .font(.system(size: 13))
                        .foregroundColor(AdamTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer()
                }
            } else {
                List {
                    ForEach(itemsList, id: \.item.id) { pair in
                        HStack(spacing: 10) {
                            Text(pair.item.emoji)
                                .font(.system(size: 24))
                                .frame(width: 34, height: 34)
                                .background(AdamTheme.bg)
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(pair.item.name)
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(AdamTheme.textPrimary)
                                Text(DataManager.formatMoney(pair.item.price * pair.qty))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(AdamTheme.green)
                            }

                            Spacer()

                            HStack(spacing: 8) {
                                Button(action: {
                                    let current = cartItems[pair.item.id] ?? 0
                                    if current <= 1 {
                                        cartItems.removeValue(forKey: pair.item.id)
                                    } else {
                                        cartItems[pair.item.id] = current - 1
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(AdamTheme.red.opacity(0.85))
                                }

                                Text("\(pair.qty)")
                                    .font(.system(size: 15, weight: .black))
                                    .foregroundColor(AdamTheme.textPrimary)
                                    .frame(minWidth: 20)

                                Button(action: {
                                    cartItems[pair.item.id] = (cartItems[pair.item.id] ?? 0) + 1
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(AdamTheme.green)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                        .listRowBackground(AdamTheme.card)
                    }
                }
                .listStyle(PlainListStyle())
                .background(AdamTheme.card)

                // خيارات الدفع والطلب
                VStack(spacing: 10) {
                    Picker("نوع الطلب", selection: $orderType) {
                        ForEach(OrderType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    Picker("طريقة الدفع", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    TextField("ملاحظة (مثال: بدون بصل، زيادة صوص)", text: $orderNote)
                        .padding(10)
                        .background(AdamTheme.bg)
                        .foregroundColor(AdamTheme.textPrimary)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))
                        .font(.system(size: 13))

                    HStack {
                        Text("المجموع المطلوب:")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AdamTheme.textSecondary)
                        Spacer()
                        Text(DataManager.formatMoney(totalAmount))
                            .font(.system(size: 21, weight: .black))
                            .foregroundColor(AdamTheme.green)
                    }

                    Button(action: completeSale) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 17, weight: .bold))
                            Text("تسجيل البيع وحفظه")
                                .font(.system(size: 16, weight: .black))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AdamTheme.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding(14)
                .background(AdamTheme.card)
                .overlay(Rectangle().frame(height: 1).foregroundColor(AdamTheme.border), alignment: .top)
            }
        }
        .background(AdamTheme.card)
        .sheet(item: $completedOrder) { order in
            ReceiptView(order: order)
        }
    }

    private func completeSale() {
        guard !itemsList.isEmpty else { return }
        let orderItems = itemsList.map { pair in
            OrderItem(menuItemId: pair.item.id, name: pair.item.name, unitPrice: pair.item.price, quantity: pair.qty)
        }
        let order = dataManager.addOrder(
            items: orderItems,
            note: orderNote.trimmingCharacters(in: .whitespacesAndNewlines),
            orderType: orderType,
            paymentMethod: paymentMethod
        )
        cartItems.removeAll()
        orderNote = ""
        completedOrder = order
    }
}
