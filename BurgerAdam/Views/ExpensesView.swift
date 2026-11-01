import SwiftUI

public struct ExpensesView: View {
    @ObservedObject var dataManager: DataManager
    @State private var name: String = ""
    @State private var amountString: String = ""
    @State private var selectedCategory: String = "مواد غذائية (لحوم، خبز)"
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var showAllExpenses: Bool = true // افتراضياً يعرض كل المصاريف لكي لا يختفي أي رقم

    private var todayExpensesTotal: Int {
        dataManager.totalExpenses(for: Date())
    }

    private var displayedExpensesList: [Expense] {
        if showAllExpenses {
            return dataManager.expenses
        } else {
            return dataManager.expenses(for: Date())
        }
    }

    public var body: some View {
        HStack(spacing: 0) {
            // نموذج إضافة مصروف جديد
            VStack(alignment: .leading, spacing: 14) {
                Text("تسجيل مصروف جديد")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(AdamTheme.textPrimary)

                VStack(alignment: .leading, spacing: 5) {
                    Text("اسم المصروف / البند")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AdamTheme.textSecondary)
                    TextField("مثال: صمون، لحم، غاز، خضار...", text: $name)
                        .padding(11)
                        .background(AdamTheme.bg)
                        .foregroundColor(AdamTheme.textPrimary)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("المبلغ (بالدينار العراقي)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AdamTheme.textSecondary)
                    TextField("مثال: 25000", text: $amountString)
                        .keyboardType(.numberPad)
                        .padding(11)
                        .background(AdamTheme.bg)
                        .foregroundColor(AdamTheme.textPrimary)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("فئة المصروف")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AdamTheme.textSecondary)
                    Picker("الفئة", selection: $selectedCategory) {
                        ForEach(Expense.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AdamTheme.bg)
                    .foregroundColor(AdamTheme.textPrimary)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("التاريخ")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AdamTheme.textSecondary)
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .padding(4)
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text("ملاحظات إضافية")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AdamTheme.textSecondary)
                    TextField("تفاصيل إضافية...", text: $note)
                        .padding(11)
                        .background(AdamTheme.bg)
                        .foregroundColor(AdamTheme.textPrimary)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))
                }

                Spacer()

                Button(action: saveExpense) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("حفظ المصروف")
                            .fontWeight(.bold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(AdamTheme.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(18)
            .frame(width: 360)
            .background(AdamTheme.card)

            Divider().background(AdamTheme.border)

            // قائمة المصاريف السابقة
            VStack(spacing: 0) {
                // شريط إحصائيات المصاريف الثنائية (الشفت الحالي + الإجمالي الكلي)
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("إجمالي المصاريف الكلية:")
                            .font(.system(size: 12))
                            .foregroundColor(AdamTheme.textSecondary)
                        Text(DataManager.formatMoney(dataManager.allTimeExpensesTotal))
                            .font(.system(size: 19, weight: .black))
                            .foregroundColor(AdamTheme.red)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AdamTheme.bg)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("مصاريف شفت اليوم:")
                            .font(.system(size: 12))
                            .foregroundColor(AdamTheme.textSecondary)
                        Text(DataManager.formatMoney(todayExpensesTotal))
                            .font(.system(size: 19, weight: .black))
                            .foregroundColor(AdamTheme.amber)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(AdamTheme.bg)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AdamTheme.border, lineWidth: 1))

                    // زر التبديل بين الكل واليوم
                    Button(action: {
                        showAllExpenses.toggle()
                    }) {
                        Text(showAllExpenses ? "عرض: الكل" : "عرض: اليوم")
                            .font(.system(size: 12, weight: .bold))
                            .padding(.horizontal, 10)
                            .padding(.vertical, 8)
                            .background(AdamTheme.bg)
                            .foregroundColor(AdamTheme.textPrimary)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(AdamTheme.border, lineWidth: 1))
                    }
                }
                .padding()
                .background(AdamTheme.card)

                Divider().background(AdamTheme.border)

                if displayedExpensesList.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "tray")
                            .font(.system(size: 46))
                            .foregroundColor(AdamTheme.textSecondary.opacity(0.4))
                        Text("لا توجد مصاريف مسجلة")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AdamTheme.textSecondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(displayedExpensesList) { exp in
                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(exp.name)
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(AdamTheme.textPrimary)
                                    HStack(spacing: 8) {
                                        Text(exp.category)
                                            .font(.system(size: 11, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.18))
                                            .foregroundColor(.blue)
                                            .cornerRadius(6)
                                        Text(exp.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 12))
                                            .foregroundColor(AdamTheme.textSecondary)
                                        if !exp.note.isEmpty {
                                            Text("• \(exp.note)")
                                                .font(.system(size: 12))
                                                .foregroundColor(AdamTheme.textSecondary)
                                        }
                                    }
                                }
                                Spacer()
                                Text(DataManager.formatMoney(exp.amount))
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundColor(AdamTheme.red)

                                Button(action: {
                                    dataManager.deleteExpense(id: exp.id)
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(AdamTheme.red.opacity(0.7))
                                        .padding(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 3)
                            .listRowBackground(AdamTheme.card)
                        }
                    }
                    .listStyle(PlainListStyle())
                    .background(AdamTheme.card)
                }
            }
            .background(AdamTheme.bg)
        }
    }

    private func saveExpense() {
        guard let amount = Int(amountString.trimmingCharacters(in: .whitespacesAndNewlines)),
              amount > 0,
              !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        dataManager.addExpense(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            amount: amount,
            category: selectedCategory,
            date: date,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        name = ""
        amountString = ""
        note = ""
    }
}
