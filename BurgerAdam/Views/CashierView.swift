import SwiftUI

public struct CashierView: View {
    @ObservedObject var dataManager: DataManager
    @State private var selectedCategory: String = "الكل"
    @State private var cartItems: [UUID: Int] = [:]
    @State private var searchText: String = ""

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
        GridItem(.adaptive(minimum: 150, maximum: 190), spacing: 12)
    ]

    public var body: some View {
        HStack(spacing: 0) {
            // القسم الرئيسي: المنيو والأصناف
            VStack(spacing: 0) {
                // شريط البحث وتصنيفات المنيو
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(AdamTheme.textSecondary)
                        TextField("بحث عن وجبة أو مشروب...", text: $searchText)
                            .font(.system(size: 15))
                            .foregroundColor(AdamTheme.textPrimary)
                        if !searchText.isEmpty {
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(AdamTheme.textSecondary)
                            }
                        }
                    }
                    .padding(10)
                    .background(AdamTheme.card)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AdamTheme.border, lineWidth: 1))
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // أزرار الفئات
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(categories, id: \.self) { cat in
                                Button(action: {
                                    selectedCategory = cat
                                }) {
                                    Text(cat)
                                        .font(.system(size: 13, weight: .bold))
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .background(selectedCategory == cat ? AdamTheme.amber : AdamTheme.card)
                                        .foregroundColor(selectedCategory == cat ? .black : AdamTheme.textPrimary)
                                        .cornerRadius(20)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 20)
                                                .stroke(selectedCategory == cat ? AdamTheme.amber : AdamTheme.border, lineWidth: 1)
                                        )
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 6)
                }
                .background(AdamTheme.bg)

                Divider().background(AdamTheme.border)

                // شبكة الأصناف (بدون ظلال لمنع استهلاك البطارية والحرارة)
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredItems) { item in
                            MenuItemCard(item: item, cartQty: cartItems[item.id] ?? 0) {
                                cartItems[item.id] = (cartItems[item.id] ?? 0) + 1
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                    }
                    .padding(14)
                }
            }
            .frame(maxWidth: .infinity)

            Divider().background(AdamTheme.border)

            // القسم الجانبي: السلة والدفع السريع
            CartView(dataManager: dataManager, cartItems: $cartItems)
                .frame(width: 360)
        }
        .background(AdamTheme.bg)
    }
}

// كرت الصنف فائق الكفاءة والسرعة
struct MenuItemCard: View {
    let item: MenuItem
    let cartQty: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    Text(item.emoji)
                        .font(.system(size: 42))
                        .frame(maxWidth: .infinity)
                        .frame(height: 64)
                        .background(AdamTheme.bg)
                        .cornerRadius(10)

                    if cartQty > 0 {
                        Text("\(cartQty)")
                            .font(.system(size: 12, weight: .black))
                            .foregroundColor(.black)
                            .frame(width: 22, height: 22)
                            .background(AdamTheme.amber)
                            .clipShape(Circle())
                            .offset(x: 4, y: -4)
                    }
                }

                Text(item.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(AdamTheme.textPrimary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(height: 36)

                Text(DataManager.formatMoney(item.price))
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(AdamTheme.green)

                Text("اضغط للإضافة")
                    .font(.system(size: 11))
                    .foregroundColor(AdamTheme.textSecondary)
            }
            .padding(10)
            .background(AdamTheme.card)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(cartQty > 0 ? AdamTheme.green : AdamTheme.border, lineWidth: cartQty > 0 ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
