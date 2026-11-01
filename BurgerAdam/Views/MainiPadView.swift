import SwiftUI

public struct MainiPadView: View {
    @StateObject private var dataManager = DataManager()
    @State private var selectedTab: Int = 0

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            // شريط العنوان العلوي الفاخر
            HStack(spacing: 12) {
                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.yellow, Color.orange]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 44, height: 44)
                        Text("🍔")
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("بركر ادم")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                        Text("نظام الكاشير والمصاريف والأرباح")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AdamTheme.textSecondary)
                    }
                }

                Spacer()

                // مؤشر العمل بدون إنترنت
                HStack(spacing: 6) {
                    Circle()
                        .fill(AdamTheme.green)
                        .frame(width: 8, height: 8)
                    Text("محلي • يعمل بدون إنترنت")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(AdamTheme.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(AdamTheme.green.opacity(0.12))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AdamTheme.green.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(AdamTheme.bg)

            // شريط التبويبات العلوي للآيباد
            HStack(spacing: 8) {
                TabButton(title: "الكاشير والطلبات", icon: "cart.fill", isSelected: selectedTab == 0) {
                    selectedTab = 0
                }
                TabButton(title: "المصاريف والنفقات", icon: "banknote.fill", isSelected: selectedTab == 1) {
                    selectedTab = 1
                }
                TabButton(title: "الأرباح والتقارير", icon: "chart.pie.fill", isSelected: selectedTab == 2) {
                    selectedTab = 2
                }
                TabButton(title: "المنيو والنسخ الاحتياطي", icon: "gearshape.fill", isSelected: selectedTab == 3) {
                    selectedTab = 3
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(AdamTheme.card)
            .overlay(Rectangle().frame(height: 1).foregroundColor(AdamTheme.border), alignment: .bottom)

            // محتوى الصفحات
            ZStack {
                switch selectedTab {
                case 0:
                    CashierView(dataManager: dataManager)
                case 1:
                    ExpensesView(dataManager: dataManager)
                case 2:
                    ReportsView(dataManager: dataManager)
                case 3:
                    SettingsAndBackupView(dataManager: dataManager)
                default:
                    CashierView(dataManager: dataManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(AdamTheme.bg)
    }
}

// زر التبويب المخصص للآيباد (خفيف وبدون ظلال لمنع استهلاك البطارية والحرارة)
struct TabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .bold))
                Text(title)
                    .font(.system(size: 14, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? AdamTheme.amber : AdamTheme.bg)
            .foregroundColor(isSelected ? .black : AdamTheme.textPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AdamTheme.amber : AdamTheme.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
