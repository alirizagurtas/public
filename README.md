# PS-Filtered-Project-Archiver

## 🗑️ Gereksiz Dosyalardan Arındırılmış,  
## Tarih Damgalı PowerShell Proje Yedekleme Scripti 📂

Yazılım projelerinizi yedeklerken `node_modules`, `.git`,  
build çıktıları, cache dosyaları gibi gereksiz ve yer kaplayan klasörleri  
veya `.log`, `.tmp`, `.obj` gibi dosyaları da yedeklemekten bıktınız mı?  
Bulut depolama (Google Drive, OneDrive vb.) alanınız bu şişkin yedekler yüzünden doluyor mu?

**PS-Filtered-Project-Archiver**, bu sorunları çözmek için tasarlanmış  
basit ama etkili bir PowerShell scriptidir. Belirlediğiniz proje klasörlerini,  
tanımladığınız hariç tutma listesine göre filtreleyerek,  
temiz ve sıkıştırılmış (ZIP) arşivler halinde,  
her çalıştırmada tarih damgalı ayrı dosyalar olarak yedekler.

Bu sayede:

*   💾 **Alandan Tasarruf Edersiniz:**  
    Sadece projenizin kaynak kodunu ve önemli dosyalarını yedekleyerek  
    bulut depolama ve yerel disk alanınızı verimli kullanırsınız.
*   ✨ **Temiz Yedekler Elde Edersiniz:**  
    Yedeklerinizde development ortamınıza ait geçici veya yeniden oluşturulabilir dosyalar bulunmaz.
*   📅 **Tarihli Versiyonlarınız Olur:**  
    Her yedekleme ayrı bir ZIP dosyası olarak kaydedilir,  
    böylece kolayca farklı tarihlerdeki proje durumlarına geri dönebilirsiniz.
*   🚀 **Senkronizasyon Hızını Artırırsınız:**  
    Bulut senkronizasyon araçları (Google Drive Sync gibi)  
    sadece temizlenmiş, sıkıştırılmış ve yeni oluşturulmuş küçük ZIP dosyalarını yükler,  
    bu da senkronizasyon süresini önemli ölçüde kısaltır.
*   💻 **PowerShell İle Çalışır:**  
    Ek bir yazılım kurulumuna gerek kalmadan  
    Windows üzerindeki PowerShell ile doğrudan kullanabilirsiniz.

## Nasıl Çalışır?

Script, yapılandırmanıza göre şu adımları izler:

1.  Yedeklemek istediğiniz her bir kaynak klasörünü sırayla işler.
2.  Her kaynak klasör için, hariç tutulacak klasörler ve dosya uzantıları listesini  
    kullanarak içeriği Windows'un geçici klasörüne kopyalar.
3.  Geçici klasöre kopyalanan filtrelenmiş içeriği alır.
4.  Bu içeriği, kaynak klasör adı ve o anki tarih/saat ile isimlendirilmiş  
    (\`KaynakKlasorAdı_YYYY-MM-dd_HH-mm-ss.zip\` formatında)  
    bir ZIP dosyasına sıkıştırır.
5.  Oluşturulan ZIP dosyasını belirlediğiniz hedef yedekleme klasörüne kaydeder.
6.  İşlem bittikten veya bir hata oluştuğunda geçici klasörü otomatik olarak temizler.

## Gereksinimler

*   Windows İşletim Sistemi
*   PowerShell 5.0 veya üstü (Windows 10 ve sonrası genellikle dahili olarak bu sürümleri içerir)

## Kurulum

1.  Bu depoyu bilgisayarınıza klonlayın veya script dosyasını (\`.ps1\`) indirin.

    ```bash
    git clone https://github.com/alirizagurtas/PowerShell-Project-Backup-Archiver.git
    ```
    (Yukarıdaki URL'yi kendi GitHub kullanıcı adınız ve repo adınız ile değiştirin)

2.  Script dosyasını bilgisayarınızda kolay erişilebilir bir yere kaydedin  
    (örn: \`C:\Scripts\Backup-Projects.ps1\`).

## Yapılandırma

Scriptin çalışması için \`.ps1\` dosyasını bir metin düzenleyici ile açın  
ve dosyanın başındaki \`param(...)\` bloğunu kendi ihtiyaçlarınıza göre düzenleyin:

```powershell
param(
    [string[]]$SourceRoots = @(
        "C:\Yol\To\Your\Project1",   # <-- Yedeklenecek 1. proje klasörü
        "D:\Another\ProjectFolder"   # <-- Yedeklenecek 2. proje klasörü
        # Virgülle ayırarak istediğiniz kadar klasör ekleyebilirsiniz
    ),
    [string]$DestinationRoot = "C:\Users\KullaniciAdi\GoogleDriveKlasorunuz\ProjectBackups",  # <-- ZIP dosyalarının kaydedileceği klasör
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
