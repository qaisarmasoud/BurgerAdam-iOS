import SwiftUI

public struct CartView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var cartItems: [UUID: Int] // MenuItem ID -> Quantity
    @State private var orderNote = ""
    @State private var orderType: OrderType = .takeaway
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var completedOrder: Order?
    @State private var showReceipt = false
    @State private var showEmptyAlert = false

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
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                if !itemsList.isEmpty {
                    Button(action: {
                        withAnimation { cartItems.removeAll() }
                    }) {
                        Text("تفريغ")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.red)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.red.opacity(0.12))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemBackground))

            Divider()

            if itemsList.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("السلة فارغة")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.secondary)
                    Text("اضغط على أي وجبة أو مشروب من القائمة لإضافتها للطلب")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer()
                }
            } else {
                List {
                    ForEach(itemsList, id: \.item.id) { pair in
                        HStack(spacing: 12) {
                            Text(pair.item.emoji)
                                .font(.system(size: 26))
                                .frame(width: 36, height: 36)
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)

                            VStack(alignment: .leading, spacing: 3) {
                                Text(pair.item.name)
                                    .font(.system(size: 15, weight: .bold))
                                Text(DataManager.formatMoney(pair.item.price * pair.qty))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(.green)
                            }

                            Spacer()

                            // أزرار التحكم بالكمية
                            HStack(spacing: 8) {
                                Button(action: {
                                    withAnimation {
                                        let current = cartItems[pair.item.id] ?? 0
                                        if current <= 1 {
                                            cartItems.removeValue(forKey: pair.item.id)
                                        } else {
                                            cartItems[pair.item.id] = current - 1
                                        }
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.red.opacity(0.8))
                                }

                                Text("\(pair.qty)")
                                    .font(.system(size: 16, weight: .bold))
                                    .frame(minWidth: 24)

                                Button(action: {
                                    withAnimation {
                                        cartItems[pair.item.id] = (cartItems[pair.item.id] ?? 0) + 1
                                    }
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())

                // قسم الخيارات والدفع
                VStack(spacing: 12) {
                    // اختيار نوع الطلب
                    Picker("نوع الطلب", selection: $orderType) {
                        ForEach(OrderType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // اختيار طريقة الدفع
                    Picker("طريقة الدفع", selection: $paymentMethod) {
                        ForEach(PaymentMethod.allCases, id: \.self) { method in
                            Text(method.rawValue).tag(method)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    // ملاحظات الطلب
                    TextField("ملاحظة (مثال: بدون بصل، زيادة مايونيز)", text: $orderNote)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .font(.system(size: 14))

                    // شريط المجموع
                    HStack {
                        Text("المجموع المطلوب:")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(DataManager.formatMoney(totalAmount))
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.green)
                    }
                    .padding(.top, 4)

                    // زر تسجيل البيع
                    Button(action: completeSale) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 18, weight: .bold))
                            Text("تسجيل البيع وإصدار الوصل")
                                .font(.system(size: 17, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: -4)
            }
        }
        .background(Color(UIColor.systemBackground))
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
        // تفريغ السلة وتصفير الملاحظة
        cartItems.removeAll()
        orderNote = ""
        completedOrder = order
    }
}
