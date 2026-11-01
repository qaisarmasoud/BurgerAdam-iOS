import SwiftUI

public struct ReceiptView: View {
    public let order: Order
    @Environment(\.presentationMode) var presentationMode

    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 6) {
                        Text("🍔")
                            .font(.system(size: 46))
                        Text("بركر ادم")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(AdamTheme.textPrimary)
                        Text("نظام الكاشير والمبيعات")
                            .font(.system(size: 13))
                            .foregroundColor(AdamTheme.textSecondary)
                    }
                    .padding(.top, 10)

                    Divider().background(AdamTheme.border)

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("رقم الطلب:")
                                .fontWeight(.bold)
                                .foregroundColor(AdamTheme.textPrimary)
                            Spacer()
                            Text("#\(order.orderNumber)")
                                .fontWeight(.black)
                                .foregroundColor(.blue)
                        }

                        HStack {
                            Text("التاريخ والوقت:")
                                .foregroundColor(AdamTheme.textSecondary)
                            Spacer()
                            Text(order.date.formatted(date: .abbreviated, time: .shortened))
                                .foregroundColor(AdamTheme.textPrimary)
                        }

                        HStack {
                            Text("نوع الطلب:")
                                .foregroundColor(AdamTheme.textSecondary)
                            Spacer()
                            Text(order.orderType.rawValue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AdamTheme.amber.opacity(0.18))
                                .foregroundColor(AdamTheme.amber)
                                .cornerRadius(6)
                        }

                        HStack {
                            Text("طريقة الدفع:")
                                .foregroundColor(AdamTheme.textSecondary)
                            Spacer()
                            Text(order.paymentMethod.rawValue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(AdamTheme.green.opacity(0.18))
                                .foregroundColor(AdamTheme.green)
                                .cornerRadius(6)
                        }

                        if !order.note.isEmpty {
                            HStack(alignment: .top) {
                                Text("ملاحظة:")
                                    .foregroundColor(AdamTheme.textSecondary)
                                Spacer()
                                Text(order.note)
                                    .foregroundColor(AdamTheme.textPrimary)
                            }
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.horizontal)

                    Divider().background(AdamTheme.border)

                    // جدول الأصناف
                    VStack(spacing: 8) {
                        HStack {
                            Text("الصنف")
                                .fontWeight(.bold)
                            Spacer()
                            Text("الكمية")
                                .fontWeight(.bold)
                            Spacer()
                            Text("السعر")
                                .fontWeight(.bold)
                        }
                        .font(.system(size: 13))
                        .foregroundColor(AdamTheme.textSecondary)

                        ForEach(order.items) { item in
                            HStack {
                                Text(item.name)
                                    .fontWeight(.semibold)
                                    .foregroundColor(AdamTheme.textPrimary)
                                Spacer()
                                Text("× \(item.quantity)")
                                    .foregroundColor(AdamTheme.textSecondary)
                                Spacer()
                                Text(DataManager.formatMoney(item.totalPrice))
                                    .fontWeight(.bold)
                                    .foregroundColor(AdamTheme.green)
                            }
                            .font(.system(size: 14))
                        }
                    }
                    .padding(.horizontal)

                    Divider().background(AdamTheme.border)

                    HStack {
                        Text("المجموع النهائي:")
                            .font(.system(size: 17, weight: .bold))
                            .foregroundColor(AdamTheme.textPrimary)
                        Spacer()
                        Text(DataManager.formatMoney(order.total))
                            .font(.system(size: 21, weight: .black))
                            .foregroundColor(AdamTheme.green)
                    }
                    .padding(.horizontal)

                    Text("شكراً لزيارتكم! نتشرف بخدمتكم دائماً")
                        .font(.system(size: 12))
                        .foregroundColor(AdamTheme.textSecondary)
                        .padding(.top, 8)
                }
                .padding()
                .background(AdamTheme.card)
                .cornerRadius(16)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(AdamTheme.border, lineWidth: 1))
                .padding()
            }
            .background(AdamTheme.bg)
            .navigationTitle("فاتورة الطلب")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("إغلاق") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: printReceipt) {
                        Label("طباعة", systemImage: "printer.fill")
                    }
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }

    private func printReceipt() {
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "فاتورة بركر ادم #\(order.orderNumber)"
        printController.printInfo = printInfo

        let formatter = UIMarkupTextPrintFormatter(markupText: generateHTMLReceipt())
        formatter.perPageContentInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        printController.printFormatter = formatter

        printController.present(animated: true, completionHandler: nil)
    }

    private func generateHTMLReceipt() -> String {
        var itemsHtml = ""
        for item in order.items {
            itemsHtml += """
            <tr>
                <td style="padding:6px 0;border-bottom:1px solid #eee;">\(item.name)</td>
                <td style="padding:6px 0;text-align:center;border-bottom:1px solid #eee;">\(item.quantity)</td>
                <td style="padding:6px 0;text-align:left;border-bottom:1px solid #eee;">\(DataManager.formatMoney(item.totalPrice))</td>
            </tr>
            """
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
                table { width: 100%; border-collapse: collapse; margin: 12px 0; }
                .total { font-size: 18px; margin-top: 10px; border-top: 2px dashed #000; padding-top: 10px; }
            </style>
        </head>
        <body>
            <div class="center">
                <h2 style="margin:4px 0;">🍔 بركر ادم</h2>
                <div style="font-size:12px;">نظام الكاشير والمبيعات</div>
                <div style="font-size:14px; margin-top:8px;" class="bold">طلب رقم: #\(order.orderNumber)</div>
                <div style="font-size:11px; color:#555;">\(order.date.formatted(date: .abbreviated, time: .shortened))</div>
                <div style="font-size:12px; margin:4px 0;">النوع: \(order.orderType.rawValue) | الدفع: \(order.paymentMethod.rawValue)</div>
            </div>
            <table>
                <thead>
                    <tr style="border-bottom:1px solid #000; font-size:12px;">
                        <th style="text-align:right;">الصنف</th>
                        <th>العدد</th>
                        <th style="text-align:left;">السعر</th>
                    </tr>
                </thead>
                <tbody>
                    \(itemsHtml)
                </tbody>
            </table>
            <div class="total bold" style="display:flex; justify-content:space-between;">
                <span>المجموع:</span>
                <span>\(DataManager.formatMoney(order.total))</span>
            </div>
            \(order.note.isEmpty ? "" : "<div style='margin-top:8px;font-size:12px;'>ملاحظة: \(order.note)</div>")
            <div class="center" style="margin-top:16px; font-size:11px; color:#666;">شكراً لزيارتكم! نتشرف بخدمتكم</div>
        </body>
        </html>
        """
    }
}
