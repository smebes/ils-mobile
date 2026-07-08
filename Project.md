Evet. Aşağıdaki planla projeyi başlatabilirsin. Ben bunu “dijital kitap + interaktif dil pratiği platformu” olarak kurguluyorum. Yani sadece PDF gösteren bir uygulama değil; PDF’den içerik çıkaran, görselleri/sesleri yöneten, egzersizleri uygulama içinde çözdüren, öğretmen ve öğrenci takibini yapan bir sistem.

⸻

Proje Adı

EduLanguage Interactive Reader

Geçici Türkçe adı:

Dil Okulu İnteraktif Kitap ve Pratik Uygulaması

⸻

1. Projenin ana hedefi

Firma mevcut dijital kitaplarını ve materyallerini uygulama içine taşıtmak istiyor.

Uygulamada öğrenci:

Kitabı görecek
Sayfaları açacak
Görselleri ve sesleri kullanacak
Egzersizleri çözecek
Cevap kontrolü alacak
İlerlemesini görecek

Öğretmen:

Sınıf oluşturacak
Öğrenci ekleyecek
Ödev verecek
Kim ne yaptı görecek
Hangi öğrencinin nerede zorlandığını takip edecek

Admin:

Kitap yükleyecek
PDF import edecek
Sayfaları görsele çevirecek
Görsel/ses ekleyecek
Egzersizleri tanımlayacak
Cevap anahtarlarını girecek
İçerik yayınlayacak

⸻

2. Mevcut sistemden anladığımız yapı

Senin bulduğun reader sistemi şu mantıkla çalışıyor:

viewer.html
↓
PDF dosyasını çağırıyor
↓
PDF byte-range / chunk ile veya direkt indirilebiliyor
↓
Sayfa üstü canvas verilerini ayrı endpoint’ten alıyor
↓
Canvas verileri Fabric.js objelerine benziyor

Bizim tespit ettiğimiz iki kaynak var:

1. PDF dosyası:
   9783191810801.pdf
2. Canvas / annotation datası:
   9783191810801_canvas_14_

PDF’i direkt indirmeyi başardın:

9783191810801.pdf → yaklaşık 30.5 MB

Bu çok iyi. Çünkü artık viewer’a bağlı kalmadan PDF’i işleyebiliriz.

⸻

3. Ürün yaklaşımı

Bu projeyi 3 katmanlı yapacağız.

Katman 1 — Dijital Kitap Katmanı

PDF sayfaları uygulamada gösterilecek.

Öğrenci:

Kitap seçer
Ünite seçer
Sayfayı açar
Zoom yapar
Sayfalar arasında gezer

Backend tarafında PDF’den sayfa görselleri üretilecek:

9783191810801.pdf
↓
page-001.png
page-002.png
page-003.png
...

Bu görseller storage’a kaydedilecek.

⸻

Katman 2 — İçerik / Medya Katmanı

Kitaptaki fotoğraflar, görseller, sesler, sayfa parçaları ayrı asset olarak tutulacak.

Örnek:

assets/books/9783191810801/pages/page-001.png
assets/books/9783191810801/images/page-001-cafe.png
assets/books/9783191810801/images/page-001-portrait.png
assets/books/9783191810801/audio/track-001.mp3

Admin panelden:

Sayfadan görsel kırpılacak
Ses dosyası yüklenecek
Egzersize bağlanacak

⸻

Katman 3 — İnteraktif Egzersiz Katmanı

Kitaptaki pratikler uygulama egzersizlerine dönüştürülecek.

Desteklenecek ilk egzersiz tipleri:

1. Multiple choice
2. Fill in the blanks
3. Matching
4. Ordering / sentence sorting
5. Listening question
6. True / false
7. Dialogue completion
8. Open text answer
9. Speaking answer — ikinci faz
10. Writing AI feedback — ikinci faz

⸻

4. MVP kapsamı

İlk sürümde çok büyütmeyelim. MVP şu olmalı:

1 kitap
1 seviye
2–3 ünite
30–50 egzersiz
PDF sayfa görüntüleme
Görsel asset yönetimi
Ses asset yönetimi
Öğrenci egzersiz çözme
Basit skor sistemi
Admin içerik paneli
Öğretmen sınıf/ödev paneli

İlk fazda AI şart değil. Önce sistemin omurgasını kurmak daha doğru.

