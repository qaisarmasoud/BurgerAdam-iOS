import SwiftUI

public struct CashierView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedCategory: String = "الكل"
    @State private var cartItems: [OrderItem] = []
    @State private var searchText: String = ""
    @State private var selectedItemForCustomization: MenuItem?

    private var categories: [String] {
        var list = ["الكل"]
        let cats = Set(dataManager.menuItems.map { $0.category })
        list.append(contentsOf: cats.sorted())
        return list
    }

    private var filteredItems: [MenuItem] {
        dataManager.menuItems.filter { item in
            let matchesCategory = (selectedCategory == "الكل" || item.category == selectedCategory)
            let matchesSearch = searchText.isEmpty || item.name.localizedCaseInsensitiveContains(searchText)
            return matchesCategory && matchesSearch
        }
    }

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 200), spacing: 14)
    ]

    public var body: some View {
        HStack(spacing: 0) {
            // القسم الرئيسي: المنيو والأصناف
            VStack(spacing: 0) {
                // شريط البحث وتصنيفات المنيو
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("بحث عن وجبة أو مشروب...", text: $searchText)
                            .font(.system(size: 15))
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // أزرار الفئات
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: {
                                    withAnimation { selectedCategory = cat }
                                }) {
                                    Text(cat)
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? Color.orange : Color(UIColor.secondarySystemBackground))
                                        .foregroundColor(selectedCategory == cat ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 6)
                }
                .background(Color(UIColor.systemBackground))

                Divider()

                // شبكة الأصناف
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(filteredItems) { item in
                            let countInCart = cartItems.filter { $0.menuItemId == item.id }.reduce(0) { $0 + $1.quantity }
                            MenuItemCard(item: item, cartQty: countInCart) {
                                // فتح نافذة التخصيص
                                selectedItemForCustomization = item
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                            }
                        }
                    }
                    .padding(16)
                }
            }
            .frame(maxWidth: .infinity)

            Divider()

            // القسم الجانبي: السلة والدفع (شاشة مقسومة للآيباد)
            CartView(dataManager: dataManager, cartItems: $cartItems)
                .frame(width: 370)
        }
        .background(Color(UIColor.secondarySystemBackground))
        .sheet(item: $selectedItemForCustomization) { item in
            ItemCustomizerView(item: item) { orderItem in
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    cartItems.append(orderItem)
                }
            }
        }
    }
}

// كرت الصنف
struct MenuItemCard: View {
    let item: MenuItem
    let cartQty: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Text(item.emoji)
                        .font(.system(size: 44))
                        .frame(maxWidth: .infinity)
                        .frame(height: 70)
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(12)

                    if cartQty > 0 {
                        Text("\(cartQty)")
                            .font(.system(size: 13, weight: .black))
                            .foregroundColor(.white)
                            .frame(width: 24, height: 24)
                            .background(Color.green)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                            .shadow(radius: 2)
                    }
                }

                Text(item.name)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 38)

                Text(DataManager.formatMoney(item.price))
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.green)

                Text("تخصيص وإضافة ⚙️")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.orange)
            }
            .padding(12)
            .background(Color(UIColor.systemBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(cartQty > 0 ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
