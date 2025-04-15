### 🎯 RetroLauncher CLI

A command-line tool to patch the Habbo Shockwave projector related files (`.exe`, `.dir`). 

How it works is that it replaces the bytes of the executable itself with obfuscated values that setup the client. This allows people to easily create their own Shockwave projector for their Habbo private servers.

During its usage you'll see it creates a file called offsets.ini - this is so any subsequent patching will be faster, as it doesn't have to search for the offsets to replace the bytes at.

**Note**: The RetroLauncher.CLI program gets detected as a false positve as "Trojan:Win32/Wacatac.C!ml" by Windows Defender.

---

### 📂 Download

You can download the latest releases at: https://github.com/Quackster/RetroLauncher/releases/tag/v0.1.0 

#### 🛠 Requirements

- [.NET 6](https://dotnet.microsoft.com/en-us/download/dotnet/6.0) or later installed
- Your `.exe` file in the same directory as the CLI

---

### 💻 Projector Source

You can find the projector Director project under the /RetroLauncher.Projector/ folder.

It requires [Director MX 2004](https://archive.org/details/director_mx_2004) to open projector.dir.

All changes to the classes inside the .dir are avaliable inside /RetroLauncher.Projector/scripts/

---

### 🚀 Usage

```bash
RetroLauncher.CLI.exe <projector file1> [--key=value ...]
```

### 🔧 Supported Command-Line Flags

You can override default values using the following flags:

| Flag         | Description                 | Default                                              |
|--------------|-----------------------------|------------------------------------------------------|
| `--infoHost` | Connection info host        | `localhost`                                          |
| `--musHost`  | Connection MUS host         | `localhost`                                          |
| `--infoPort` | Connection info port        | `12321`                                              |
| `--musPort`  | Connection MUS port         | `12322`                                              |
| `--varsUrl`  | External variables URL      | `http://localhost/v31/external_vars.txt?`            |
| `--textsUrl` | External texts URL          | `http://localhost/v31/external_texts.txt?`           |
| `--movieUrl` | Movie path (DCR)            | `http://localhost/v31/habbo.dcr?`                    |
| `--sso`      | Enable SSO login (true/false) | `false`                                           |
| `--ssoPath`  | SSO login path URL	         | http://localhost/api/login
| `--width`    | Startup display width	 | 960 (if non-widescreen then supply 720)
| `--height`   | Startup display height	 | 540

---

## 💡 Example

```bash
RetroLauncher.CLI.exe projector.exe --infoHost=192.168.0.5 --infoPort=3000 --sso=true --ssoPath=http://localhost/api/login
```

This command will:
- Patch the projector into a new output file: `new_projector.exe`
- Override the connection host and port
- Enable SSO login
- Tell the projector to make a request to ``http://localhost/api/login`` with ``username`` and ``password`` as GET parameters.

The /api/login is now available on Havana v1.3 and later.

---

## 📁 Output

- New patched files will be created with the prefix `new_`
- The script used for patching is internally defined and automatically adjusted based on your inputs
- Rename either **config_sso.ini** or **config_no_sso.ini** to config.ini depending if you have SSO installed or not!