⸻

5. Kullanıcı rolleri

5.1 Admin

Yetkileri:

Okul / organizasyon yönetimi
Kitap ekleme
PDF yükleme
Sayfa import etme
Sayfa görsellerini üretme
Görsel kırpma
Ses yükleme
Ünite / ders / egzersiz oluşturma
Cevap anahtarı girme
İçerik yayınlama
Kullanıcı yönetimi

5.2 Teacher

Yetkileri:

Sınıf oluşturma
Öğrenci ekleme
Ödev atama
Öğrenci ilerleme takibi
Egzersiz sonuçlarını görme
Yanlış cevapları inceleme

5.3 Student

Yetkileri:

Kendi kitaplarını görme
Dersleri açma
Egzersiz çözme
Ses dinleme
Yanlışlarını görme
İlerleme durumunu takip etme

⸻

6. Ana modüller

6.1 Auth modülü

Özellikler:

Email + password login
Rol bazlı yetkilendirme
Organization bazlı erişim
JWT auth
Refresh token
Password reset

Roller:

admin
teacher
student

⸻

6.2 Organization / School modülü

Sistem ileride başka okullara da açılabilir. Bu yüzden baştan organization mantığı olmalı.

Organization = okul / firma / müşteri

Her kitap, kullanıcı, sınıf bir organization’a bağlı olacak.

⸻

6.3 Book modülü

Kitap hiyerarşisi:

Book
  Unit
    Lesson
      Exercise

Örnek:

Book: Deutsch A1
Unit 1: Hallo!
Lesson 1: Begrüßung
Exercise 1: Guten Morgen / Guten Abend

⸻

6.4 PDF Import modülü

Admin PDF yükler.

Sistem:

PDF’i kaydeder
Sayfa sayısını bulur
Her sayfayı PNG’ye çevirir
page_assets oluşturur

Terminalde bunun karşılığı:

pdftoppm -png -r 200 9783191810801.pdf pages/page

Backend’de otomatik yapılacak.

⸻

6.5 Page Viewer modülü

Öğrenci kitap sayfasını görecek.

Özellikler:

Sayfa listesi
Önceki / sonraki sayfa
Zoom
Full screen
Sayfa üstü hotspot
Sayfaya bağlı egzersiz listesi
Ses oynatma

⸻

6.6 Media Asset modülü

Medya tipleri:

page_image
image
audio
video
document

Admin şunları yapacak:

Görsel yükle
Ses yükle
Sayfadan görsel kırp
Asset’i egzersize bağla

⸻

6.7 Canvas / Annotation Import modülü

Senin bulduğun endpoint’ten gelen Fabric.js datası gibi veriler burada işlenecek.

Ham veri örneği:

{
  "type": "Textbox",
  "text": "Tschau",
  "left": 442.16,
  "top": 153.20
}

Biz bunu normalize edeceğiz:

{
  "type": "text",
  "text": "Tschau",
  "x": 442.16,
  "y": 153.20,
  "source": "fabric_canvas"
}

Bu veri şu amaçlarla kullanılabilir:

Sayfa üstü notları göstermek
Tıklanabilir kelime alanları oluşturmak
Highlight verilerini saklamak
Egzersiz adayları çıkarmak

⸻

6.8 Exercise Engine modülü

Her egzersiz tipi için ortak motor olacak.

Ortak alanlar:

instruction
content_json
answer_json
validation_json
feedback_json
score

Egzersiz tipleri JSON ile esnek tutulacak.

⸻

7. Egzersiz tipleri ve JSON örnekleri

7.1 Multiple Choice

{
  "question": "Was sagt man am Morgen?",
  "options": [
    { "id": "a", "text": "Guten Morgen" },
    { "id": "b", "text": "Gute Nacht" },
    { "id": "c", "text": "Tschau" }
  ]
}

Cevap:

{
  "correctOptionIds": ["a"]
}

⸻

7.2 Fill Blank

{
  "text": "Guten ___!",
  "blanks": [
    {
      "id": "blank_1",
      "placeholder": "..."
    }
  ]
}

Cevap:

{
  "blank_1": ["Morgen"]
}

Validation:

{
  "caseSensitive": false,
  "trimSpaces": true,
  "ignorePunctuation": true
}

⸻

7.3 Matching

