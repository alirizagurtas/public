```markdown
# PS-Filtered-Project-Archiver

## 🗑️ Gereksiz Dosyalardan Arındırılmış, Tarih Damgalı PowerShell Proje Yedekleme Scripti 📂

Yazılım projelerinizi yedeklerken `node_modules`, `.git`, build çıktıları, cache dosyaları gibi gereksiz ve yer kaplayan klasörleri veya `.log`, `.tmp`, `.obj` gibi dosyaları da yedeklemekten bıktınız mı? Bulut depolama (Google Drive, OneDrive vb.) alanınız bu şişkin yedekler yüzünden doluyor mu?

**PS-Filtered-Project-Archiver**, bu sorunları çözmek için tasarlanmış basit ama etkili bir PowerShell scriptidir. Belirlediğiniz proje klasörlerini, tanımladığınız hariç tutma listesine göre filtreleyerek, temiz ve sıkıştırılmış (ZIP) arşivler halinde, her çalıştırmada tarih damgalı ayrı dosyalar olarak yedekler.

Bu sayede:

*   💾 **Alandan Tasarruf Edersiniz:** Sadece projenizin kaynak kodunu ve önemli dosyalarını yedekleyerek bulut depolama ve yerel disk alanınızı verimli kullanırsınız.
*   ✨ **Temiz Yedekler Elde Edersiniz:** Yedeklerinizde development ortamınıza ait geçici veya yeniden oluşturulabilir dosyalar bulunmaz.
*   📅 **Tarihli Versiyonlarınız Olur:** Her yedekleme ayrı bir ZIP dosyası olarak kaydedilir, böylece kolayca farklı tarihlerdeki proje durumlarına geri dönebilirsiniz.
*   🚀 **Senkronizasyon Hızını Artırırsınız:** Bulut senkronizasyon araçları (Google Drive Sync gibi) sadece temizlenmiş, sıkıştırılmış ve yeni oluşturulmuş küçük ZIP dosyalarını yükler, bu da senkronizasyon süresini önemli ölçüde kısaltır.
*   💻 **PowerShell İle Çalışır:** Ek bir yazılım kurulumuna gerek kalmadan Windows üzerindeki PowerShell ile doğrudan kullanabilirsiniz.

## Nasıl Çalışır?

Script, yapılandırmanıza göre şu adımları izler:

1.  Yedeklemek istediğiniz her bir kaynak klasörünü sırayla işler.
2.  Her kaynak klasör için, hariç tutulacak klasörler ve dosya uzantıları listesini kullanarak içeriği Windows'un geçici klasörüne kopyalar.
3.  Geçici klasöre kopyalanan filtrelenmiş içeriği alır.
4.  Bu içeriği, kaynak klasör adı ve o anki tarih/saat ile isimlendirilmiş (`KaynakKlasorAdı_YYYY-MM-dd_HH-mm-ss.zip` formatında) bir ZIP dosyasına sıkıştırır.
5.  Oluşturulan ZIP dosyasını belirlediğiniz hedef yedekleme klasörüne kaydeder.
6.  İşlem bittikten veya bir hata oluştuğunda geçici klasörü otomatik olarak temizler.

## Gereksinimler

*   Windows İşletim Sistemi
*   PowerShell 5.0 veya üstü (Windows 10 ve sonrası genellikle dahili olarak bu sürümleri içerir)

## Kurulum

1.  Bu depoyu bilgisayarınıza klonlayın veya script dosyasını (`.ps1`) indirin.

    ```bash
    git clone https://github.com/KullaniciAdiniz/ps-filtered-project-archiver.git
    ```
    (Yukarıdaki URL'yi kendi GitHub kullanıcı adınız ve repo adınız ile değiştirin)

2.  Script dosyasını bilgisayarınızda kolay erişilebilir bir yere kaydedin (örn: `C:\Scripts\Backup-Projects.ps1`).

## Yapılandırma

Scriptin çalışması için `.ps1` dosyasını bir metin düzenleyici ile açın ve dosyanın başındaki `param(...)` bloğunu kendi ihtiyaçlarınıza göre düzenleyin:

```powershell
param(
    [string[]]$SourceRoots = @(
        "C:\Yol\To\Your\Project1",   # <-- Yedeklenecek 1. proje klasörü
        "D:\Another\ProjectFolder"   # <-- Yedeklenecek 2. proje klasörü
        # Virgülle ayırarak istediğiniz kadar klasör ekleyebilirsiniz
    ),
    [string]$DestinationRoot = "C:\Users\KullaniciAdi\YourGoogleDriveFolder\ProjectBackups",  # <-- ZIP dosyalarının kaydedileceği klasör
    [string[]]$ExcludeFolders = @(
        # Varsayılan hariç tutulacak klasörler... Bu listeyi düzenleyebilirsiniz.
        "node_modules",
        ".venv",
        # ... diğerleri ...
    ),
    [string[]]$ExcludeFileExtensions = @(
        # Varsayılan hariç tutulacak dosya uzantıları... Bu listeyi düzenleyebilirsiniz.
        ".log",
        ".tmp",
        # ... diğerleri ...
    )
)
```

*   `$SourceRoots`: Yedeklemek istediğiniz *tüm* proje klasörlerinin yollarını çift tırnak içinde ve virgülle ayırarak buraya ekleyin.
*   `$DestinationRoot`: Oluşturulan ZIP dosyalarının kaydedileceği klasörün tam yolunu girin. Bu klasörün Google Drive, OneDrive vb. senkronizasyon klasörünüz içinde olması önerilir.
*   `$ExcludeFolders`: Yedekleme sırasında tamamen atlanacak klasörlerin isimlerini (tam eşleşme, büyük/küçük harf önemsiz) çift tırnak içinde ve virgülle ayırarak buraya ekleyin.
*   `$ExcludeFileExtensions`: Yedekleme sırasında tamamen atlanacak dosya uzantılarını (başında nokta ile, büyük/küçük harf önemsiz) çift tırnak içinde ve virgülle ayırarak buraya ekleyin.

## Kullanım

1.  Bir PowerShell penceresi açın.
2.  Script dosyasını kaydettiğiniz klasöre gidin.

    ```powershell
    cd C:\Scripts
    ```
3.  Scripti çalıştırın.

    ```powershell
    .\Backup-ToZipArchives.ps1
    ```

    *Not:* Eğer scripti ilk defa çalıştırıyorsanız ve bir "Execution Policy" hatası alırsanız, şu komutu çalıştırıp onaylayın ve scripti tekrar çalıştırın:
    ```powershell
    Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```
    Bu, sizin kullanıcı hesabınız için lokal scriptlerin çalıştırılmasına izin verir.

Script çalışırken konsola hangi klasörleri işlediğini, hangi öğeleri atladığını ve hangi ZIP dosyalarını oluşturduğunu yazacaktır. İşlem tamamlandığında, belirlediğiniz `$DestinationRoot` klasöründe tarih damgalı ZIP arşivlerini bulacaksınız.

Bu scripti Windows Görev Zamanlayıcı (Task Scheduler) kullanarak periyodik olarak otomatik çalışacak şekilde ayarlayabilirsiniz.

## Hariç Tutulan Varsayılan Öğeler

Script varsayılan olarak şu klasörleri ve dosya uzantılarını hariç tutar (script dosyasını düzenleyerek bu listeleri değiştirebilirsiniz):

**Hariç Tutulan Klasörler (`$ExcludeFolders`):**

*   `node_modules`
*   `.venv`
*   `venv`
*   `env`
*   `dist`
*   `build`
*   `__pycache__`
*   `.idea`
*   `bin`
*   `obj`
*   `target`
*   `Vendor`
*   `tmp`
*   `temp`

**Hariç Tutulan Dosya Uzantıları (`$ExcludeFileExtensions`):**

*   `.log`
*   `.tmp`
*   `.temp`
*   `.bak`
*   `.swp`
*   `.swo`
*   `.cache`
*   `.pyc`
*   `.class`
*   `.obj`
*   `.exe`
    ... (Scriptteki tam listeye bakın)

## Katkıda Bulunma

Geliştirmeye katkıda bulunmak isterseniz lütfen çekinmeyin! Sorun bildirmek veya özellik önermek için bir "Issue" açabilir, iyileştirmeler yapmak için bir "Pull Request" gönderebilirsiniz.

## Lisans

Bu proje MIT Lisansı ile lisanslanmıştır. Daha fazla bilgi için [LICENSE](LICENSE) dosyasına bakabilirsiniz.

---
```

