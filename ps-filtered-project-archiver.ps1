<#
.SYNOPSIS
Birden fazla kaynak klasöründeki dosyalarý ve alt klasörleri, belirtilen klasörleri ve dosya uzantýlarýný hariç tutarak ZIP arþivleri oluþturur.
Her kaynak klasör için, hedef klasör altýnda tarih damgalý ayrý bir ZIP dosyasý oluþturulur.

.DESCRIPTION
Script, SourceRoots olarak belirtilen her bir klasörü ayrý ayrý iþler.
Her kaynak klasörün içeriði (dosya ve alt klasörler), önce belirtilen klasörler ve dosya uzantýlarý hariç tutularak geçici bir klasöre kopyalanýr.
Daha sonra bu geçici klasörün içeriði, DestinationRoot altýnda kaynak klasörün adý ve güncel tarih/saat ile isimlendirilmiþ bir ZIP dosyasýna sýkýþtýrýlýr.
Sýkýþtýrma tamamlandýktan sonra geçici klasör silinir.

.PARAMETER SourceRoots
Yedeklenecek ana klasörlerin yollarýný içeren bir string dizisi.
Her bir eleman, baðýmsýz olarak yedeklenecek bir klasörü temsil eder.
Örn: @("C:\Users\KullaniciAdi\Documents\ProjeA", "D:\Development\ProjeB")

.PARAMETER DestinationRoot
Oluþturulan ZIP arþivlerinin kaydedileceði hedef klasörün yolu.
Bu klasör genellikle Google Drive veya benzeri bir senkronizasyon aracýnýn
takip ettiði bir klasör içinde olmalýdýr.
Örn: "C:\Users\KullaniciAdi\Drive'ým\ProjelerYedegiArsiv"

.PARAMETER ExcludeFolders
Yedekleme sýrasýnda hariç tutulacak klasör isimlerini içeren bir string dizisi.
Bu isimler büyük/küçük harfe duyarlý deðildir. Bu klasörler, SourceRoots altýndaki
herhangi bir seviyede bulunduðunda kopyalanmayacaktýr.
Örn: @("node_modules", ".venv", "build", "__pycache__", ".git")

.PARAMETER ExcludeFileExtensions
Yedekleme sýrasýnda hariç tutulacak dosya uzantýlarýný içeren bir string dizisi.
Uzantýlar nokta (.) ile baþlamalýdýr. Büyük/küçük harfe duyarlý deðildir.
Bu uzantýlara sahip dosyalar kopyalanmayacaktýr.
Örn: @(".log", ".tmp", ".bak", ".cache")

.EXAMPLE
.\Backup-ToZipArchives.ps1
Bu, scriptin içinde tanýmlanan varsayýlan SourceRoots, DestinationRoot, ExcludeFolders
ve ExcludeFileExtensions deðerlerini kullanarak yedeklemeyi baþlatýr ve ZIP dosyalarý oluþturur.

.EXAMPLE
.\Backup-ToZipArchives.ps1 -SourceRoots @("C:\MyCode\Proj1", "D:\OldProjects\ProjX") -DestinationRoot "E:\GDriveBackup\Archives" -ExcludeFolders @("vendor") -ExcludeFileExtensions @(".log")
Belirtilen iki klasörü, farklý hariç tutmalarla ZIP arþivlerine yedekler.