{
  "leftItems": [
    { "id": "l1", "text": "Guten Morgen" },
    { "id": "l2", "text": "Tschau" }
  ],
  "rightItems": [
    { "id": "r1", "text": "Good morning" },
    { "id": "r2", "text": "Bye" }
  ]
}

Cevap:

{
  "pairs": [
    { "left": "l1", "right": "r1" },
    { "left": "l2", "right": "r2" }
  ]
}

⸻

7.4 Ordering

{
  "items": [
    { "id": "i1", "text": "Ich" },
    { "id": "i2", "text": "heiße" },
    { "id": "i3", "text": "Murat" }
  ]
}

Cevap:

{
  "correctOrder": ["i1", "i2", "i3"]
}

⸻

7.5 Listening Question

{
  "audioAssetId": "audio_001",
  "question": "Was hörst du?",
  "options": [
    { "id": "a", "text": "Guten Morgen" },
    { "id": "b", "text": "Gute Nacht" }
  ]
}

Cevap:

{
  "correctOptionIds": ["a"]
}

⸻

7.6 Dialogue Completion

{
  "dialogue": [
    {
      "speaker": "A",
      "text": "Hallo!"
    },
    {
      "speaker": "B",
      "blankId": "b1"
    }
  ],
  "options": [
    { "id": "o1", "text": "Hallo!" },
    { "id": "o2", "text": "Gute Nacht!" }
  ]
}

Cevap:

{
  "b1": "o1"
}

⸻

8. Veritabanı şeması

Aşağıdaki şema ile başlayabiliriz.

8.1 Organizations

CREATE TABLE organizations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);

⸻

8.2 Users / Roles

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  password_hash TEXT,
  status TEXT NOT NULL DEFAULT 'active',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP,
  UNIQUE (organization_id, email)
);
CREATE TABLE roles (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL
);
CREATE TABLE user_roles (
  user_id UUID REFERENCES users(id),
  role_id UUID REFERENCES roles(id),
  PRIMARY KEY (user_id, role_id)
);

⸻

8.3 Books / Units / Lessons

CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),
  title TEXT NOT NULL,
  language TEXT,
  target_language TEXT,
  support_language TEXT,
  level TEXT,
  isbn TEXT,
  publisher_ref TEXT,
  status TEXT NOT NULL DEFAULT 'draft',
  content_source_status TEXT DEFAULT 'licensed_final',
  license_status TEXT DEFAULT 'licensed_final',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);
CREATE TABLE units (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id),
  unit_no TEXT,
  title TEXT NOT NULL,
  description TEXT,
  order_index INT DEFAULT 0,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);
CREATE TABLE lessons (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  unit_id UUID REFERENCES units(id),
  lesson_no TEXT,
  title TEXT NOT NULL,
  description TEXT,
  order_index INT DEFAULT 0,
  status TEXT DEFAULT 'draft',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);

⸻

8.4 PDF / Pages

CREATE TABLE book_files (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id),
  file_type TEXT NOT NULL, -- pdf, source, teacher_guide
  file_url TEXT NOT NULL,
  file_name TEXT,
  mime_type TEXT,
  file_size BIGINT,
  uploaded_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT now()
);
CREATE TABLE book_pages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id),
  page_no INT NOT NULL,
  page_image_url TEXT,
  width INT,
  height INT,
  status TEXT DEFAULT 'ready',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  UNIQUE (book_id, page_no)
);

⸻

8.5 Media Assets

CREATE TABLE media_assets (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),
  book_id UUID REFERENCES books(id),
  type TEXT NOT NULL, -- image, audio, video, page_image
  file_url TEXT NOT NULL,
  file_name TEXT,
  mime_type TEXT,
  duration_seconds NUMERIC,
  source_page INT,
  source_ref TEXT,
  license_status TEXT DEFAULT 'licensed_final',
  content_source_status TEXT DEFAULT 'licensed_final',
  uploaded_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);

⸻

8.6 Sayfa üstü objeler / Canvas

CREATE TABLE page_canvas_layers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id),
  page_no INT NOT NULL,
  raw_fabric_json JSONB,
  normalized_json JSONB,
  source TEXT,
  imported_at TIMESTAMP DEFAULT now(),
  UNIQUE (book_id, page_no, source)
);
CREATE TABLE page_objects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  book_id UUID REFERENCES books(id),
  page_no INT NOT NULL,
  object_type TEXT NOT NULL, -- text, rect, circle, path, highlight, hotspot
  text TEXT,
  x NUMERIC,
  y NUMERIC,
  width NUMERIC,
  height NUMERIC,
  style_json JSONB,
  raw_json JSONB,
  created_at TIMESTAMP DEFAULT now()
);

