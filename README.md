# 🌍 Kelima — Kelime Odaklı Dil Öğrenme Uygulaması

**Kelima**, kullanıcıların yeni bir dili en etkili şekilde öğrenmelerini sağlamak amacıyla geliştirilmiş, **SRS (Spaced Repetition System - Aralıklı Tekrar Sistemi)** ve mikro-öğrenme prensiplerine dayalı modern bir Flutter uygulamasıdır.

---

## 📱 Canlı Demo
- **Web Sürümü:** [https://kelima-7d07f.web.app](https://kelima-7d07f.web.app)
- **GitHub Deposu:** [yakupkaramanyk/Kelima](https://github.com/yakupkaramanyk/Kelima)

---

## ✨ Öne Çıkan Özellikler

- 🧠 **Gelişmiş SRS Algoritması**: Kelimeleri öğrenme durumunuza (*Kolay / Zor / Unuttum*) göre puanlayarak tekrar aralıklarını dinamik olarak hesaplar.
- 🌐 **Hedef Dil İzolasyonu**: Birden fazla hedef dil (Almanca, Felemenkçe vb.) çalışıldığında kelime ilerlemeleri birbirine karışmaz (`{targetLang}_{wordId}` doküman anahtarlaması).
- 🛂 **Özelleştirilmiş Hedefler**: Vize hazırlığı (*Eş/Aile Vizesi Hazırlığı*), seyahat, kariyer veya kişisel gelişim gibi hedeflere uygun akışlar.
- 🎯 **Günlük Alışkanlık & Seri (Streak)**: Günlük XP, öğrenilen kelime sayısı ve kesintisiz çalışma serisi takibi.
- 🔤 **Çoklu Alıştırma Modları**: Fotoğraf eşleştirme, kelime yazma, test ve görsel kartlar.
- 🗣️ **Metin Okuma (TTS)**: Kelimelerin hedef dilde doğru telaffuzunu dinleyebilme desteği.
- 🎨 **Brand v2 Tasarım Sistemi**: Fraunces, Inter ve IBM Plex Mono tipografilerini ve özel seçilmiş renk paletini (*ink, paper, amber, sage, brick*) temel alan arayüz.

---

## 🏗️ Proje Mimarisi & Dizin Yapısı

Proje, sürdürülebilirlik ve test edilebilirlik için **Katmanlı Mimari (Clean/Layered Architecture)** prensiplerine göre yapılandırılmıştır:

```
lib/
├── application/         # 🧠 İş Mantığı & Durum Yönetimi (State Management - Riverpod)
│   ├── auth/            # Kullanıcı oturumu ve tercih sağlayıcıları (user_prefs_provider)
│   ├── onboarding/      # Kayıt ve hedef belirleme state'i
│   ├── quiz/            # Sınav ve test mantığı
│   ├── stats/           # Günlük XP, seri ve istatistik servisi (user_stats_provider)
│   └── word_session/    # Kelime çalışma oturumları ve SRS motoru (word_session_notifier)
│
├── core/                # ⚙️ Çekirdek Ayarlar & Paylaşılan Modüller
│   ├── constants/       # Sabitler (Diller, hedefler, süre seçenekleri)
│   ├── l10n/            # Yerelleştirme (Locale) sağlayıcısı
│   ├── router/          # Sayfa yönlendirme kuralları (GoRouter)
│   └── theme/           # Tasarım sistemi, renk tokenları (AppColors) ve tipografi (AppTypography)
│
├── data/                # 💾 Veri Katmanı (Modeller, Depolar, Veri Kaynakları)
│   ├── datasources/     # Mock kelime havuzu (mock_words.dart)
│   ├── models/          # Veri modelleri (WordModel, UserStatsModel, OnboardingData)
│   └── repositories/    # Firestore bağlantıları (WordProgressRepository, UserRepository)
│
├── l10n/                # 🌐 Çoklu Dil Dosyaları (.arb)
│   ├── app_tr.arb       # Türkçe metin çevirileri
│   └── app_en.arb       # İngilizce metin çevirileri
│
├── ui/                  # 🎨 Kullanıcı Arayüzü (Ekranlar & Widget'lar)
│   ├── screens/         # Sayfalar (home, onboarding, word_session, quiz, progress, settings)
│   └── widgets/         # Yeniden kullanılabilir bileşenler (PrimaryButton, SelectionCard vb.)
│
├── firebase_options.dart # 🔥 Firebase istemci yapılandırması
└── main.dart            # 🚀 Uygulama başlangıç noktası
```

---

## 🛠️ Teknoloji Yığını

| Alan | Teknoloji | Açıklama |
|---|---|---|
| **Frontend / Çatı** | Flutter (Dart) | Çapraz platform UI geliştirme |
| **State Management** | Flutter Riverpod | Reaktif ve güvenli durum yönetimi |
| **Veritabanı & Auth** | Firebase (Firestore & Auth) | Kullanıcı kimlik doğrulama & bulut veritabanı |
| **Navigasyon** | GoRouter | Deklaratif URL ve rota yönetimi |
| **Seslendirme** | Flutter TTS | Cihaz tabanlı metin okuma motoru |
| **Yayınlama** | Firebase Hosting | Hızlı ve güvenli web dağıtımı |

---

## 🚀 Geliştirme & Çalıştırma

### 1. Gereksinimler
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>= 3.3.0)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- Web tarayıcısı (Chrome / Edge) veya bir mobil cihaz simülatörü

### 2. Kurulum
Projeyi klonlayın ve bağımlılıkları yükleyin:
```bash
git clone https://github.com/yakupkaramanyk/Kelima.git
cd Kelima
flutter pub get
```

### 3. Yerelleştirme Dosyalarını Derleme
```bash
flutter gen-l10n
```

### 4. Uygulamayı Başlatma
Geliştirme ortamında çalıştırmak için:
```bash
flutter run -d chrome
```

---

## 📦 Dağıtım (Build & Deploy)

Web sürümünü derlemek ve Firebase Hosting'e göndermek için:
```bash
# 1. Web paketini derleyin
flutter build web

# 2. Firebase Hosting'e yükleyin
firebase deploy --only hosting
```

---

## 🔒 Güvenlik & Firestore Kuralları

Firestore güvenlik kuralları (`firestore.rules`) gereği her kullanıcı yalnızca kendi verilerine ve kendi `wordProgress` alt koleksiyonuna erişebilir.

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /wordProgress/{wordId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

---

## 📄 Lisans
Bu proje kişisel ve ticari kullanım haklarıyla geliştirilmektedir.