.NOTES
Script, kopyalama ve sýkýþtýrma sýrasýnda hatalarý yakalamaya çalýþýr.
Klasör ve dosya uzantýsý isimleri case-insensitive olarak karþýlaþtýrýlýr.
Sýkýþtýrma iþlemi geçici bir klasör kullanýr, bu da ek disk alaný gerektirebilir
(geçici olarak yedeklenecek verinin ham boyutu kadar).
Geçici klasör iþlem sonrasý otomatik olarak silinir.
ZIP dosya isimleri YYYY-MM-DD_HH-mm-ss formatýnda tarih/saat bilgisi içerir.
#>
param(
    [string[]]$SourceRoots = @(
        "C:\Yol\To\Your\Project1",   # <-- Yedeklenecek 1. proje klasörü
        "D:\Another\ProjectFolder"   # <-- Yedeklenecek 2. proje klasörü
        # Virgülle ayýrarak istediðiniz kadar klasör ekleyebilirsiniz
    ),
    [string]$DestinationRoot = "C:\Users\KullaniciAdi\GoogleDriveKlasorunuz\ProjectBackups",  # <-- ZIP dosyalarýnýn kaydedileceði klasör
    [string[]]$ExcludeFolders = @(
        "node_modules", # JavaScript/Node.js baðýmlýlýklarý
        ".venv",        # Python Sanal Ortam (venv)
        "venv",         # Python Sanal Ortam (venv)
        "env",          # Python Sanal Ortam (yaygýn isimler)
        ".git",         # Git versiyon kontrol klasörü (yedeklemeye genellikle gerek yok)
        "dist",         # Build çýktýlarý (örn: webpack, parcel)
        "build",        # Build çýktýlarý (örn: make, setup.py)
        "__pycache__",  # Python cache dosyalarý
        ".vscode",      # VS Code ayar klasörleri (isteðe baðlý, dahil etmek isterseniz silin)
        ".idea",        # JetBrains IDE ayar klasörleri (isteðe baðlý)
        "bin",          # Derlenmiþ çýktýlar (örn: .NET, Java)
        "obj",          # Derleme ara dosyalarý (.NET)
        "target",       # Build çýktýlarý (örn: Rust, Maven)
        "Vendor",       # Composer baðýmlýlýklarý (PHP)
        "tmp",          # Geçici dosyalar
        "temp"          # Geçici dosyalar
    ),
    [string[]]$ExcludeFileExtensions = @(
        ".log",    # Log dosyalarý
        ".tmp",    # Geçici dosyalar
        ".temp",   # Geçici dosyalar
        ".bak",    # Yedek dosyalar (genellikle)
        ".swp",    # Swap dosyalarý (Vim gibi editörler)
        ".swo",    # Swap dosyalarý (Vim gibi editörler)
        ".cache",  # Cache dosyalarý
        ".pyc",    # Python compiled files (__pycache__ zaten hariç tutuluyor ama ek güvenlik)
        ".class",  # Java compiled files
        ".obj",    # Object files (C++, C# derleme ara)
        ".exe",    # Çalýþtýrýlabilir dosyalar (isteðe baðlý)
        ".dll",    # Kütüphane dosyalarý (isteðe baðlý)
        ".pdb"     # Debugging dosyalarý (isteðe baðlý)
    )
)

# Hariç tutulacak klasör ve dosya uzantýsý isimlerini küçük harfe çevir (case-insensitive karþýlaþtýrma için)
$ExcludeFoldersLower = $ExcludeFolders | ForEach-Object {$_.ToLower()}
$ExcludeFileExtensionsLower = $ExcludeFileExtensions | ForEach-Object {$_.ToLower()}

