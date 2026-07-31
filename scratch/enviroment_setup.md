no give me modern guide using fvm instead download the sdk zip folder. is windows using cholate as i remember?

---

Berikut adalah versi revisi modern dari panduan setup environment Flutter menggunakan **FVM (Flutter Version Manager)**.

Pada Windows, kita menggunakan **Chocolatey** (`choco`) sebagai *package manager* (setara dengan Homebrew di macOS), sehingga peserta **tidak perlu mengunduh file `.zip` manual, mengekstraknya, atau mengatur `Path` variabel Windows secara manual**.

---

# 📚 Panduan Environment Setup Flutter Modern (FVM & Package Manager)

Panduan ini disusun menggunakan standar industri modern (**FVM + Package Manager**) untuk mempermudah instruktur dan guru SMK.

---

## 🛠️ Bagian 1: Panduan Windows (PC Lab / Peserta SMK)

Menggunakan **Chocolatey** (Package Manager untuk Windows) dan **FVM** untuk menginstal seluruh perkakas tanpa perlu *download* zip manual.

### Langkah 1: Pasang Chocolatey (Package Manager)

1. Buka **PowerShell** sebagai **Administrator** (Klik kanan Start Menu $\rightarrow$ *Terminal (Admin)* atau *Windows PowerShell (Admin)*).
2. Jalankan perintah berikut untuk memasang Chocolatey:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

```

3. Tutup jendela PowerShell, lalu **buka kembali PowerShell (Admin) baru**.

### Langkah 2: Pasang FVM & Toolchain via Chocolatey

Jalankan perintah satu baris ini untuk menginstal FVM, Git, dan VS Code secara otomatis:

```powershell
choco install fvm git vscode -y

```

### Langkah 3: Install & Set Flutter SDK via FVM

Masih di PowerShell (atau Command Prompt baru):

```powershell
# 1. Install Flutter SDK Stable via FVM
fvm install stable

# 2. Set versi stable sebagai default global komputer
fvm global stable

# 3. Tambahkan symlink FVM ke User PATH Windows
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\fvm\default\bin", "User")

```

### Langkah 4: Setup Android Studio & SDK Tools

1. Unduh dan jalankan installer **Android Studio**.
2. Buka Android Studio $\rightarrow$ **SDK Manager** $\rightarrow$ tab **SDK Tools**.
3. Centang **Android SDK Command-line Tools (latest)**, **Android SDK Build-Tools**, dan **Android Emulator**. Klik **Apply**.
4. Buka PowerShell baru dan terima lisensi Android:
```powershell
flutter doctor --android-licenses
flutter doctor -v

```



---

## 🍎 Bagian 2: Panduan macOS (Laptop Instruktur / Mac)

Menggunakan **Homebrew** dan **FVM** untuk manajemen SDK yang bersih.

### Langkah 1: Pasang Homebrew & Toolchain Core

Buka Terminal macOS:

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Tambahkan Homebrew ke shell environment
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install FVM, Git, CocoaPods, dan Scrcpy via Homebrew
brew install git cocoapods fvm scrcpy

```

### Langkah 2: Install Flutter SDK via FVM

```bash
# Install dan set Flutter Stable
fvm install stable
fvm global stable

# Configure global shell PATH
echo 'export PATH="$HOME/fvm/default/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

```

### Langkah 3: Setup Xcode & Android Studio

1. Pasang **Xcode** dari App Store dan jalankan konfigurasi:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept

```


2. Pasang Android Studio & Chrome via Cask:
```bash
brew install --cask android-studio google-chrome

```


3. Buka Android Studio $\rightarrow$ **Settings** $\rightarrow$ **Languages & Frameworks** $\rightarrow$ **Android SDK** $\rightarrow$ **SDK Tools**, pastikan **Android SDK Command-line Tools** tercentang.
4. Verifikasi instalasi:
```bash
flutter doctor --android-licenses
flutter doctor -v

```



---

## ⚡ Bagian 3: Strategi Khusus Lab Komputer SMK (Offline Kit)

Untuk mengatasi keterbatasan spek PC lab & koneksi internet di sekolah:

1. **HP Fisik + Scrcpy (Tanpa Android Emulator):**
* Minta guru/siswa membawa HP Android dan kabel data.
* Aktifkan **USB Debugging** di HP Android.
* Jalankan `scrcpy` dari terminal (Windows/Mac) untuk me-mirror layar HP ke PC secara sangat ringan tanpa membebani RAM PC.


2. **Flashdisk Master Kit (32 GB):**
* Isi Flashdisk dengan:
* `Chocolatey` installer script
* `Android Studio` offline installer
* `VS Code` offline installer
* Folder cache `.fvm/versions/stable` yang sudah terunduh (peserta cukup `copy-paste` ke folder `C:\Users\Username\fvm\versions\` jika internet di sekolah sangat lambat).





---

## 📝 Konfigurasi `settings.json` VS Code / Antigravity IDE

Tambahkan konfigurasi ini di VS Code agar IDE otomatis mendeteksi SDK Flutter milik FVM dan melakukan *format-on-save*:

```json
{
  "workbench.settings.applyToAllProfiles": [],

  // Auto-detect Flutter dari FVM
  "dart.flutterSdkPaths": ["fvm/versions"],

  // Automation & Linting
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit",
    "source.organizeImports": "explicit"
  },

  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code",
    "editor.formatOnSave": true
  }
}

```

is choco also support  install android studio?

---

**Ya, benar sekali.** Chocolatey (`choco`) mendukung instalasi Android Studio secara penuh di Windows.

### Perintah Instalasi

Buka **PowerShell (Admin)** atau **Command Prompt (Admin)**, lalu jalankan:

```powershell
choco install androidstudio -y

```

---

### Cara Menginstal Seluruh Toolchain Flutter Sekaligus

Agar lebih praktis saat menyiapkan PC di lab sekolah, Anda dapat menggabungkan semua alat pengembangan dalam satu baris perintah Chocolatey:

```powershell
choco install fvm git vscode androidstudio -y

```

---

### Hal Penting Setelah Instalasi via Chocolatey

1. **Jalankan Setup Wizard Android Studio:**
Setelah proses instalasi `choco` selesai, buka Android Studio dari Start Menu Windows untuk menjalankan *Standard Setup Wizard* pertama kali.


2. **Pasang Command-line Tools (Wajib untuk Flutter):**
* Masuk ke **More Actions** $\rightarrow$ **SDK Manager** $\rightarrow$ tab **SDK Tools**.


* Centang **Android SDK Command-line Tools (latest)**, **Android SDK Build-Tools**, dan **Android Emulator**.


* Klik **Apply**.




3. **Terima Lisensi SDK di PowerShell Baru:**
```powershell
flutter doctor --android-licenses

```



---

### Menerima Update Android Studio via Chocolatey

Sama seperti Homebrew Cask di macOS (`brew upgrade`) , Chocolatey juga mendukung pembaruan versi Android Studio di kemudian hari:

```powershell
# Cek daftar aplikasi yang memiliki update
choco outdated

# Perbarui Android Studio ke versi terbaru
choco upgrade androidstudio -y

# Atau perbarui seluruh paket aplikasi di komputer sekaligus
choco upgrade all -y

```