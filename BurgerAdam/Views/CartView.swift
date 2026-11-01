import SwiftUI

public struct CartView: View {
    @ObservedObject var dataManager: DataManager
    @Binding var cartItems: [OrderItem]
    @State private var orderNote = ""
    @State private var orderType: OrderType = .takeaway
    @State private var paymentMethod: PaymentMethod = .cash
    @State private var completedOrder: Order?

    private var totalAmount: Int {
        cartItems.reduce(0) { $0 + $1.totalPrice }
    }

    public var body: some View {
        VStack(spacing: 0) {
            // ترويسة السلة
            HStack {
                Text("الطلب الحالي")
                    .font(.system(size: 20, weight: .bold))
                Spacer()
                if !cartItems.isEmpty {
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

            if cartItems.isEmpty {
                VStack(spacing: 12) {
                    Spacer()
                    Image(systemName: "cart.badge.plus")
                        .font(.system(size: 50))
                        .foregroundColor(.secondary.opacity(0.6))
                    Text("السلة فارغة")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.secondary)
                    Text("اضغط على أي وجبة لتخصيص الإضافات وإضافتها للطلب")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    Spacer()
                }
            } else {
                List {
                    ForEach(Array(cartItems.enumerated()), id: \.element.id) { index, item in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(item.name)
                                    .font(.system(size: 15, weight: .bold))
                                Spacer()
                                Text(DataManager.formatMoney(item.totalPrice))
                                    .font(.system(size: 14, weight: .black))
                                    .foregroundColor(.green)
                            }

                            // عرض الإضافات والرغبات
                            if !item.selectedAddOns.isEmpty {
                                HStack(spacing: 4) {
                                    Text("إضافات:")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.orange)
                                    Text(item.selectedAddOns.map { "\($0.name) (+\($0.price))" }.joined(separator: " ، "))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }

                            if !item.selectedPreferences.isEmpty {
                                HStack(spacing: 4) {
                                    Text("تفضيلات:")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(.blue)
                                    Text(item.selectedPreferences.joined(separator: " ، "))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }

                            HStack {
                                Text("السعر الفردي: \(DataManager.formatMoney(item.singleItemTotal))")
                                    .font(.system(size: 11))
                                    .foregroundColor(.secondary)

                                Spacer()

                                // أزرار الكمية
                                HStack(spacing: 10) {
                                    Button(action: {
                                        withAnimation {
                                            if cartItems[index].quantity > 1 {
                                                cartItems[index].quantity -= 1
                                            } else {
                                                cartItems.remove(at: index)
                                            }
                                        }
                                    }) {
                                        Image(systemName: "minus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.red.opacity(0.8))
                                    }

                                    Text("\(item.quantity)")
                                        .font(.system(size: 16, weight: .bold))
                                        .frame(minWidth: 20)

                                    Button(action: {
                                        withAnimation {
                                            cartItems[index].quantity += 1
                                        }
                                    }) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())

                // خيارات الدفع والطلب
                VStack(spacing: 12) {
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

                    TextField("ملاحظات إضافية على الطلب...", text: $orderNote)
                        .padding(10)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                        .font(.system(size: 14))

                    HStack {
                        Text("المجموع النهائي:")
                            .font(.system(size: 16, weight: .bold))
                        Spacer()
                        Text(DataManager.formatMoney(totalAmount))
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.green)
                    }

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
        guard !cartItems.isEmpty else { return }
        let order = dataManager.addOrder(
            items: cartItems,
            note: orderNote.trimmingCharacters(in: .whitespacesAndNewlines),
            orderType: orderType,
            paymentMethod: paymentMethod
        )
        cartItems.removeAll()
        orderNote = ""
        completedOrder = order
    }
}