⸻

8.7 Exercise Types / Exercises

CREATE TABLE exercise_types (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  schema_json JSONB,
  status TEXT DEFAULT 'active'
);
CREATE TABLE exercises (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  lesson_id UUID REFERENCES lessons(id),
  book_id UUID REFERENCES books(id),
  page_no INT,
  exercise_type_id UUID REFERENCES exercise_types(id),
  page_ref TEXT,
  exercise_no TEXT,
  title TEXT,
  instruction_text TEXT,
  content_json JSONB NOT NULL,
  order_index INT DEFAULT 0,
  status TEXT DEFAULT 'draft',
  content_source_status TEXT DEFAULT 'licensed_final',
  license_status TEXT DEFAULT 'licensed_final',
  source_ref TEXT,
  created_by UUID REFERENCES users(id),
  updated_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);

⸻

8.8 Answers / Feedback

CREATE TABLE answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID REFERENCES exercises(id),
  answer_json JSONB NOT NULL,
  validation_json JSONB,
  is_primary BOOLEAN DEFAULT true,
  order_index INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);
CREATE TABLE feedback (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID REFERENCES exercises(id),
  on_correct_text TEXT,
  on_wrong_text TEXT,
  explanation_json JSONB,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

⸻

8.9 Exercise Media

CREATE TABLE exercise_media (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  exercise_id UUID REFERENCES exercises(id),
  media_asset_id UUID REFERENCES media_assets(id),
  start_time NUMERIC,
  end_time NUMERIC,
  role TEXT, -- listening_source, image, background, prompt_image
  order_index INT DEFAULT 0
);

⸻

8.10 Classes / Students

CREATE TABLE classes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID REFERENCES organizations(id),
  name TEXT NOT NULL,
  teacher_id UUID REFERENCES users(id),
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);
CREATE TABLE class_students (
  class_id UUID REFERENCES classes(id),
  student_id UUID REFERENCES users(id),
  status TEXT DEFAULT 'active',
  joined_at TIMESTAMP DEFAULT now(),
  PRIMARY KEY (class_id, student_id)
);

⸻

8.11 Assignments

CREATE TABLE assignments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id UUID REFERENCES classes(id),
  assigned_by UUID REFERENCES users(id),
  target_type TEXT NOT NULL, -- book, unit, lesson, exercise
  target_id UUID NOT NULL,
  title TEXT,
  description TEXT,
  due_date TIMESTAMP,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now(),
  deleted_at TIMESTAMP
);

⸻

8.12 Attempts / Progress

CREATE TABLE attempt_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id UUID REFERENCES users(id),
  assignment_id UUID REFERENCES assignments(id),
  lesson_id UUID REFERENCES lessons(id),
  started_at TIMESTAMP DEFAULT now(),
  completed_at TIMESTAMP,
  total_score NUMERIC,
  status TEXT DEFAULT 'started'
);
CREATE TABLE attempt_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id UUID REFERENCES attempt_sessions(id),
  exercise_id UUID REFERENCES exercises(id),
  given_answer_json JSONB,
  is_correct BOOLEAN,
  score NUMERIC,
  checked_by TEXT DEFAULT 'system', -- system, teacher, ai
  feedback_json JSONB,
  attempted_at TIMESTAMP DEFAULT now()
);
CREATE TABLE progress_summary (
  student_id UUID REFERENCES users(id),
  lesson_id UUID REFERENCES lessons(id),
  completion_pct NUMERIC DEFAULT 0,
  correct_count INT DEFAULT 0,
  wrong_count INT DEFAULT 0,
  last_activity_at TIMESTAMP,
  PRIMARY KEY (student_id, lesson_id)
);

⸻

9. Teknoloji seçimi

Backend

NestJS
PostgreSQL
Prisma veya TypeORM
JWT Auth
BullMQ / Redis queue
S3 veya Cloudflare R2 storage

Ben burada NestJS + PostgreSQL + Prisma öneririm.

⸻

Frontend Web

Next.js
React
TailwindCSS
shadcn/ui
PDF/page viewer component
Canvas crop tool

