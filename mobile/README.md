# SprachApp (mobile)

**Asıl hedef:** iOS ve Android telefonlar.  
**Web (`chrome` / `web-server`):** sadece geliştirme sırasında hızlı UI denemesi — ürün dağıtımı değil.

## Çalıştırma

```bash
cd mobile
flutter pub get

# Telefon / simülatör (tercih edilen)
flutter devices
flutter run -d <ios|android_device_id>

# Sadece hızlı test (ürün değil)
flutter run -d web-server --web-port=5281 --web-hostname=localhost
```

## i18n

Arayüz dili: `tr` / `en` / `fr` (Profil’den).  
Öğrenme içeriği her zaman Almanca. Ayrıntı: `../docs/I18N.md`.
