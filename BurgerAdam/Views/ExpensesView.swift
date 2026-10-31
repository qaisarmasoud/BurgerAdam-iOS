import SwiftUI

public struct ExpensesView: View {
    @ObservedObject var dataManager: DataManager
    @State private var name: String = ""
    @State private var amountString: String = ""
    @State private var selectedCategory: String = "مواد غذائية (لحوم، خبز)"
    @State private var date: Date = Date()
    @State private var note: String = ""
    @State private var showSuccessAlert = false

    private var todayExpensesTotal: Int {
        dataManager.totalExpenses(for: Date())
    }

    public var body: some View {
        HStack(spacing: 0) {
            // نموذج إضافة مصروف جديد (الجانب الأيمن)
            VStack(alignment: .leading, spacing: 16) {
                Text("تسجيل مصروف جديد")
                    .font(.system(size: 20, weight: .bold))

                VStack(alignment: .leading, spacing: 6) {
                    Text("اسم المصروف / البند")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                    TextField("مثال: لحم عجل، صمون، طماطة، غاز...", text: $name)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("المبلغ (بالدينار العراقي)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                    TextField("مثال: 25000", text: $amountString)
                        .keyboardType(.numberPad)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("فئة المصروف")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                    Picker("الفئة", selection: $selectedCategory) {
                        ForEach(Expense.categories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("التاريخ")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                    DatePicker("", selection: $date, displayedComponents: .date)
                        .labelsHidden()
                        .padding(4)
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text("ملاحظات إضافية")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.secondary)
                    TextField("تفاصيل إضافية عن الفاتورة أو المورد...", text: $note)
                        .padding(12)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(10)
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
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
            .padding(20)
            .frame(width: 380)
            .background(Color(UIColor.systemBackground))

            Divider()

            // قائمة المصاريف السابقة (الجانب الأيسر)
            VStack(spacing: 0) {
                // شريط إحصائي للمصاريف
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("إجمالي مصاريف اليوم:")
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                        Text(DataManager.formatMoney(todayExpensesTotal))
                            .font(.system(size: 22, weight: .black))
                            .foregroundColor(.red)
                    }
                    Spacer()
                    Text("\(dataManager.expenses.count) مصروف مسجل")
                        .font(.system(size: 13, weight: .bold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                }
                .padding()
                .background(Color(UIColor.systemBackground))

                Divider()

                if dataManager.expenses.isEmpty {
                    VStack(spacing: 12) {
                        Spacer()
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("لا توجد مصاريف مسجلة حتى الآن")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                } else {
                    List {
                        ForEach(dataManager.expenses) { exp in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(exp.name)
                                        .font(.system(size: 16, weight: .bold))
                                    HStack(spacing: 8) {
                                        Text(exp.category)
                                            .font(.system(size: 11, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(Color.blue.opacity(0.12))
                                            .foregroundColor(.blue)
                                            .cornerRadius(6)
                                        Text(exp.date.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 12))
                                            .foregroundColor(.secondary)
                                        if !exp.note.isEmpty {
                                            Text("• \(exp.note)")
                                                .font(.system(size: 12))
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                Spacer()
                                Text(DataManager.formatMoney(exp.amount))
                                    .font(.system(size: 16, weight: .black))
                                    .foregroundColor(.red)

                                Button(action: {
                                    withAnimation {
                                        dataManager.deleteExpense(id: exp.id)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.7))
                                        .padding(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .background(Color(UIColor.secondarySystemBackground))
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
