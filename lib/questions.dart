import 'package:flutter/material.dart';

/// A true/false question with a short explanation shown after answering.
class Question {
  final String text;
  final bool answer;
  final String why;
  const Question(this.text, this.answer, this.why);
}

class Category {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Question> questions;
  const Category(this.id, this.title, this.subtitle, this.icon, this.color, this.questions);
}

const categories = <Category>[
  Category('flutter', 'Flutter', 'Widget, state ve araçlar', Icons.flutter_dash, Color(0xFF0288D1), [
    Question('Flutter sadece Dart programlama dilini kullanır.', true, 'Flutter uygulamaları Dart ile yazılır; platform kodu gerektiğinde Kotlin/Swift kanalları kullanılır.'),
    Question('Flutter yalnızca mobil uygulamalar için kullanılabilir, web veya masaüstü için değil.', false, 'Flutter mobil, web, Windows, macOS ve Linux için derlenebilir. Bu uygulama da Flutter Web ile çalışıyor.'),
    Question("Flutter'da Widget'lar ya Stateful ya da Stateless olabilir.", true, 'Durumu değişen arayüzler StatefulWidget, sabit olanlar StatelessWidget ile yazılır.'),
    Question("Flutter'daki Hot Reload uygulamayı tamamen yeniden başlatır.", false, 'Hot Reload kodu enjekte eder ve durumu korur; tamamen yeniden başlatan Hot Restart’tır.'),
    Question("Flutter'daki tüm öğeler, düğmeler, metinler ve arka planlar dahil, Widget olarak kabul edilir.", true, 'Flutter’da arayüzün her parçası bir widget ağacının elemanıdır.'),
    Question('setState çağrıldığında build metodu yeniden çalışır.', true, 'setState, widget’ı “kirli” işaretler ve bir sonraki karede build yeniden çağrılır.'),
    Question('pubspec.yaml dosyası yalnızca uygulamanın adını tutar.', false, 'Bağımlılıklar, varlıklar (assets), fontlar ve sürüm bilgisi de pubspec.yaml’dadır.'),
    Question('Material 3, Flutter’ın varsayılan tasarım sistemidir.', true, 'Flutter 3.16’dan beri useMaterial3 varsayılan olarak açıktır.'),
  ]),
  Category('dart', 'Dart', 'Dil temelleri', Icons.code_rounded, Color(0xFF00897B), [
    Question("Dart'ta 'final' ve 'const' tamamen aynı anlama gelir.", false, 'final çalışma zamanında bir kez atanır; const derleme zamanında bilinmelidir.'),
    Question("Dart null safety ile bir değişken varsayılan olarak null olamaz.", true, "Null olabilmesi için türün sonuna '?' eklenir, örn. String?."),
    Question("'async' fonksiyonlar her zaman bir Future döndürür.", true, 'async gövdeli bir fonksiyonun dönüş tipi Future<T> olur.'),
    Question('Dart tek iş parçacıklı (single-threaded) bir event loop ile çalışır.', true, 'Ağır işler için ayrı belleği olan Isolate’lar kullanılır.'),
    Question("List<int> sayilar = [1, 2, 3]; sayilar.length değeri 4'tür.", false, 'Listede üç eleman var, yani length 3’tür.'),
    Question("Dart'ta fonksiyonlar değişkene atanabilir ve parametre olarak geçirilebilir.", true, 'Dart’ta fonksiyonlar birinci sınıf nesnelerdir.'),
    Question("'var' ile tanımlanan bir değişkenin tipi sonradan değiştirilebilir.", false, 'var tipini ilk atanan değerden çıkarır ve sonra değişmez; tip değişebilsin istenirse dynamic kullanılır.'),
    Question('Dart hem JIT hem AOT derlemeyi destekler.', true, 'Geliştirmede JIT (hot reload), yayında AOT (hızlı başlangıç) kullanılır.'),
  ]),
  Category('web', 'Web', 'HTML, CSS, JavaScript', Icons.language_rounded, Color(0xFFF4511E), [
    Question('HTML bir programlama dilidir.', false, 'HTML bir işaretleme (markup) dilidir; mantık ve döngü içermez.'),
    Question("CSS'te 'flex' ve 'grid' yerleşim için kullanılır.", true, 'Flexbox tek eksenli, Grid iki eksenli yerleşim içindir.'),
    Question("JavaScript'te '===' hem değeri hem tipi karşılaştırır.", true, "'==' tip dönüşümü yapar, '===' yapmaz."),
    Question('localStorage verileri tarayıcı kapanınca silinir.', false, 'Silinen sessionStorage’dır; localStorage kalıcıdır.'),
    Question("HTTP 404 kodu 'sunucu hatası' anlamına gelir.", false, '404 “bulunamadı” demektir; sunucu hataları 5xx ile başlar.'),
    Question('HTTPS, iletilen veriyi şifreler.', true, 'HTTPS, HTTP’nin TLS ile şifrelenmiş halidir.'),
    Question("<img> etiketinde 'alt' metni erişilebilirlik için önemlidir.", true, 'Ekran okuyucular görseli alt metniyle anlatır; görsel yüklenmezse de görünür.'),
    Question("JavaScript yalnızca tarayıcıda çalışabilir.", false, 'Node.js sayesinde sunucuda da çalışır.'),
  ]),
  Category('genel', 'Yazılım', 'Genel bilgiler', Icons.memory_rounded, Color(0xFF8E24AA), [
    Question('Git bir sürüm kontrol sistemidir.', true, 'Git, kodun geçmişini ve dallarını yönetir; GitHub ise Git depolarını barındıran bir hizmettir.'),
    Question("SQL'de SELECT komutu veriyi siler.", false, 'SELECT veriyi okur; silmek için DELETE kullanılır.'),
    Question('Bir API, iki yazılımın birbiriyle konuşmasını sağlar.', true, 'API (Application Programming Interface) yazılımlar arasındaki sözleşmedir.'),
    Question('RAM kalıcı bir depolama birimidir.', false, 'RAM geçicidir; elektrik kesilince içeriği silinir.'),
    Question('İkili sistemde 1010 sayısı onluk sistemde 10’a eşittir.', true, '8 + 0 + 2 + 0 = 10.'),
    Question('Bir algoritmanın O(n) karmaşıklığı, girdi büyüdükçe süresinin doğrusal arttığı anlamına gelir.', true, 'Girdi iki katına çıkınca süre de yaklaşık iki katına çıkar.'),
    Question('Python derlenen, Java ise yorumlanan bir dildir.', false, 'Genel olarak tersi: Python yorumlanır, Java bayt koda derlenip JVM’de çalışır.'),
    Question('Makine öğrenmesi, yapay zekânın bir alt alanıdır.', true, 'Makine öğrenmesi, verilerden öğrenen yapay zekâ yöntemlerini kapsar.'),
  ]),
];
