<#
.SYNOPSIS
Creates ZIP archives from multiple source folders, excluding specified folders and file extensions.  
For each source folder, produces a separate timestamped ZIP file under the destination folder.

.DESCRIPTION
The script processes each folder listed in -SourceRoots individually.  
It first copies the contents (files and subfolders) of each source folder—omitting any folders or file types you’ve excluded—into a temporary directory.  
Then it compresses that temporary directory’s contents into a ZIP file named using the source folder’s name plus the current date/time under -DestinationRoot.  
Finally, it deletes the temporary folder.

.PARAMETER SourceRoots
An array of paths (strings) for the root folders to back up.  
Each element represents one folder that will be backed up separately.  
Example:  
    @(
      "C:\Users\UserName\Documents\ProjectA",
      "D:\Development\ProjectB"
    )

.PARAMETER DestinationRoot
The path (string) of the folder where the created ZIP archives will be saved.  
This is typically a folder synchronized by a cloud-sync tool (e.g. Google Drive).  
Example:  
    "C:\Users\UserName\MyDrive\ProjectBackupArchives"

.PARAMETER ExcludeFolders
An array of folder names (strings) to exclude from the backup.  
Names are case-insensitive; any matching folder at any level under the source will be skipped.  
Example:  
    @("node_modules", ".venv", "build", "__pycache__", ".git")

.PARAMETER ExcludeFileExtensions
An array of file extensions (strings) to exclude from the backup.  
Extensions must begin with a dot and are case-insensitive; any file matching these extensions will be skipped.  
Example:  
    @(".log", ".tmp", ".bak", ".cache")

.EXAMPLE
    .\Backup-ToZipArchives.ps1
Runs the script with its built-in default values for SourceRoots, DestinationRoot, ExcludeFolders, and ExcludeFileExtensions—creating ZIP archives accordingly.

.EXAMPLE
    .\Backup-ToZipArchives.ps1 `
      -SourceRoots @("C:\MyCode\Proj1","D:\OldProjects\ProjX") `
      -DestinationRoot "E:\GDriveBackup\Archives" `
      -ExcludeFolders @("vendor") `
      -ExcludeFileExtensions @(".log")
Backs up those two specified folders into ZIP archives under the given destination, while excluding any “vendor” folders and “.log” files.

.NOTES
- The script attempts to catch and report errors during copy and compression.  
- Folder names and file extensions are compared case-insensitively.  
- A temporary folder holds the filtered copy before zipping, so you’ll need free disk space equal to the data size.  
- The temporary folder is always removed at the end.  
- ZIP file names include date/time in `yyyy-MM-dd_HH-mm-ss` format to ensure proper sorting and uniqueness.  
#>
param(
    [string[]]$SourceRoots = @(
        "C:\Path\To\Your\Project1",
        "D:\Another\ProjectFolder"
    ),
    [string]$DestinationRoot = "C:\Users\UserName\GoogleDrive\ProjectBackups",
    [string[]]$ExcludeFolders = @(
        "node_modules",
        ".venv",
        "venv",
        "env",
        ".git",
        "dist",
        "build",
        "__pycache__",
        ".vscode",
        ".idea",
        "bin",
        "obj",
        "target",
        "vendor",
        "tmp",
        "temp"
    ),
    [string[]]$ExcludeFileExtensions = @(
        ".log",
        ".tmp",
        ".temp",
        ".bak",
        ".swp",
        ".swo",
        ".cache",
        ".pyc",
        ".class",
        ".obj",
        ".exe",
        ".dll",
        ".pdb"
    )
)

# Convert excludes to lowercase for case-insensitive comparison
$ExcludeFoldersLower        = $ExcludeFolders       | ForEach-Object { $_.ToLower() }
$ExcludeFileExtensionsLower = $ExcludeFileExtensions | ForEach-Object { $_.ToLower() }