⸻

Mobile

İkinci fazda:

Flutter

Senin geçmişin Flutter olduğu için mobilde Flutter mantıklı. Ama MVP önce web olmalı.

⸻

Storage

Cloudflare R2
veya
AWS S3

Geliştirme ortamında:

local storage

⸻

PDF processing

Sunucuda kullanılacak araçlar:

poppler-utils
pdftoppm
pdfimages
imagemagick

Node tarafında worker:

PDF import job
Page image generation job
Image crop job

⸻

10. Backend servisleri

AuthService

login
register
refreshToken
resetPassword
getCurrentUser

OrganizationService

createOrganization
updateOrganization
getOrganization

BookService

createBook
uploadPdf
listBooks
getBookDetail
publishBook

PdfImportService

savePdf
getPageCount
generatePageImages
storePageImages
createBookPages

MediaService

uploadAsset
cropFromPage
listAssets
attachAssetToExercise

ExerciseService

createExercise
updateExercise
publishExercise
validateAnswer
getExerciseForStudent

AssignmentService

createAssignment
listClassAssignments
getStudentAssignments

AttemptService

startSession
submitAnswer
calculateScore
completeSession
updateProgress

CanvasImportService

importRawFabricJson
normalizeFabricObjects
createPageObjects

⸻

11. API endpoint planı

Auth

POST /auth/login
POST /auth/register
POST /auth/refresh
GET  /auth/me

Books

GET    /books
POST   /books
GET    /books/:id
PATCH  /books/:id
POST   /books/:id/upload-pdf
POST   /books/:id/import-pages
GET    /books/:id/pages
GET    /books/:id/pages/:pageNo

Media

POST   /media/upload
GET    /media
GET    /media/:id
POST   /media/crop-from-page
DELETE /media/:id

Crop request:

{
  "bookId": "uuid",
  "pageNo": 1,
  "x": 120,
  "y": 300,
  "width": 500,
  "height": 320,
  "name": "page-001-cafe"
}

Canvas

POST /books/:id/pages/:pageNo/canvas/import
GET  /books/:id/pages/:pageNo/objects

Exercises

GET    /exercises
POST   /exercises
GET    /exercises/:id
PATCH  /exercises/:id
DELETE /exercises/:id
POST   /exercises/:id/publish
POST   /exercises/:id/check-answer

Classes

GET   /classes
POST  /classes
GET   /classes/:id
POST  /classes/:id/students
GET   /classes/:id/students

Assignments

POST /assignments
GET  /assignments/class/:classId
GET  /assignments/student/me

Attempts

POST /attempt-sessions
POST /attempt-sessions/:id/answers
POST /attempt-sessions/:id/complete
GET  /students/:studentId/progress

⸻

12. Frontend ekranları

12.1 Admin panel

Dashboard

Toplam kitap
Toplam öğrenci
Toplam öğretmen
Yayınlanmış egzersiz sayısı
Son import edilen kitaplar

Books

Kitap listesi
Kitap oluştur
PDF yükle
Sayfaları import et
Kitap yayınla

Page Manager

Sayfa listesi
Sayfa görseli görüntüleme
Sayfadan görsel kırpma
Sayfa üstü canvas objeleri
Hotspot ekleme
Sayfaya egzersiz bağlama

Media Library

Görseller
Sesler
Sayfa görselleri
Filtre: book/page/type

Exercise Builder

Egzersiz tipi seç
Instruction yaz
Content JSON’u form üzerinden oluştur
Cevap anahtarı gir
Feedback gir
Medya bağla
Önizleme
Yayınla

Users

Admin / teacher / student listesi
Kullanıcı oluştur
Rol ata

⸻

12.2 Teacher panel

Dashboard

Sınıflarım
Aktif ödevler
Son öğrenci aktiviteleri

Class Detail

Öğrenciler
Atanan dersler
Tamamlama oranı
Yanlış cevap analizi

Assignment Create

Sınıf seç
Kitap / ünite / ders / egzersiz seç
Teslim tarihi belirle
Yayınla

⸻

12.3 Student uygulaması

Home

Kitaplarım
Devam ettiğim dersler
Aktif ödevler
İlerleme yüzdesi

Book Reader

Sayfa görüntüleme
Önceki / sonraki sayfa
Zoom
Sayfadaki egzersizler
Ses oynatıcı

