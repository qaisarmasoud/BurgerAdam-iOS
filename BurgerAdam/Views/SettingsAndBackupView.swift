import SwiftUI
import UniformTypeIdentifiers

public struct SettingsAndBackupView: View {
    @ObservedObject var dataManager: DataManager
    
    // لإضافة صنف جديد
    @State private var newItemName = ""
    @State private var newItemPrice = ""
    @State private var newItemCategory = "بركر لحم"
    @State private var newItemEmoji = "🍔"
    @State private var showingAddAlert = false
    @State private var showingShareSheet = false
    @State private var backupFileURL: URL?
    @State private var showingFilePicker = false
    @State private var importStatusMessage = ""

    private let emojis = ["🍔", "🍗", "🧀", "🍟", "🥤", "🧃", "💧", "🥗", "🍰", "☕️", "🌭", "🍕"]

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // قسم إدارة المنيو والأصناف
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Text("إدارة قائمة الطعام (المنيو)")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Button(action: { showingAddAlert = true }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("إضافة صنف جديد")
                            }
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                    }

                    // قائمة الأصناف الحالية
                    VStack(spacing: 8) {
                        ForEach(dataManager.menuItems) { item in
                            HStack {
                                Text(item.emoji)
                                    .font(.system(size: 24))
                                    .frame(width: 36, height: 36)
                                    .background(Color(UIColor.secondarySystemBackground))
                                    .cornerRadius(8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name)
                                        .font(.system(size: 15, weight: .bold))
                                    Text(item.category)
                                        .font(.system(size: 12))
                                        .foregroundColor(.secondary)
                                }

                                Spacer()

                                Text(DataManager.formatMoney(item.price))
                                    .font(.system(size: 15, weight: .bold))
                                    .foregroundColor(.green)

                                Button(action: {
                                    withAnimation {
                                        dataManager.deleteMenuItem(id: item.id)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red.opacity(0.8))
                                        .padding(8)
                                }
                            }
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(10)
                        }
                    }

                    Button("استعادة قائمة الطعام الافتراضية لبركر ادم") {
                        dataManager.resetMenuToDefaults()
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.orange)
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)

                // قسم النسخ الاحتياطي والأمان
                VStack(alignment: .leading, spacing: 14) {
                    Text("النسخ الاحتياطي ونقل البيانات")
                        .font(.system(size: 20, weight: .bold))

                    Text("بياناتك تُحفظ تلقائياً وبأمان في ذاكرة الآيباد بدون إنترنت. يمكنك تصدير نسخة احتياطية لحفظها في تطبيق «الملفات» أو نقلها لجهاز آخر.")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)

                    HStack(spacing: 12) {
                        Button(action: exportBackup) {
                            HStack {
                                Image(systemName: "square.and.arrow.up.fill")
                                Text("تصدير نسخة احتياطية (JSON)")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }

                        Button(action: { showingFilePicker = true }) {
                            HStack {
                                Image(systemName: "square.and.arrow.down.fill")
                                Text("استيراد نسخة احتياطية")
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color(UIColor.secondarySystemBackground))
                            .foregroundColor(.primary)
                            .cornerRadius(12)
                        }
                    }

                    if !importStatusMessage.isEmpty {
                        Text(importStatusMessage)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.green)
                            .padding(.top, 4)
                    }

                    Divider()

                    // إحصاءات التخزين
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("الطلبات المسجلة: \(dataManager.orders.count)")
                            Text("المصاريف المسجلة: \(dataManager.expenses.count)")
                            Text("أصناف المنيو: \(dataManager.menuItems.count)")
                        }
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                .padding()
                .background(Color(UIColor.systemBackground))
                .cornerRadius(16)
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        // نافذة إضافة صنف جديد
        .sheet(isPresented: $showingAddAlert) {
            NavigationView {
                Form {
                    Section(header: Text("معلومات الصنف")) {
                        TextField("اسم الصنف (مثال: بركر تركي)", text: $newItemName)
                        TextField("السعر بالدينار (مثال: 4000)", text: $newItemPrice)
                            .keyboardType(.numberPad)
                        TextField("الفئة (مثال: بركر لحم، مشروبات)", text: $newItemCategory)
                    }

                    Section(header: Text("اختر رمز تعبيري (Emoji)")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(emojis, id: \.self) { em in
                                    Button(action: { newItemEmoji = em }) {
                                        Text(em)
                                            .font(.system(size: 32))
                                            .padding(6)
                                            .background(newItemEmoji == em ? Color.orange.opacity(0.2) : Color.clear)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
                .navigationTitle("إضافة صنف للمنيو")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("إلغاء") { showingAddAlert = false }
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("حفظ") {
                            if let price = Int(newItemPrice), !newItemName.isEmpty {
                                dataManager.addMenuItem(name: newItemName, price: price, category: newItemCategory, emoji: newItemEmoji)
                                newItemName = ""
                                newItemPrice = ""
                                showingAddAlert = false
                            }
                        }
                        .font(.system(size: 15, weight: .bold))
                    }
                }
            }
            .environment(\.layoutDirection, .rightToLeft)
        }
        .sheet(isPresented: $showingShareSheet) {
            if let url = backupFileURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $showingFilePicker) {
            DocumentPicker { url in
                if dataManager.importBackup(from: url) {
                    importStatusMessage = "تم استرجاع النسخة الاحتياطية بنجاح! ✅"
                } else {
                    importStatusMessage = "فشل في استيراد الملف. تأكد من صحة الملف ❌"
                }
            }
        }
    }

    private func exportBackup() {
        if let url = dataManager.exportBackupURL() {
            backupFileURL = url
            showingShareSheet = true
        }
    }
}

// عارض مشاركة الملفات (UIActivityViewController)
struct ShareSheet: UIViewControllerRepresentable {
    var activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// منتقي الملفات للاستيراد
struct DocumentPicker: UIViewControllerRepresentable {
    var onPick: (URL) -> Void

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json])
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        var parent: DocumentPicker
        init(_ parent: DocumentPicker) { self.parent = parent }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            _ = url.startAccessingSecurityScopedResource()
            parent.onPick(url)
            url.stopAccessingSecurityScopedResource()
        }
    }
}
