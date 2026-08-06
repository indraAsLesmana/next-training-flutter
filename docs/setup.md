# Setup untuk Peserta Training Flutter + Neon

Panduan ini disusun menggunakan standar industri modern dengan memanfaatkan **Package Manager** dan **FVM (Flutter Version Manager)**. 

## Package Manager (Chocolatey / Homebrew)?
Package Manager untuk mengunduh, menginstal, dan mengkonfigurasi semua perangkat lunak secara otomatis.

## Apa itu FVM?
**FVM (Flutter Version Manager)** adalah alat standar industri yang memungkinkan Anda memiliki banyak versi Flutter SDK di satu komputer tanpa saling bentrok.

## Bagian 1: Install Package Manager & Toolchain

::::{tab-set}
:::{tab-item} Windows
Menggunakan **Chocolatey** (Package Manager untuk Windows).

1. Buka **PowerShell** sebagai **Administrator** (Klik kanan Start Menu -> *Terminal (Admin)* atau *Windows PowerShell (Admin)*).
2. Jalankan perintah berikut untuk memasang Chocolatey:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

3. Tutup jendela PowerShell, lalu **buka kembali PowerShell (Admin) baru**.
4. Jalankan perintah satu baris ini untuk menginstal FVM, Git, VS Code, dan Android Studio secara otomatis:

```powershell
choco install fvm git vscode androidstudio -y
```
:::
:::{tab-item} macOS
Menggunakan **Homebrew**.

1. Buka **Terminal**.
2. Jalankan perintah berikut untuk memasang Homebrew:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

3. Tambahkan Homebrew ke shell environment:

```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
eval "$(/opt/homebrew/bin/brew shellenv)"
```

4. Install FVM, Git, CocoaPods, Scrcpy, VS Code, dan Android Studio:

```bash
brew install git cocoapods fvm scrcpy
brew install --cask visual-studio-code android-studio google-chrome
```
:::
::::

## Bagian 2: Install Flutter SDK via FVM

::::{tab-set}
:::{tab-item} Windows
Buka **PowerShell** biasa atau Admin:

```powershell
# 1. Install Flutter SDK Stable via FVM
fvm install stable

# 2. Set versi stable sebagai default global komputer
fvm global stable

# 3. Tambahkan symlink FVM ke User PATH Windows
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$env:USERPROFILE\fvm\default\bin", "User")
```
:::
:::{tab-item} macOS
Buka **Terminal**:

```bash
# 1. Install dan set Flutter Stable
fvm install stable
fvm global stable

# 2. Configure global shell PATH
echo 'export PATH="$HOME/fvm/default/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```
:::
::::

## Bagian 3: Setup Android Studio & SDK Tools

::::{tab-set}
:::{tab-item} Windows
1. Jalankan **Setup Wizard Android Studio**: Setelah instalasi `choco` selesai, buka Android Studio dari Start Menu untuk menjalankan *Standard Setup Wizard* pertama kali.
2. Pasang Command-line Tools:
   - Masuk ke **More Actions** -> **SDK Manager** -> tab **SDK Tools**.
   - Centang **Android SDK Command-line Tools (latest)**, **Android SDK Build-Tools**, dan **Android Emulator**.
   - Klik **Apply** dan tunggu instalasi selesai.
:::
:::{tab-item} macOS
1. Setup Xcode:
   - Pasang Xcode dari App Store.
   - Buka Terminal dan jalankan konfigurasi:
```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
sudo xcodebuild -license accept
```
2. Jalankan **Setup Wizard Android Studio** pertama kali.
3. Buka Android Studio -> **Settings** -> **Languages & Frameworks** -> **Android SDK** -> **SDK Tools**.
4. Pastikan **Android SDK Command-line Tools** tercentang, lalu **Apply**.
:::
::::

## Bagian 4: Konfigurasi VS Code

Tambahkan konfigurasi ini di VS Code agar IDE otomatis mendeteksi SDK Flutter milik FVM dan melakukan *format-on-save*.

1. Buka VS Code.
2. Tekan `Ctrl + Shift + P` (Windows) atau `Cmd + Shift + P` (macOS).
3. Ketik **Preferences: Open User Settings (JSON)** dan pilih.
4. Tambahkan konfigurasi berikut ke dalam file `settings.json`:

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

