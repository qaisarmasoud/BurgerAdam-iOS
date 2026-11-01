import SwiftUI

public struct ZReportView: View {
    @ObservedObject var dataManager: DataManager
    @State private var actualCashString: String = ""
    @State private var showingCloseAlert = false
    @State private var newCashierName = "كاشير 1"
    @State private var newStartingCashString = "50000"

    private var todaySales: (cash: Int, zainCash: Int, card: Int) {
        dataManager.salesByPaymentMethod(for: Date())
    }

    private var todayExpenses: Int {
        dataManager.totalExpenses(for: Date())
    }

    private var expectedCash: Int {
        dataManager.shiftExpectedCash()
    }

    private var actualCash: Int? {
        Int(actualCashString.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    private var cashDifference: Int? {
        guard let actual = actualCash else { return nil }
        return actual - expectedCash
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // ترويسة الشفت
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("تقرير إغلاق الشفت واستلام القاصة (Z-Report)")
                            .font(.system(size: 22, weight: .black))
                        Text("متابعة النقد وحركة الصندوق وتسليم الشفتات")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    Button(action: printZReport) {
                        HStack {
                            Image(systemName: "printer.fill")
                            Text("طباعة تقرير الشفت")
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)

                // معلومات الكاشير والشفت الحالي
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("الكاشير المسؤول:")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(dataManager.currentShift.cashierName)
                            .font(.system(size: 17, weight: .black))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("وقت بدء الشفت:")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(dataManager.currentShift.startTime.formatted(date: .omitted, time: .shortened))
                            .font(.system(size: 17, weight: .black))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 6) {
                        Text("القاصة الافتتاحية (خردة):")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        Text(DataManager.formatMoney(dataManager.currentShift.startingCash))
                            .font(.system(size: 17, weight: .black))
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                }

                // تفصيل المبيعات والمقبوضات
                VStack(spacing: 12) {
                    HStack {
                        Text("حركة الصندوق والمبيعات اليومية")
                            .font(.system(size: 17, weight: .bold))
                        Spacer()
                    }

                    HStack(spacing: 12) {
                        StatCard(title: "مبيعات النقد (كاش)", value: DataManager.formatMoney(todaySales.cash), subtitle: "دخل الصندوق", icon: "banknote.fill", color: .green)
                        StatCard(title: "مبيعات زين كاش", value: DataManager.formatMoney(todaySales.zainCash), subtitle: "محفظة إلكترونية", icon: "iphone.circle.fill", color: .purple)
                        StatCard(title: "مبيعات البطاقات", value: DataManager.formatMoney(todaySales.card), subtitle: "حساب بنكي", icon: "creditcard.fill", color: .blue)
                    }

                    HStack(spacing: 12) {
                        StatCard(title: "المصاريف المسحوبة", value: DataManager.formatMoney(todayExpenses), subtitle: "خرجت من الصندوق", icon: "arrow.down.right.circle.fill", color: .red)
                        StatCard(title: "الرصيد النقدي المتوقع", value: DataManager.formatMoney(expectedCash), subtitle: "المفروض بالدرج الآن", icon: "lock.shield.fill", color: .orange)
                    }
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)

                // مطابقة القاصة الفعلية
                VStack(alignment: .leading, spacing: 14) {
                    Text("مطابقة النقد الفعلي في القاصة (الجرد)")
                        .font(.system(size: 17, weight: .bold))

                    HStack(spacing: 14) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("أدخل المبلغ النقدي الفعلي الموجود بالدرج:")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(.secondary)
                            TextField("مثال: 125000", text: $actualCashString)
                                .keyboardType(.numberPad)
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                        }

                        if let diff = cashDifference {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("حالة الصندوق:")
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.secondary)
                                HStack {
                                    Text(diff == 0 ? "مطابق تماماً 🎯" : (diff > 0 ? "فائض بالقاصة: +" : "عجز بالقاصة: "))
                                    Text(DataManager.formatMoney(abs(diff)))
                                }
                                .font(.system(size: 16, weight: .black))
                                .foregroundColor(diff == 0 ? .green : (diff > 0 ? .blue : .red))
                                .padding(12)
                                .background(Color(UIColor.secondarySystemBackground))
                                .cornerRadius(10)
                            }
                        }
                    }

