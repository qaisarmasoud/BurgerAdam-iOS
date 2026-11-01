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
                            .font(.system(size: 48))
                        Text("بركر ادم")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.primary)
                        Text("نظام الكاشير والمبيعات")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 10)

                    Divider()

                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("رقم الطلب:")
                                .fontWeight(.bold)
                            Spacer()
                            Text("#\(order.orderNumber)")
                                .fontWeight(.black)
                                .foregroundColor(.blue)
                        }

                        HStack {
                            Text("التاريخ والوقت:")
                            Spacer()
                            Text(order.date.formatted(date: .abbreviated, time: .shortened))
                        }

                        HStack {
                            Text("نوع الطلب:")
                            Spacer()
                            Text(order.orderType.rawValue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .cornerRadius(6)
                        }

                        HStack {
                            Text("طريقة الدفع:")
                            Spacer()
                            Text(order.paymentMethod.rawValue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green.opacity(0.15))
                                .foregroundColor(.green)
                                .cornerRadius(6)
                        }

                        if !order.note.isEmpty {
                            HStack(alignment: .top) {
                                Text("ملاحظة:")
                                Spacer()
                                Text(order.note)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .font(.system(size: 14))
                    .padding(.horizontal)

                    Divider()

                    // قائمة الأصناف مع الإضافات
                    VStack(spacing: 12) {
                        ForEach(order.items) { item in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text("\(item.name) × \(item.quantity)")
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(DataManager.formatMoney(item.totalPrice))
                                        .fontWeight(.black)
                                }
                                .font(.system(size: 14))

                                if !item.selectedAddOns.isEmpty {
                                    Text("+ " + item.selectedAddOns.map { "\($0.name) (+\($0.price))" }.joined(separator: " ، "))
                                        .font(.system(size: 11))
                                        .foregroundColor(.orange)
                                }

                                if !item.selectedPreferences.isEmpty {
                                    Text("• " + item.selectedPreferences.joined(separator: " ، "))
                                        .font(.system(size: 11))
                                        .foregroundColor(.secondary)
                                }
                            }
                            Divider()
                        }
                    }
                    .padding(.horizontal)

                    HStack {
                        Text("المجموع النهائي:")
                            .font(.system(size: 18, weight: .bold))
                        Spacer()
                        Text(DataManager.formatMoney(order.total))
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal)

                    Text("شكراً لزيارتكم! نتشرف بخدمتكم دائماً")
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(16)
                .padding()
            }
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
            var subdetails = ""
            if !item.selectedAddOns.isEmpty {
                subdetails += "<div style='font-size:10px; color:#d97706;'>+ " + item.selectedAddOns.map { "\($0.name) (+\($0.price))" }.joined(separator: " ، ") + "</div>"
            }
            if !item.selectedPreferences.isEmpty {
                subdetails += "<div style='font-size:10px; color:#666;'>• " + item.selectedPreferences.joined(separator: " ، ") + "</div>"
            }

            itemsHtml += """
            <tr>
                <td style="padding:6px 0;border-bottom:1px solid #eee;">
                    <div>\(item.name)</div>
                    \(subdetails)
                </td>
                <td style="padding:6px 0;text-align:center;border-bottom:1px solid #eee;vertical-align:top;">\(item.quantity)</td>
                <td style="padding:6px 0;text-align:left;border-bottom:1px solid #eee;vertical-align:top;">\(DataManager.formatMoney(item.totalPrice))</td>
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
