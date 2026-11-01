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
                            .shadow(color: Color.orange.opacity(0.35), radius: 6, x: 0, y: 3)
                        Text("🍔")
                            .font(.system(size: 24))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("بركر ادم")
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(.white)
                        Text("نظام الكاشير وإدارة القاصة والأرباح")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color.white.opacity(0.75))
                    }
                }

                Spacer()

                // مؤشر الحفظ التلقائي المحلي
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("محلي • يعمل بدون إنترنت")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color.green.opacity(0.9))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.12))
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(Color(red: 15/255, green: 23/255, blue: 42/255)) // slate-900

            // شريط التبويبات العلوي للآيباد (Tabs)
            HStack(spacing: 8) {
                TabButton(title: "الكاشير والطلبات", icon: "cart.fill", isSelected: selectedTab == 0) {
                    withAnimation { selectedTab = 0 }
                }
                TabButton(title: "المصاريف والنفقات", icon: "banknote.fill", isSelected: selectedTab == 1) {
                    withAnimation { selectedTab = 1 }
                }
                TabButton(title: "إغلاق القاصة Z-Report", icon: "lock.shield.fill", isSelected: selectedTab == 2) {
                    withAnimation { selectedTab = 2 }
                }
                TabButton(title: "الأرباح والإحصائيات", icon: "chart.pie.fill", isSelected: selectedTab == 3) {
                    withAnimation { selectedTab = 3 }
                }
                TabButton(title: "المنيو والنسخ", icon: "gearshape.fill", isSelected: selectedTab == 4) {
                    withAnimation { selectedTab = 4 }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(Color(UIColor.secondarySystemBackground))

            // محتوى الصفحات
            ZStack {
                switch selectedTab {
                case 0:
                    CashierView(dataManager: dataManager)
                case 1:
                    ExpensesView(dataManager: dataManager)
                case 2:
                    ZReportView(dataManager: dataManager)
                case 3:
                    ReportsView(dataManager: dataManager)
                case 4:
                    SettingsAndBackupView(dataManager: dataManager)
                default:
                    CashierView(dataManager: dataManager)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .environment(\.layoutDirection, .rightToLeft)
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}