Lesson Detail

Ders açıklaması
Egzersiz listesi
Tamamlanan / tamamlanmayan durum

Exercise Screen

Instruction
Question
Options / input / drag-drop
Check answer
Feedback
Next exercise

Progress

Tamamlanan dersler
Doğru / yanlış sayısı
Yanlışlarım
Tekrar et

⸻

13. PDF ve görsel import süreci

13.1 Manuel test

Sen zaten PDF’i indirdin. İlk test şu:

file 9783191810801.pdf
head -c 5 9783191810801.pdf
open 9783191810801.pdf

Sonra:

brew install poppler
mkdir -p book-pages
pdftoppm -png -r 200 9783191810801.pdf book-pages/page

Bu, sayfa görsellerini verir.

⸻

13.2 Backend otomasyon

Backend’de import flow:

Admin PDF yükler
↓
PDF storage’a kaydedilir
↓
Queue job başlar
↓
pdftoppm çalışır
↓
Her page PNG storage’a yüklenir
↓
book_pages kayıtları açılır

⸻

13.3 Görsel kırpma

Admin panelde:

Sayfa açılır
Mouse ile alan seçilir
Crop butonuna basılır
Backend crop yapar
Yeni image asset oluşturur

Backend crop mantığı:

Input:
page_image_url
x
y
width
height
Output:
cropped image file
media_assets kaydı

⸻

14. Canvas import süreci

Senin gördüğün endpoint’ten gelen JSON şu tip objeler içeriyor:

Textbox
Rect
Circle
Path

Bunları şu normalize tiplere çeviririz:

Textbox → text
Rect    → rect / hotspot candidate
Circle  → marker
Path    → drawing / highlight

Normalize örnek:

{
  "type": "text",
  "text": "Tschau",
  "x": 442.16,
  "y": 153.2,
  "fontSize": 24,
  "color": "rgb(0, 0, 0)"
}

Path/highlight örnek:

{
  "type": "highlight",
  "stroke": "rgba(255, 255, 0, 0.3)",
  "strokeWidth": 19.1,
  "path": []
}

⸻

15. İçerik import şablonu

Firmadan şu formatta Excel/CSV isteyebiliriz.

Books

book_code
title
isbn
level
target_language
support_language
publisher_ref

Units

book_code
unit_no
title
order_index

Lessons

book_code
unit_no
lesson_no
title
order_index

Exercises

book_code
unit_no
lesson_no
page_no
exercise_no
exercise_type
instruction
question_text
options_json
answer_json
feedback_correct
feedback_wrong
media_refs

Media

book_code
page_no
media_type
file_name
source_ref
role

⸻

16. Klasör yapısı

Monorepo öneririm.

edu-language-platform/
  apps/
    api/
      src/
        modules/
          auth/
          organizations/
          users/
          books/
          pdf-import/
          media/
          canvas-import/
          exercises/
          classes/
          assignments/
          attempts/
    web/
      app/
        admin/
        teacher/
        student/
      components/
      lib/
  packages/
    db/
      prisma/
    shared/
      types/
      schemas/
  storage/
    local/
      books/
  docker-compose.yml
  README.md

⸻

17. Backend klasör yapısı

apps/api/src/modules/
  auth/
    auth.controller.ts
    auth.service.ts
    jwt.strategy.ts
  books/
    books.controller.ts
    books.service.ts
  pdf-import/
    pdf-import.service.ts
    pdf-import.processor.ts
  media/
    media.controller.ts
    media.service.ts
  canvas-import/
    canvas-import.controller.ts
    canvas-import.service.ts
    fabric-normalizer.ts
  exercises/
    exercises.controller.ts
    exercises.service.ts
    validators/
      multiple-choice.validator.ts
      fill-blank.validator.ts
      matching.validator.ts
  attempts/
    attempts.controller.ts
    attempts.service.ts

⸻

18. Answer validation mantığı

Her egzersiz tipi için ayrı validator.

Ortak interface:

interface ExerciseValidator {
  validate(
    content: unknown,
    answer: unknown,
    givenAnswer: unknown,
    validationRules: unknown
  ): ValidationResult;
}
interface ValidationResult {
  isCorrect: boolean;
  score: number;
  feedback?: string;
  details?: unknown;
}

Örnek fill blank:

function normalizeText(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[.,!?]/g, '');
}

