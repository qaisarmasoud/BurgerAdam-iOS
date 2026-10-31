# 🍔 بركر ادم (Burger Adam POS) - تطبيق كاشير أصلي لجهاز iPad Air 2

تطبيق iOS أصلي بالكامل مبني بلغة **Swift و SwiftUI** الرسمية من Apple، ومصمم خصيصاً ليعمل بأعلى كفاءة وسرعة على أجهزة **iPad Air 2** (يدعم iOS 15 وأحدث) بدون إنترنت وبشكل دائم.

---

## 🚀 كيفية بناء وتحميل ملف الـ IPA في دقيقتين (عبر GitHub Actions مجاناً):

بما أن نظام آبل يفرض وجود نظام Mac لتجميع ملفات `.ipa`، قمنا بإنشاء مسار أوتوماتيكي كامل داخل مجلد `.github/workflows/build-ipa.yml` يستخدم خوادم macOS السحابية المجانية لـ GitHub لبناء الـ IPA لك:

1. افتح حسابك على [GitHub](https://github.com) وأنشئ مستودعاً جديداً (New Repository) باسم `BurgerAdam-iOS`.
2. في جهاز الكمبيوتر، افتح موجه الأوامر (PowerShell) داخل مجلد المشروع ونفذ:
   ```powershell
   cd "C:\Users\baraa\Desktop\BurgerAdam-iOS"
   git remote add origin https://github.com/اسم_حسابك/BurgerAdam-iOS.git
   git branch -M main
   git push -u origin main
   ```
3. بمجرد رفع الكود، اذهب إلى تبويب **Actions** في صفحة المستودع على GitHub.
4. ستجد عملية البناء **"Compile Native iOS IPA"** قد بدأت فوراً على خادم macOS حقيقي.
5. بعد دقيقتين، ادخل على العملية وستجد ملف **`BurgerAdam-iOS-IPA.zip`** جاهزاً في قسم **Artifacts** في الأسفل للتحميل المباشر.
6. فك الضغط لتجد ملف: `BurgerAdam.ipa`.

---

## 📲 كيفية تثبيت ملف الـ IPA على iPad Air 2:

### 1. التثبيت عبر TrollStore (أفضل طريقة على الإطلاق لـ iPad Air 2):
بما أن iPad Air 2 يعمل بنظام **iOS 15**، فهو يدعم **TrollStore**:
* أرسل ملف `BurgerAdam.ipa` إلى الآيباد (عبر AirDrop أو Telegram أو Google Drive أو كابل).
* اضغط على الملف واختر **مشاركة (Share) -> فتح في TrollStore**.
* سيتم تثبيت التطبيق بشكل **دائم 100% بدون أي حاجة لتجديد الشهادة كل 7 أيام**!

### 2. التثبيت عبر Sideloadly (عبر الكمبيوتر):
1. حمل برنامج [Sideloadly](https://sideloadly.io) على جهاز Windows.
2. وصّل الآيباد بالكمبيوتر بواسطة كابل Lightning الأصلي.
3. افتح Sideloadly، واسحب ملف `BurgerAdam.ipa` وأفلته داخل البرنامج.
4. أدخل بريدك الإلكتروني لحساب Apple ID المجاني الخاص بك، ثم اضغط **Start**.
5. خلال 30 ثانية سينزل التطبيق على شاشة الآيباد الرئيسية.
6. على الآيباد اذهب إلى: **الإعدادات -> عام -> إدارة الجهاز والـ VPN** واضغط **وثوق (Trust)**.

---

## ⚡ خيار التثبيت الفوري الإضافي (بدون كمبيوتر):
موجود على سطح المكتب مجلد باسم:
`BurgerAdam.swiftpm`
يمكنك نسخه إلى الآيباد وفتحه مباشرة في تطبيق **Swift Playgrounds** من Apple والضغط على "تثبيت التطبيق على الشاشة الرئيسية".