---

### **Öneri 2: Script Dosyasının Başındaki Açıklama Bloğu (`<# ... #>`)**

Bu blok zaten scriptin içinde mevcut ve teknik bir referans görevi görür. Mevcut bloğu güncelleyip biraz daha detay ekleyelim.

```powershell
<#
.SYNOPSIS
Birden fazla kaynak klasöründeki dosyaları ve alt klasörleri, belirtilen klasörleri ve dosya uzantılarını hariç tutarak tarih damgalı ZIP arşivleri oluşturur.
Gereksiz development dosyalarının yedeklenmesini engelleyerek bulut depolama alanından tasarruf sağlar.

.DESCRIPTION
Bu script, SourceRoots olarak belirtilen her bir kaynak klasörünü ayrı ayrı işleyerek yedekler.
Her kaynak klasör için:
1. İçeriği, ExcludeFolders ve ExcludeFileExtensions listeleri kullanılarak filtrelenir.
2. Filtrelenmiş içerik, Windows'un geçici dizinindeki benzersiz bir alt klasöre kopyalanır.
3. Geçici klasördeki içerik, DestinationRoot altında, kaynak klasör adı ve güncel tarih/saat (YYYY-MM-dd_HH-mm-ss formatında) ile isimlendirilmiş ayrı bir ZIP dosyasına sıkıştırılır.
4. Sıkıştırma işlemi tamamlandıktan sonra geçici klasör otomatik olarak silinir.
Bu yaklaşım, her yedeklemenin temiz, optimize edilmiş ve ayrı bir arşiv olarak saklanmasını sağlar.

.PARAMETER SourceRoots
Yedeklenecek ana klasörlerin (genellikle proje klasörleriniz) yollarını içeren bir string dizisi. Script bu dizideki her elemanı ayrı bir yedekleme birimi olarak işler.
Örn: @("C:\Yol\To\ProjeA", "D:\Gelistirme\ProjeB")

.PARAMETER DestinationRoot
Oluşturulan ZIP arşivlerinin kaydedileceği hedef klasörün yolu. Bu klasör, bulut senkronizasyon aracınız (Google Drive, OneDrive vb.) tarafından takip edilen bir konumda olmalıdır. Her yedek ZIP dosyası buraya kaydedilir.
Örn: "C:\Users\KullaniciAdi\Drive'ım\Yedekler\Projeler"

.PARAMETER ExcludeFolders
Yedekleme sırasında tamamen atlanacak (kopyalanmayacak ve arşivlenmeyecek) klasör isimlerini içeren bir string dizisi. Bu isimler büyük/küçük harfe duyarlı değildir. Belirtilen isimdeki klasörler, kaynak yolların altında herhangi bir derinlikte bulunsa da atlanacaktır.
Örn: @("node_modules", ".venv", "build", "__pycache__")

.PARAMETER ExcludeFileExtensions
Yedekleme sırasında tamamen atlanacak (kopyalanmayacak ve arşivlenmeyecek) dosya uzantılarını içeren bir string dizisi. Uzantılar nokta (.) ile başlamalıdır ve büyük/küçük harfe duyarlı değildir. Belirtilen uzantıya sahip dosyalar, kaynak yolların altında herhangi bir klasörde bulunsa da atlanacaktır.
Örn: @(".log", ".tmp", ".bak", ".exe")

.EXAMPLE
.\Backup-ToZipArchives.ps1
Scriptin içinde tanımlanan varsayılan parametre değerlerini kullanarak yedeklemeyi başlatır.

.EXAMPLE
.\Backup-ToZipArchives.ps1 -SourceRoots @("C:\MyCode", "D:\OldProjects") -DestinationRoot "E:\GDriveBackup" -ExcludeFolders @("vendor", "obj") -ExcludeFileExtensions @(".log", ".cache")
Belirtilen iki kaynak klasörü, özel hariç tutma listeleriyle belirtilen hedefe ZIP arşivlerine yedekler.

.NOTES
- Script, kopyalama, sıkıştırma ve temizlik işlemleri sırasında temel hata yönetimini içerir.
- Klasör ve dosya uzantısı karşılaştırmaları büyük/küçük harfe duyarlı değildir.
- Sıkıştırma işlemi sırasında, yedeklenecek içeriğin ham boyutu kadar ek geçici disk alanına ihtiyaç duyulabilir.
- Geçici klasör işlem tamamlandıktan veya hata durumunda otomatik olarak silinir.
- ZIP dosya isimleri YYYY-MM-dd_HH-mm-ss formatında tarih/saat bilgisi içerir, bu da kronolojik sıralama ve versiyon takibi için kullanışlıdır.
- Script, PowerShell'in yerleşik Compress-Archive cmdlet'ini kullandığı için PowerShell 5.0 veya daha yeni bir sürüm gerektirir.
#>
```

---

Bu metinleri kullanarak GitHub deponuzu zenginleştirebilir ve scriptinizin amacını, faydalarını ve kullanımını net bir şekilde anlatabilirsiniz. README dosyasındaki `KullaniciAdiniz` kısmını kendi GitHub kullanıcı adınız ve repo adınız ile değiştirmeyi unutmayın.

Başarılar dilerim yayınlamada!