# --- Recursive Filtered Copy Function ---
# Bu fonksiyon, klasörleri özyinelemeli olarak kopyalar ve belirtilenleri hariç tutar.
# ZIP oluþturmak için geçici bir dizine kopyalama amacýyla kullanýlýr.
function Copy-FilteredContentRecursive {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string[]]$ExcludeFoldersLower,
        [string[]]$ExcludeFileExtensionsLower
    )

    # Write-Host "Processing: $($SourcePath)" -ForegroundColor DarkGray # Çok fazla çýktý olabilir

    # Hedef klasörü oluþtur (varsa zaten var olacaktýr)
    if (-not (Test-Path $DestinationPath -PathType Container)) {
        try {
            # Write-Host "Creating directory: $($DestinationPath)" -ForegroundColor Green # Çok fazla çýktý olabilir
            New-Item -Path $DestinationPath -ItemType Directory | Out-Null
        } catch {
            Write-Host "Error creating directory $($DestinationPath): $($_.Exception.Message)" -ForegroundColor Red
            return # Bu yolda devam etme
        }
    }

    # Kaynak klasördeki öðeleri (dosya ve klasörler) al
    $items = Get-ChildItem -Path $SourcePath -Force -ErrorAction SilentlyContinue

    foreach ($item in $items) {
        $sourceItemPath = $item.FullName
        $destinationItemPath = Join-Path -Path $DestinationPath -ChildPath $item.Name

        if ($item.PSIsContainer) {
            # Öðrenin adý hariç tutulanlar listesinde mi kontrol et (küçük harf karþýlaþtýrma)
            if ($ExcludeFoldersLower -contains $item.Name.ToLower()) {
                Write-Host "Skipping excluded folder: $($sourceItemPath)" -ForegroundColor Yellow
            } else {
                # Hariç tutulmayan bir klasör - özyinelemeli olarak kopyalamaya devam et
                Copy-FilteredContentRecursive -SourcePath $sourceItemPath -DestinationPath $destinationItemPath -ExcludeFoldersLower $ExcludeFoldersLower -ExcludeFileExtensionsLower $ExcludeFileExtensionsLower
            }
        } else {
            # Öðren bir dosya

            # Dosya uzantýsý hariç tutulanlar listesinde mi kontrol et (küçük harf karþýlaþtýrma)
            $fileExtensionLower = $item.Extension.ToLower()
            if ($ExcludeFileExtensionsLower -contains $fileExtensionLower) {
                 # Write-Host "Skipping excluded file extension: $($sourceItemPath)" -ForegroundColor Yellow # Çok fazla çýktý olabilir
                 continue # Döngüde bir sonraki öðeye geç, bu dosyayý kopyalama
            }

            # Dosya uzantýsý hariç tutulanlar listesinde deðil, kopyalamaya devam et
            try {
                # Write-Host "Copying file: $($sourceItemPath)" -ForegroundColor Gray # Çok fazla çýktý olabilir
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

# Hedef kök klasörünü oluþtur (varsa zaten var olacaktýr)
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
    $TempBackupPath = $null # Geçici yol deðiþkenini sýfýrla
    
    try {
        # Kaynak kök klasörünün varlýðýný ve klasör olup olmadýðýný kontrol et
        if (-not (Test-Path $CurrentSourceRoot -PathType Container)) {
            Write-Host "WARNING: Source root directory $($CurrentSourceRoot) not found or is not a directory. Skipping." -ForegroundColor Yellow
            continue # Bu kaynaðý atla, bir sonrakine geç
        }

        # Kaynak klasör adýný al ve geçici yedekleme yolunu oluþtur
        $SourceFolderName = (Get-Item $CurrentSourceRoot).Name
        # Get-TempPath() kullanýlýrsa genellikle 'C:\Users\...\AppData\Local\Temp\' olur
        $TempBackupPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath "BackupTemp_$($SourceFolderName)_$([Guid]::NewGuid().ToString("N"))"
        # GUID eklemek, ayný isimli farklý kaynaklar veya ayný kaynaðýn ardýþýk çalýþtýrýlmasý durumunda çakýþmayý önler.

        Write-Host "--- Starting backup for $($CurrentSourceRoot) ---" -ForegroundColor Cyan
        Write-Host "Using temporary path: $($TempBackupPath)" -ForegroundColor DarkGray

        # Geçici yedekleme klasörünü oluþtur (olmasý gereken)
        # Copy-FilteredContentRecursive fonksiyonu da oluþturacak ama emin olmak için burada da yapabiliriz.
        # Bu scriptte recursive fonksiyon zaten oluþturuyor, burasý gereksiz.

        # Önceki çalýþmalardan kalan ayný isimli temp klasör varsa temizle
        if (Test-Path $TempBackupPath -PathType Container) {
            Write-Host "Cleaning up previous temporary directory: $($TempBackupPath)" -ForegroundColor DarkYellow
            try {
                 Remove-Item -Path $TempBackupPath -Recurse -Force -ErrorAction Stop
            } catch {
                 Write-Host "ERROR: Could not clean up temporary directory $($TempBackupPath): $($_.Exception.Message). Skipping this backup." -ForegroundColor Red
                 continue # Temp klasör silinemezse bu yedeklemeyi atla
            }
        }
        
        # Kaynak içeriðini hariç tutarak geçici klasöre kopyala
        Write-Host "Copying filtered content to temporary location..." -ForegroundColor DarkCyan
        Copy-FilteredContentRecursive -SourcePath $CurrentSourceRoot -DestinationPath $TempBackupPath -ExcludeFoldersLower $ExcludeFoldersLower -ExcludeFileExtensionsLower $ExcludeFileExtensionsLower

        # Geçici klasörün boþ olup olmadýðýný kontrol et (hariç tutulan her þeyse boþ olabilir)
        if (-not (Get-ChildItem -Path $TempBackupPath -Recurse -Force -ErrorAction SilentlyContinue | Select-Object -First 1)) {
            Write-Host "Temporary backup path is empty after filtering. No content to archive. Skipping archiving for $($SourceFolderName)." -ForegroundColor Yellow
        } else {
            # Tarih damgasýný Türkiye formatýnda al
            # HH:mm:ss yerine HH-mm-ss kullandýk çünkü kolon Windows dosya isimlerinde kullanýlamaz.
            # yyyy-MM-dd_HH-mm-ss formatý hem okunur hem de dosya yöneticilerinde doðru sýralanýr.
            $Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

            # Hedef ZIP dosya adýný ve yolunu oluþtur
            $ArchiveFileName = "$($SourceFolderName)_$($Timestamp).zip"
            $ArchiveFilePath = Join-Path -Path $DestinationRoot -ChildPath $ArchiveFileName

            Write-Host "Compressing temporary content to $($ArchiveFilePath)..." -ForegroundColor DarkCyan

            # Geçici klasörün içeriðini ZIP dosyasýna sýkýþtýr
            # -Path "$TempBackupPath\*" : Bu, geçici klasörün KENDÝSÝNÝ deðil, ÝÇERÝÐÝNÝ sýkýþtýrmak için kullanýlýr.
            Compress-Archive -Path "$TempBackupPath\*" -DestinationPath $ArchiveFilePath -Force -ErrorAction Stop # Force: Hedef dosya varsa üzerine yaz (ayný timestamp'li dosya olmaz gerçi)

            Write-Host "Successfully created archive: $($ArchiveFilePath)" -ForegroundColor Green
        }

    } catch {
        # Try bloðu içindeki herhangi bir hatayý yakala (geçici klasör silme hariç)
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