⸻

19. MVP sprint planı

Sprint 0 — Hazırlık

Süre: 2–3 gün

Repo oluştur
Docker compose hazırla
PostgreSQL kur
NestJS api oluştur
Next.js web oluştur
Auth temelini kur
Prisma schema başlat

Çıktı:

Çalışan boş monorepo
API health endpoint
DB bağlantısı
Login altyapısı başlangıcı

⸻

Sprint 1 — Core schema + auth

Süre: 1 hafta

Organizations
Users
Roles
Auth
RBAC middleware
Admin login
Seed data

Çıktı:

Admin sisteme girebilir
Rol bazlı erişim çalışır

⸻

Sprint 2 — Book + PDF import

Süre: 1 hafta

Book CRUD
PDF upload
PDF storage
Page generation job
Book pages table
Admin book pages ekranı

Çıktı:

PDF yüklenir
Sayfalar PNG’ye çevrilir
Admin sayfaları görür

⸻

Sprint 3 — Media crop tool

Süre: 1 hafta

Page viewer admin ekranı
Mouse ile crop seçimi
Backend crop endpoint
media_assets kaydı
Media library

Çıktı:

Admin PDF sayfasından görsel kırpar
Görsel asset olarak kaydedilir

⸻

Sprint 4 — Exercise builder

Süre: 1–2 hafta

Exercise types
Exercise CRUD
Multiple choice builder
Fill blank builder
Matching builder
Listening builder
Answer JSON
Feedback
Preview

Çıktı:

Admin egzersiz oluşturur
Önizleyebilir
Yayınlayabilir

⸻

Sprint 5 — Student exercise flow

Süre: 1 hafta

Student home
Book reader
Lesson detail
Exercise solve screen
Answer check
Feedback
Attempt responses
Progress update

Çıktı:

Öğrenci egzersiz çözebilir
Cevap kontrolü alır
İlerlemesi kaydedilir

⸻

Sprint 6 — Teacher panel

Süre: 1 hafta

Classes
Class students
Assignments
Progress report
Student result detail

Çıktı:

Öğretmen sınıf oluşturur
Ödev verir
Sonuçları görür

⸻

Sprint 7 — Canvas import

Süre: 1 hafta

Fabric JSON import endpoint
Normalize service
Page objects table
Admin page overlay viewer
Textbox/highlight gösterimi

Çıktı:

EduReader canvas datası içeri alınır
Sayfa üstünde gösterilir

⸻

20. İlk milestone

İlk demo hedefi:

1 PDF kitap yüklendi
İlk 10 sayfa PNG’ye çevrildi
2 görsel sayfadan kırpıldı
10 egzersiz oluşturuldu
1 öğrenci login oldu
Egzersizleri çözdü
Öğretmen sonucu gördü

Bu demo firmaya gösterilebilir.

⸻

21. Firmadan istenecek materyaller

Firmaya net şu liste gönderilmeli:

1. Tam PDF dosyaları
2. Orijinal görseller JPG/PNG
3. Ses dosyaları MP3/WAV
4. Cevap anahtarları
5. Öğretmen kitabı / teacher guide
6. Ünite-ders-egzersiz listesi
7. Hangi içeriklerin uygulamada kullanılabileceğine dair yazılı onay
8. Eğer varsa InDesign / XML / EPUB kaynak dosyaları
9. Kitapların seviye bilgileri: A1, A2, B1...
10. Öğrenci/öğretmen kullanım senaryoları

⸻

22. Firmaya gönderilecek açıklama

Şunu kullanabilirsin:

Uygulamayı sürdürülebilir şekilde geliştirebilmemiz için viewer linki yerine içeriklerin kaynak dosyalarına ihtiyacımız olacak.
PDF’i sisteme import edip sayfa görsellerini oluşturabiliriz. Sayfalardan gerekli görselleri kırpıp uygulama asset’i haline getirebiliriz. Ayrıca ses dosyaları, cevap anahtarları ve egzersiz eşleştirme bilgileri gelirse içerikleri doğrudan interaktif egzersizlere dönüştürebiliriz.
Teknik olarak sistem şu şekilde çalışacak:
PDF → sayfa görselleri → medya asset’leri → interaktif egzersizler → öğrenci çözümü → öğretmen raporu.
Eğer mevcut reader sisteminde canvas/annotation verileri varsa bunları da import edip sayfa üstü yazı, işaretleme ve hotspot bilgisi olarak kullanabiliriz.

