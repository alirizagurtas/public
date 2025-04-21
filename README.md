<!-- Türkçe -->
## 🇹🇷 Türkçe
# powershell-project-backup-archiver
## 📂 Tarih Damgalı PowerShell Proje Yedekleme Scripti

Yazılım projelerinizi yedeklerken `node_modules`, `.git`,  
build çıktıları, cache dosyaları gibi gereksiz ve yer kaplayan klasörleri  
veya `.log`, `.tmp`, `.obj` gibi dosyaları da yedeklemekten bıktınız mı?  
Bulut depolama (Google Drive, OneDrive vb.) alanınız bu şişkin yedekler yüzünden doluyor mu?

**powershell-project-backup-archiver**, bu sorunları çözmek için tasarlanmış  
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
    https://github.com/alirizagurtas/powershell-project-backup-archiver.git
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
```

<!-- English -->
## 🇬🇧 English

# powershell-project-backup-archiver
## 📂 Date-Stamped PowerShell Project Backup Script

Are you tired of backing up unnecessary and space-consuming folders like `node_modules`, `.git`,
build outputs, and cache files, or files like `.log`, `.tmp`, and `.obj`,
when backing up your software projects?
Is your cloud storage (Google Drive, OneDrive, etc.) filling up because of these bloated backups?

**powershell-project-backup-archiver** is a simple yet effective PowerShell script designed
to solve these problems. It backs up your specified project folders by filtering them
according to a defined exclusion list, creating clean and compressed (ZIP) archives
as separate date-stamped files for each run.

With this script, you will:

*   💾 **Save Space:**
    By backing up only your project's source code and essential files, you efficiently use
    your cloud storage and local disk space.
*   ✨ **Get Clean Backups:**
    Your backups won't contain temporary or re-creatable files from your development environment.
*   📅 **Have Dated Versions:**
    Each backup is saved as a separate ZIP file, allowing you to easily revert
    to different project states from different dates.
*   🚀 **Increase Synchronization Speed:**
    Cloud synchronization tools (like Google Drive Sync) only upload the cleaned,
    compressed, and newly created small ZIP files, which significantly shortens the sync time.
*   💻 **Work with PowerShell:**
    You can use it directly with PowerShell on Windows without needing additional software installation.

## How It Works

Based on your configuration, the script follows these steps:

1.  It processes each source folder you want to back up sequentially.
2.  For each source folder, it copies the content to Windows' temporary folder
    using the list of folders and file extensions to exclude.
3.  It takes the filtered content copied to the temporary folder.
4.  It compresses this content into a ZIP file named with the source folder name
    and the current date/time (in the format `SourceFolderName_YYYY-MM-dd_HH-mm-ss.zip`).
5.  It saves the created ZIP file to your specified destination backup folder.
6.  It automatically cleans up the temporary folder after the process finishes
    or if an error occurs.

## Requirements

*   Windows Operating System
*   PowerShell 5.0 or higher (Windows 10 and later usually include these versions natively)

## Installation

1.  Clone this repository to your computer or download the script file (`.ps1`).

    ```bash
    https://github.com/your-github-username/powershell-project-backup-archiver.git
    ```
    (Replace the URL above with your own GitHub username and repo name)

2.  Save the script file to an easily accessible location on your computer
    (e.g., `C:\Scripts\Backup-Projects.ps1`).

## Configuration

To run the script, open the `.ps1` file with a text editor and modify the `param(...)` block
at the beginning of the file according to your needs:

```powershell
param(
    [string[]]$SourceRoots = @(
        "C:\Path\To\Your\Project1",   # <-- 1st project folder to back up
        "D:\Another\ProjectFolder"   # <-- 2nd project folder to back up
        # You can add as many folders as you want, separated by commas
    ),
    [string]$DestinationRoot = "C:\Users\YourUserName\GoogleDriveFolder\ProjectBackups",  # <-- Folder where the ZIP files will be saved
    [string[]]$ExcludeFolders = @(
        # Default folders to exclude... You can modify this list.
        "node_modules",
        ".venv",
        # ... others ...
    ),
    [string[]]$ExcludeFileExtensions = @(
        # Default file extensions to exclude... You can modify this list.
        ".log",
        ".tmp",
        # ... others ...
    )
)