5. Install VS Code Extensions:
   - **Flutter** (Dart-Code.flutter)
   - **Dart** (Dart-Code.dart-code)

6. Terima Lisensi Android SDK:
   Buka terminal di dalam VS Code (tekan `` Ctrl + ` ``) lalu jalankan:
   ```bash
   fvm flutter doctor --android-licenses
   fvm flutter doctor -v
   ```

7. **(Optional) Mirroring HP Android (Tanpa Emulator)**:
   Untuk mengatasi keterbatasan spek PC/Laptop jika tidak kuat menjalankan Android Emulator:
   - Siapkan HP Android dan kabel data.
   - Aktifkan **USB Debugging** di HP Android.
   - Install **Scrcpy** menggunakan Package Manager:
     - **Windows (PowerShell Admin):** `choco install scrcpy -y`
     - **macOS (Terminal):** `brew install scrcpy`
   - Sambungkan HP ke Laptop, buka terminal lalu ketik `scrcpy` untuk me-mirror layar HP ke PC.

## Bagian 5: Inisialisasi Project

1. **Buat Project Baru:**
   Buka terminal, lalu jalankan perintah berikut untuk membuat project Flutter baru:
   ```bash
   fvm flutter create --org com.flutter_training --platforms android,ios,web flutter_training
   cd flutter_training
   ```

2. **Set Versi Flutter dengan FVM:**
   Kita akan mengunci versi Flutter untuk project ini.
   
   > [!IMPORTANT]
   > **Khusus Pengguna Windows (Developer Mode):** 
   > Agar VS Code dapat membuat *symlink* FVM tanpa harus selalu dijalankan sebagai Administrator, Anda **wajib** mengaktifkan Developer Mode:
   > 1. Tekan `Win + I` untuk membuka **Settings**.
   > 2. Masuk ke **System** -> **For developers** (Windows 11) atau **Update & Security** -> **For developers** (Windows 10).
   > 3. Aktifkan toggle **Developer Mode** dan konfirmasi (*Yes*).
   > 4. Tutup dan buka kembali VS Code.

   Jalankan perintah ini untuk menggunakan versi spesifik:
   ```bash
   fvm use 3.44.8
   ```

3. **Install Dependencies & Verifikasi:**
   ```bash
   # Unduh package yang dibutuhkan
   fvm flutter pub get

   # Pastikan tidak ada error di dalam environment project
   fvm flutter doctor
   ```

## Bagian 6: Testing Aplikasi (Run)

1. **Siapkan Perangkat:**
   - Hubungkan HP Android ke Laptop/PC menggunakan kabel data (pastikan **USB Debugging** aktif).
   - *(Atau jalankan Android Emulator jika spek Laptop memadai).*

2. **Jalankan Aplikasi:**
   Di dalam folder project `flutter_training`, jalankan:
   ```bash
   fvm flutter run 
   ```

### Troubleshooting
- **Flutter doctor errors:** 
  - **Android SDK not found:** Install Android Studio dan setup SDK Tools.
  - **No devices available:** Pastikan kabel data tersambung dengan baik dan USB debugging aktif, atau gunakan `scrcpy` untuk mengecek koneksi.
- **Gradle Build Failed (Java Version Mismatch):**
  - **Masalah:** Jika proses build gagal dengan pesan seperti `FAILURE: Build failed with an exception` atau menyebutkan versi Java (misal `25.0.2`), itu karena Gradle bawaan Flutter belum sepenuhnya mendukung versi Java terbaru di komputer Anda.
  - **Solusi 1 (Menjalankan di Web):** Jalankan aplikasi di browser menggunakan perintah: `fvm flutter run -d web`
  - **Solusi 2 (Menggunakan JDK 17):** Unduh OpenJDK 17 (misalnya dari Eclipse Temurin/Adoptium), lalu konfigurasikan Flutter untuk menggunakan JDK tersebut dengan menjalankan:
    ```bash
    fvm flutter config --jdk-dir=/path/ke/folder/jdk-17
    ```

### Verifikasi Lengkap
- [ ] Toolchain (FVM, Git, VS Code, Android Studio) terinstall via package manager.
- [ ] `flutter doctor` status OK.
- [ ] Project Flutter berhasil di-run ke perangkat/emulator.