⸻

23. Riskler

23.1 İçerik formatı riski

Firma sadece viewer linki verirse import zorlaşır.

Çözüm:

Tam PDF + medya dosyalarını istemek

23.2 Görsel kalitesi riski

PDF’den çıkarılan görseller düşük kalite olabilir.

Çözüm:

Orijinal görselleri istemek
PDF sayfalarını 300 DPI üretmek
Admin crop tool yapmak

23.3 Egzersiz mapping riski

PDF’deki egzersizi otomatik anlamak her zaman mümkün değil.

Çözüm:

AI destekli import + insan onayı

23.4 Telif / lisans riski

Firma yaptırıyor olsa bile yazılı izin gerekli.

Çözüm:

İçerik kullanım izni ve lisans durumunu kayıt altına almak

23.5 Session/token bağımlılığı

EduReader endpoint’leri geçici olabilir.

Çözüm:

Endpoint’i runtime’da kullanmamak
Sadece import aşamasında kullanmak
Kendi storage sistemimize almak

⸻

24. Sonraki fazlar

Faz 2 — AI özellikleri

Yanlış cevaba açıklama üretme
Ek pratik üretme
Yazma cevabı düzeltme
Konuşma pratiği
Telaffuz analizi

Faz 3 — Mobil uygulama

Flutter app
Offline sayfa görüntüleme
Offline egzersiz çözme
Sonra sync

Faz 4 — LMS entegrasyonu

Moodle
Google Classroom
Canvas
LTI entegrasyonu

Faz 5 — Multi-school SaaS

Her okul kendi kitaplarını yükler
Kendi öğretmen/öğrenci yapısı olur
Subscription modeli

⸻

25. Başlangıç için yapılacak ilk 10 iş

Bence projeyi başlatırken sırayla şunları yap:

1. Repo oluştur
2. Docker compose ile PostgreSQL + Redis ayağa kaldır
3. NestJS API kur
4. Next.js admin panel kur
5. Prisma schema oluştur
6. Organization / user / role seed et
7. Book CRUD yap
8. PDF upload endpoint yap
9. PDF’i sayfalara çeviren worker yaz
10. Admin panelde kitap sayfalarını göster

Bunlar bitince proje gerçekten başlamış olur.

⸻

26. Minimum geliştirme ekibi

MVP için ideal ekip:

1 Backend developer
1 Frontend developer
1 UI/UX designer
1 Content operator / admin
1 Project owner

Sen backend/frontend’i yöneteceksen, ilk etapta 2 kişiyle bile başlanabilir:

1 full-stack developer
1 content/admin person

⸻

27. Tahmini süre

MVP gerçekçi süre:

6–8 hafta

Daha hızlı demo:

2 hafta içinde clickable demo
3–4 hafta içinde çalışan import + egzersiz demo
6–8 hafta içinde öğretmen/öğrenci MVP

⸻

28. En doğru ilk teknik karar

Ben bu projede şunu öneririm:

Önce web app + admin panel yap.
Mobil uygulamayı ikinci faza bırak.

Çünkü asıl zor kısım mobil değil:

PDF import
görsel/ses asset yönetimi
egzersiz builder
cevap kontrol motoru
öğretmen raporu

Bunlar oturmadan mobil uygulama sadece ekran olur.

⸻

29. Net proje tanımı

Bu proje şu cümleyle anlatılabilir:

Mevcut dil okulu kitaplarını PDF, görsel, ses ve canvas verileriyle birlikte içe aktaran; bu içerikleri interaktif egzersizlere dönüştüren; öğrenci çözüm ve öğretmen takip sistemi sunan web tabanlı bir dil öğrenme platformu.

⸻

30. Projeye başlama kararı

Ben olsam projeyi şu isimle başlatırdım:

edu-language-platform

İlk milestone:

PDF Import + Page Viewer + Exercise Builder MVP

İlk demo hedefi:

9783191810801.pdf sisteme yüklenecek
İlk 10 sayfa görsele çevrilecek
İlk sayfadan 2 görsel kırpılacak
10 tane egzersiz oluşturulacak
Öğrenci bu egzersizleri çözecek
Öğretmen sonucu görecek

Bu demo çıktısı firmaya proje vizyonunu net gösterir.