                    Button(action: { showingCloseAlert = true }) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("إغلاق الشفت الحالي وبدء شفت جديد")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .sheet(isPresented: $showingCloseAlert) {
            NavigationView {
                Form {
                    Section(header: Text("بيانات الشفت الجديد")) {
                        TextField("اسم الكاشير الجديد", text: $newCashierName)
                        TextField("المبلغ الافتتاحي في القاصة (خردة)", text: $newStartingCashString)
                            .keyboardType(.numberPad)
                    }
                }
                .navigationTitle("بدء شفت جديد")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("إلغاء") { showingCloseAlert = false }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("تأكيد وبدء") {
                            let startCash = Int(newStartingCashString) ?? 50000
                            dataManager.startNewShift(cashierName: newCashierName, startingCash: startCash)
                            actualCashString = ""
                            showingCloseAlert = false
                        }
                        .font(.system(size: 15, weight: .bold))
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
    }

    private func printZReport() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "تقرير إغلاق القاصة Z-Report"
        printController.printInfo = printInfo

        let formatter = UIMarkupTextPrintFormatter(markupText: generateHTMLZReport())
        formatter.perPageContentInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        printController.printFormatter = formatter

        printController.present(animated: true, completionHandler: nil)
    }

    private func generateHTMLZReport() -> String {
        let now = Date().formatted(date: .abbreviated, time: .shortened)
        let actual = actualCash != nil ? DataManager.formatMoney(actualCash!) : "لم يُحدد"
        var diffText = "مطابق"
        if let diff = cashDifference {
            diffText = diff >= 0 ? "فائض: +\(DataManager.formatMoney(diff))" : "عجز: \(DataManager.formatMoney(diff))"
        }

        return """
        <!DOCTYPE html>
        <html dir="rtl" lang="ar">
        <head>
            <meta charset="utf-8">
            <style>
                body { font-family: -apple-system, sans-serif; margin: 0; padding: 15px; width: 300px; color: #111; }
                .center { text-align: center; }
                .bold { font-weight: bold; }
                .row { display: flex; justify-content: space-between; padding: 5px 0; border-bottom: 1px solid #eee; font-size: 13px; }
                .highlight { font-size: 15px; font-weight: bold; }
            </style>
        </head>
        <body>
            <div class="center">
                <h2 style="margin:4px 0;">🍔 بركر ادم</h2>
                <div style="font-size:14px; font-weight:bold;">تقرير إغلاق الصندوق (Z-Report)</div>
                <div style="font-size:11px; color:#555;">\(now)</div>
                <div style="font-size:12px; margin-top:4px;">الكاشير: \(dataManager.currentShift.cashierName)</div>
            </div>
            <hr style="border: 1px dashed #000; margin: 12px 0;" />
            <div class="row"><span>القاصة الافتتاحية:</span><span>\(DataManager.formatMoney(dataManager.currentShift.startingCash))</span></div>
            <div class="row"><span>مبيعات النقد (كاش):</span><span>\(DataManager.formatMoney(todaySales.cash))</span></div>
            <div class="row"><span>مبيعات زين كاش:</span><span>\(DataManager.formatMoney(todaySales.zainCash))</span></div>
            <div class="row"><span>مبيعات البطاقات:</span><span>\(DataManager.formatMoney(todaySales.card))</span></div>
            <div class="row"><span>المصاريف المسحوبة:</span><span style="color:red;">-\(DataManager.formatMoney(todayExpenses))</span></div>
            <hr style="border: 1px solid #000; margin: 10px 0;" />
            <div class="row highlight"><span>النقد المتوقع بالدرج:</span><span>\(DataManager.formatMoney(expectedCash))</span></div>
            <div class="row"><span>النقد الفعلي المسجل:</span><span>\(actual)</span></div>
            <div class="row bold"><span>الفارق:</span><span>\(diffText)</span></div>
            <hr style="border: 1px dashed #000; margin: 12px 0;" />
            <div class="center" style="font-size:11px; color:#555;">تم استخراج التقرير بواسطة نظام بركر ادم</div>
        </body>
        </html>
        """
    }
}
