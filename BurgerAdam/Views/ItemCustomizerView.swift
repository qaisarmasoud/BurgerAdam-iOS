import SwiftUI

public struct ItemCustomizerView: View {
    public let item: MenuItem
    public let onAdd: (OrderItem) -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var quantity: Int = 1
    @State private var selectedAddOns: Set<UUID> = []
    @State private var selectedPreferences: Set<String> = []

    private var currentAddOns: [CustomAddOn] {
        CustomAddOn.defaultAddOns.filter { selectedAddOns.contains($0.id) }
    }

    private var currentPreferences: [String] {
        Array(selectedPreferences)
    }

    private var unitTotal: Int {
        item.price + currentAddOns.reduce(0) { $0 + $1.price }
    }

    private var finalTotal: Int {
        unitTotal * quantity
    }

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // ترويسة الصنف
                    HStack(spacing: 16) {
                        Text(item.emoji)
                            .font(.system(size: 56))
                            .frame(width: 80, height: 80)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(16)

                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.name)
                                .font(.system(size: 22, weight: .black))
                            Text(item.category)
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.secondary)
                            Text(DataManager.formatMoney(item.price))
                                .font(.system(size: 18, weight: .black))
                                .foregroundColor(.green)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)

                    // قسم الإضافات المدفوعة
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.orange)
                            Text("إضافات مدفوعة (اختياري)")
                                .font(.system(size: 16, weight: .bold))
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(CustomAddOn.defaultAddOns) { addOn in
                                let isSelected = selectedAddOns.contains(addOn.id)
                                Button(action: {
                                    withAnimation(.spring(response: 0.2)) {
                                        if isSelected {
                                            selectedAddOns.remove(addOn.id)
                                        } else {
                                            selectedAddOns.insert(addOn.id)
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(isSelected ? .green : .secondary)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(addOn.name)
                                                .font(.system(size: 13, weight: .bold))
                                                .foregroundColor(.primary)
                                            Text("+\(DataManager.formatMoney(addOn.price))")
                                                .font(.system(size: 11, weight: .black))
                                                .foregroundColor(.orange)
                                        }
                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(isSelected ? Color.orange.opacity(0.12) : Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? Color.orange : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)

                    // قسم الرغبات والملاحظات المجانية
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.blue)
                            Text("تفضيلات الزبون (مجاناً)")
                                .font(.system(size: 16, weight: .bold))
                        }

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(CustomAddOn.defaultPreferences, id: \.self) { pref in
                                let isSelected = selectedPreferences.contains(pref)
                                Button(action: {
                                    withAnimation(.spring(response: 0.2)) {
                                        if isSelected {
                                            selectedPreferences.remove(pref)
                                        } else {
                                            selectedPreferences.insert(pref)
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(isSelected ? .blue : .secondary)
                                        Text(pref)
                                            .font(.system(size: 13, weight: .bold))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(10)
                                    .background(isSelected ? Color.blue.opacity(0.12) : Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(10)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)

                    // قسم الكمية
                    HStack {
                        Text("الكمية:")
                            .font(.system(size: 17, weight: .bold))
                        Spacer()
                        HStack(spacing: 16) {
                            Button(action: {
                                if quantity > 1 { quantity -= 1 }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.red.opacity(0.8))
                            }

                            Text("\(quantity)")
                                .font(.system(size: 24, weight: .black))
                                .frame(minWidth: 40)

                            Button(action: {
                                quantity += 1
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)

                    // زر الإضافة للطلب
                    Button(action: {
                        let orderItem = OrderItem(
                            menuItemId: item.id,
                            name: item.name,
                            unitPrice: item.price,
                            quantity: quantity,
                            selectedAddOns: currentAddOns,
                            selectedPreferences: currentPreferences
                        )
                        onAdd(orderItem)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: "cart.fill.badge.plus")
                                .font(.system(size: 18, weight: .bold))
                            Text("إضافة إلى السلة • \(DataManager.formatMoney(finalTotal))")
                                .font(.system(size: 18, weight: .black))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(14)
                        .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("تخصيص الوجبة")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إلغاء") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
