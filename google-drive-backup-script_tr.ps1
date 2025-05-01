<#
.SYNOPSIS
Birden fazla kaynak klasöründeki dosyaları ve alt klasörleri, belirtilen klasörleri ve dosya uzantılarını hariç tutarak ZIP arşivleri oluşturur.
Her kaynak klasör için, hedef klasör altında tarih damgalı ayrı bir ZIP dosyası oluşturulur.

.DESCRIPTION
Script, SourceRoots olarak belirtilen her bir klasörü ayrı ayrı işler.
Her kaynak klasörün içeriği (dosya ve alt klasörler), önce belirtilen klasörler ve dosya uzantıları hariç tutularak geçici bir klasöre kopyalanır.
Daha sonra bu geçici klasörün içeriği, DestinationRoot altında kaynak klasörün adı ve güncel tarih/saat ile isimlendirilmiş bir ZIP dosyasına sıkıştırılır.
Sıkıştırma tamamlandıktan sonra geçici klasör silinir.

.PARAMETER SourceRoots
Yedeklenecek ana klasörlerin yollarını içeren bir string dizisi.
Her bir eleman, bağımsız olarak yedeklenecek bir klasörü temsil eder.
Örn: @("C:\Users\KullaniciAdi\Documents\ProjeA", "D:\Development\ProjeB")

.PARAMETER DestinationRoot
Oluşturulan ZIP arşivlerinin kaydedileceği hedef klasörün yolu.
Bu klasör genellikle Google Drive veya benzeri bir senkronizasyon aracının
takip ettiği bir klasör içinde olmalıdır.
Örn: "C:\Users\KullaniciAdi\Drive'ım\ProjelerYedegiArsiv"

.PARAMETER ExcludeFolders
Yedekleme sırasında hariç tutulacak klasör isimlerini içeren bir string dizisi.
Bu isimler büyük/küçük harfe duyarlı değildir. Bu klasörler, SourceRoots altındaki
herhangi bir seviyede bulunduğunda kopyalanmayacaktır.
Örn: @("node_modules", ".venv", "build", "__pycache__", ".git")

.PARAMETER ExcludeFileExtensions
Yedekleme sırasında hariç tutulacak dosya uzantılarını içeren bir string dizisi.
Uzantılar nokta (.) ile başlamalıdır. Büyük/küçük harfe duyarlı değildir.
Bu uzantılara sahip dosyalar kopyalanmayacaktır.
Örn: @(".log", ".tmp", ".bak", ".cache")

.EXAMPLE
.\Backup-ToZipArchives.ps1
Bu, scriptin içinde tanımlanan varsayılan SourceRoots, DestinationRoot, ExcludeFolders
ve ExcludeFileExtensions değerlerini kullanarak yedeklemeyi başlatır ve ZIP dosyaları oluşturur.

.EXAMPLE
.\Backup-ToZipArchives.ps1 -SourceRoots @("C:\MyCode\Proj1", "D:\OldProjects\ProjX") -DestinationRoot "E:\GDriveBackup\Archives" -ExcludeFolders @("vendor") -ExcludeFileExtensions @(".log")
Belirtilen iki klasörü, farklı hariç tutmalarla ZIP arşivlerine yedekler.