function Copy-FilteredContentRecursive {
    param(
        [string]$SourcePath,
        [string]$DestinationPath,
        [string[]]$ExcludeFoldersLower,
        [string[]]$ExcludeFileExtensionsLower
    )

    if (-not (Test-Path $DestinationPath -PathType Container)) {
        try {
            New-Item -Path $DestinationPath -ItemType Directory | Out-Null
        } catch {
            Write-Host "Error creating directory $DestinationPath: $($_.Exception.Message)" -ForegroundColor Red
            return
        }
    }

    $items = Get-ChildItem -Path $SourcePath -Force -ErrorAction SilentlyContinue
    foreach ($item in $items) {
        $src = $item.FullName
        $dst = Join-Path -Path $DestinationPath -ChildPath $item.Name

        if ($item.PSIsContainer) {
            if ($ExcludeFoldersLower -contains $item.Name.ToLower()) {
                Write-Host "Skipping excluded folder: $src" -ForegroundColor Yellow
            } else {
                Copy-FilteredContentRecursive -SourcePath $src -DestinationPath $dst `
                    -ExcludeFoldersLower $ExcludeFoldersLower `
                    -ExcludeFileExtensionsLower $ExcludeFileExtensionsLower
            }
        } else {
            $ext = $item.Extension.ToLower()
            if ($ExcludeFileExtensionsLower -contains $ext) {
                continue
            }
            try {
                Copy-Item -Path $src -Destination $dst -Force -ErrorAction Stop
            } catch {
                Write-Host "Error copying file $src: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

Write-Host "--- Backup Script Starting (Creating ZIP Archives) ---" -ForegroundColor Cyan
Write-Host "Destination Root: $DestinationRoot"
Write-Host "Excluded Folders: $($ExcludeFolders -join ', ')"
Write-Host "Excluded File Extensions: $($ExcludeFileExtensions -join ', ')"
Write-Host "---------------------------------------------------`n"

if (-not (Test-Path $DestinationRoot -PathType Container)) {
    Write-Host "Creating destination root directory: $DestinationRoot" -ForegroundColor Green
    try {
        New-Item -Path $DestinationRoot -ItemType Directory | Out-Null
    } catch {
        Write-Host "FATAL ERROR: Could not create destination root directory. Check permissions or path." -ForegroundColor Red
        exit 1
    }
}

if ($SourceRoots.Count -eq 0) {
    Write-Host "FATAL ERROR: No source roots specified!" -ForegroundColor Red
    exit 1
}

Write-Host "Processing $($SourceRoots.Count) source root(s)...`n" -ForegroundColor Cyan

foreach ($CurrentSourceRoot in $SourceRoots) {
    $TempBackupPath = $null
    try {
        if (-not (Test-Path $CurrentSourceRoot -PathType Container)) {
            Write-Host "WARNING: Source root $CurrentSourceRoot not found. Skipping." -ForegroundColor Yellow
            continue
        }

        $SourceName = (Get-Item $CurrentSourceRoot).Name
        $TempBackupPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) `
            -ChildPath "BackupTemp_${SourceName}_$([Guid]::NewGuid().ToString('N'))"

        Write-Host "--- Backing up $CurrentSourceRoot ---" -ForegroundColor Cyan
        Write-Host "Temp path: $TempBackupPath" -ForegroundColor DarkGray

        if (Test-Path $TempBackupPath -PathType Container) {
            Remove-Item -Path $TempBackupPath -Recurse -Force -ErrorAction Stop
        }

        Copy-FilteredContentRecursive -SourcePath $CurrentSourceRoot -DestinationPath $TempBackupPath `
            -ExcludeFoldersLower $ExcludeFoldersLower `
            -ExcludeFileExtensionsLower $ExcludeFileExtensionsLower

        if (-not (Get-ChildItem -Path $TempBackupPath -Recurse -Force)) {
            Write-Host "No content to archive after filtering. Skipping $SourceName." -ForegroundColor Yellow
        } else {
            $Timestamp       = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
            $ArchiveFileName = "${SourceName}_${Timestamp}.zip"
            $ArchivePath     = Join-Path -Path $DestinationRoot -ChildPath $ArchiveFileName

            Write-Host "Compressing to $ArchivePath..." -ForegroundColor DarkCyan
            Compress-Archive -Path "$TempBackupPath\*" -DestinationPath $ArchivePath -Force -ErrorAction Stop
            Write-Host "Archive created: $ArchivePath" -ForegroundColor Green
        }

    } catch {
        Write-Host "Error processing $CurrentSourceRoot: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        if ($TempBackupPath -and (Test-Path $TempBackupPath -PathType Container)) {
            Write-Host "Cleaning up temp directory: $TempBackupPath" -ForegroundColor DarkGray
            Remove-Item -Path $TempBackupPath -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    Write-Host "--- Finished $CurrentSourceRoot ---`n" -ForegroundColor Cyan
}

Write-Host "--- All Source Roots Processed ---" -ForegroundColor Cyan
Write-Host "--- Backup Script Finished ---" -ForegroundColor Cyan