.NOTES
Script, kopyalama ve sıkıştırma sırasında hataları yakalamaya çalışır.
Klasör ve dosya uzantısı isimleri case-insensitive olarak karşılaştırılır.
Sıkıştırma işlemi geçici bir klasör kullanır, bu da ek disk alanı gerektirebilir
(geçici olarak yedeklenecek verinin ham boyutu kadar).
Geçici klasör işlem sonrası otomatik olarak silinir.
ZIP dosya isimleri YYYY-MM-DD_HH-mm-ss formatında tarih/saat bilgisi içerir.
#>
param(
    [string[]]$SourceRoots = @(
        "C:\Yol\To\Your\Project1",   # <-- Yedeklenecek 1. proje klasörü
        "D:\Another\ProjectFolder"   # <-- Yedeklenecek 2. proje klasörü
        # Virgülle ayırarak istediğiniz kadar klasör ekleyebilirsiniz
    ),
    [string]$DestinationRoot = "C:\Users\KullaniciAdi\GoogleDriveKlasorunuz\ProjectBackups",  # <-- ZIP dosyalarının kaydedileceği klasör
    [string[]]$ExcludeFolders = @(
        "node_modules", # JavaScript/Node.js bağımlılıkları
        ".venv",        # Python Sanal Ortam (venv)
        "venv",         # Python Sanal Ortam (venv)
        "env",          # Python Sanal Ortam (yaygın isimler)
        ".git",         # Git versiyon kontrol klasörü (yedeklemeye genellikle gerek yok)
        "dist",         # Build çıktıları (örn: webpack, parcel)
        "build",        # Build çıktıları (örn: make, setup.py)
        "__pycache__",  # Python cache dosyaları
        ".vscode",      # VS Code ayar klasörleri (isteğe bağlı, dahil etmek isterseniz silin)
        ".idea",        # JetBrains IDE ayar klasörleri (isteğe bağlı)
        "bin",          # Derlenmiş çıktılar (örn: .NET, Java)
        "obj",          # Derleme ara dosyaları (.NET)
        "target",       # Build çıktıları (örn: Rust, Maven)
        "Vendor",       # Composer bağımlılıkları (PHP)
        "tmp",          # Geçici dosyalar
        "temp"          # Geçici dosyalar
    ),
    [string[]]$ExcludeFileExtensions = @(
        ".log",    # Log dosyaları
        ".tmp",    # Geçici dosyalar
        ".temp",   # Geçici dosyalar
        ".bak",    # Yedek dosyalar (genellikle)
        ".swp",    # Swap dosyaları (Vim gibi editörler)
        ".swo",    # Swap dosyaları (Vim gibi editörler)
        ".cache",  # Cache dosyaları
        ".pyc",    # Python compiled files (__pycache__ zaten hariç tutuluyor ama ek güvenlik)
        ".class",  # Java compiled files
        ".obj",    # Object files (C++, C# derleme ara)
        ".exe",    # Çalıştırılabilir dosyalar (isteğe bağlı)
        ".dll",    # Kütüphane dosyaları (isteğe bağlı)
        ".pdb"     # Debugging dosyaları (isteğe bağlı)
    )
)

# Hariç tutulacak klasör ve dosya uzantısı isimlerini küçük harfe çevir (case-insensitive karşılaştırma için)
$ExcludeFoldersLower = $ExcludeFolders | ForEach-Object {$_.ToLower()}
$ExcludeFileExtensionsLower = $ExcludeFileExtensions | ForEach-Object {$_.ToLower()}

# --- Recursive Filtered Copy Function ---
# Bu fonksiyon, klasörleri özyinelemeli olarak kopyalar ve belirtilenleri hariç tutar.
# ZIP oluşturmak için geçici bir dizine kopyalama amacıyla kullanılır.
function Copy-FilteredContentRecursive {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string[]]$ExcludeFoldersLower,
        [string[]]$ExcludeFileExtensionsLower
    )

    # Write-Host "Processing: $($SourcePath)" -ForegroundColor DarkGray # Çok fazla çıktı olabilir

    # Hedef klasörü oluştur (varsa zaten var olacaktır)
    if (-not (Test-Path $DestinationPath -PathType Container)) {
        try {
            # Write-Host "Creating directory: $($DestinationPath)" -ForegroundColor Green # Çok fazla çıktı olabilir
            New-Item -Path $DestinationPath -ItemType Directory | Out-Null
        } catch {
            Write-Host "Error creating directory $($DestinationPath): $($_.Exception.Message)" -ForegroundColor Red
            return # Bu yolda devam etme
        }
    }

    # Kaynak klasördeki öğeleri (dosya ve klasörler) al
    $items = Get-ChildItem -Path $SourcePath -Force -ErrorAction SilentlyContinue

    foreach ($item in $items) {
        $sourceItemPath = $item.FullName
        $destinationItemPath = Join-Path -Path $DestinationPath -ChildPath $item.Name

        if ($item.PSIsContainer) {
            # Öğrenin adı hariç tutulanlar listesinde mi kontrol et (küçük harf karşılaştırma)
            if ($ExcludeFoldersLower -contains $item.Name.ToLower()) {
                Write-Host "Skipping excluded folder: $($sourceItemPath)" -ForegroundColor Yellow
            } else {
                # Hariç tutulmayan bir klasör - özyinelemeli olarak kopyalamaya devam et
                Copy-FilteredContentRecursive -SourcePath $sourceItemPath -DestinationPath $destinationItemPath -ExcludeFoldersLower $ExcludeFoldersLower -ExcludeFileExtensionsLower $ExcludeFileExtensionsLower
            }
        } else {
            # Öğren bir dosya

            # Dosya uzantısı hariç tutulanlar listesinde mi kontrol et (küçük harf karşılaştırma)
            $fileExtensionLower = $item.Extension.ToLower()
            if ($ExcludeFileExtensionsLower -contains $fileExtensionLower) {
                 # Write-Host "Skipping excluded file extension: $($sourceItemPath)" -ForegroundColor Yellow # Çok fazla çıktı olabilir
                 continue # Döngüde bir sonraki öğeye geç, bu dosyayı kopyalama
            }

            # Dosya uzantısı hariç tutulanlar listesinde değil, kopyalamaya devam et
            try {
                # Write-Host "Copying file: $($sourceItemPath)" -ForegroundColor Gray # Çok fazla çıktı olabilir
                Copy-Item -Path $sourceItemPath -Destination $destinationItemPath -Force -ErrorAction Stop

            } catch {
                Write-Host "Error copying file $($sourceItemPath): $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# --- Main Script Execution ---

Write-Host "--- Backup Script Starting (Creating ZIP Archives) ---" -ForegroundColor Cyan
Write-Host "Destination Root: $($DestinationRoot)"
Write-Host "Excluded Folders: $($ExcludeFolders -join ', ')"
Write-Host "Excluded File Extensions: $($ExcludeFileExtensions -join ', ')"
Write-Host "---------------------------------------------------`n"

# Hedef kök klasörünü oluştur (varsa zaten var olacaktır)
if (-not (Test-Path $DestinationRoot -PathType Container)) {
    Write-Host "Creating destination root directory: $($DestinationRoot)" -ForegroundColor Green
    try {
        New-Item -Path $DestinationRoot -ItemType Directory | Out-Null
    } catch {
         Write-Host "FATAL ERROR: Could not create destination root directory $($DestinationRoot). Check permissions or path." -ForegroundColor Red
         exit 1
    }
}

# Her bir kaynak kök klasörü için döngüye gir
if ($SourceRoots.Count -eq 0) {
    Write-Host "FATAL ERROR: No source roots specified in the `$SourceRoots` parameter!" -ForegroundColor Red
    exit 1
}

Write-Host "Processing $($SourceRoots.Count) source root(s)...`n" -ForegroundColor Cyan

foreach ($CurrentSourceRoot in $SourceRoots) {
    $TempBackupPath = $null # Geçici yol değişkenini sıfırla
    
    try {
        # Kaynak kök klasörünün varlığını ve klasör olup olmadığını kontrol et
        if (-not (Test-Path $CurrentSourceRoot -PathType Container)) {
            Write-Host "WARNING: Source root directory $($CurrentSourceRoot) not found or is not a directory. Skipping." -ForegroundColor Yellow
            continue # Bu kaynağı atla, bir sonrakine geç
        }

        # Kaynak klasör adını al ve geçici yedekleme yolunu oluştur
        $SourceFolderName = (Get-Item $CurrentSourceRoot).Name
        # Get-TempPath() kullanılırsa genellikle 'C:\Users\...\AppData\Local\Temp\' olur
        $TempBackupPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "BackupTemp_$($SourceFolderName)_$([Guid]::NewGuid().ToString("N"))"
        # GUID eklemek, aynı isimli farklı kaynaklar veya aynı kaynağın ardışık çalıştırılması durumunda çakışmayı önler.

        Write-Host "--- Starting backup for $($CurrentSourceRoot) ---" -ForegroundColor Cyan
        Write-Host "Using temporary path: $($TempBackupPath)" -ForegroundColor DarkGray

        # Geçici yedekleme klasörünü oluştur (olması gereken)
        # Copy-FilteredContentRecursive fonksiyonu da oluşturacak ama emin olmak için burada da yapabiliriz.
        # Bu scriptte recursive fonksiyon zaten oluşturuyor, burası gereksiz.

        # Önceki çalışmalardan kalan aynı isimli temp klasör varsa temizle
        if (Test-Path $TempBackupPath -PathType Container) {
            Write-Host "Cleaning up previous temporary directory: $($TempBackupPath)" -ForegroundColor DarkYellow
            try {
                 Remove-Item -Path $TempBackupPath -Recurse -Force -ErrorAction Stop
            } catch {
                 Write-Host "ERROR: Could not clean up temporary directory $($TempBackupPath): $($_.Exception.Message). Skipping this backup." -ForegroundColor Red
                 continue # Temp klasör silinemezse bu yedeklemeyi atla
            }
        }
        
        # Kaynak içeriğini hariç tutarak geçici klasöre kopyala
        Write-Host "Copying filtered content to temporary location..." -ForegroundColor DarkCyan
        Copy-FilteredContentRecursive -SourcePath $CurrentSourceRoot -DestinationPath $TempBackupPath -ExcludeFoldersLower $ExcludeFoldersLower -ExcludeFileExtensionsLower $ExcludeFileExtensionsLower

        # Geçici klasörün boş olup olmadığını kontrol et (hariç tutulan her şeyse boş olabilir)
        if (-not (Get-ChildItem -Path $TempBackupPath -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -First 1)) {
            Write-Host "Temporary backup path is empty after filtering. No content to archive. Skipping archiving for $($SourceFolderName)." -ForegroundColor Yellow
        } else {
            # Tarih damgasını Türkiye formatında al
            # HH:mm:ss yerine HH-mm-ss kullandık çünkü kolon Windows dosya isimlerinde kullanılamaz.
            # yyyy-MM-dd_HH-mm-ss formatı hem okunur hem de dosya yöneticilerinde doğru sıralanır.
            $Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

            # Hedef ZIP dosya adını ve yolunu oluştur
            $ArchiveFileName = "$($SourceFolderName)_$($Timestamp).zip"
            $ArchiveFilePath = Join-Path -Path $DestinationRoot -ChildPath $ArchiveFileName

            Write-Host "Compressing temporary content to $($ArchiveFilePath)..." -ForegroundColor DarkCyan

            # Geçici klasörün içeriğini ZIP dosyasına sıkıştır
            # -Path "$TempBackupPath\*" : Bu, geçici klasörün KENDİSİNİ değil, İÇERİĞİNİ sıkıştırmak için kullanılır.
            Compress-Archive -Path "$TempBackupPath\*" -DestinationPath $ArchiveFilePath -Force -ErrorAction Stop # Force: Hedef dosya varsa üzerine yaz (aynı timestamp'li dosya olmaz gerçi)

            Write-Host "Successfully created archive: $($ArchiveFilePath)" -ForegroundColor Green
        }

    } catch {
        # Try bloğu içindeki herhangi bir hatayı yakala (geçici klasör silme hariç)
        Write-Host "An error occurred during processing $($CurrentSourceRoot): $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        # Geçici klasörü her zaman temizle (hata olsa bile)
        if (Test-Path $TempBackupPath -PathType Container) {
             Write-Host "Cleaning up temporary directory: $($TempBackupPath)" -ForegroundColor DarkGray
             Remove-Item -Path $TempBackupPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "--- Finished processing $($CurrentSourceRoot) ---`n" -ForegroundColor Cyan
}

Write-Host "--- All Source Roots Processed ---" -ForegroundColor Cyan
Write-Host "--- Backup Script Finished ---" -ForegroundColor Cyan
