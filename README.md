# Shiz-ify
Shiz-ify is a simple batch script that enables Shizuku on any Android device via ADB. It automatically detects connected devices, checks Shizuku authorization, and authorizes it if needed, all in under 5 seconds. Perfect for users who want to streamline the Shizuku setup process.
# Modifications
Added an AHK script that supports retrieving ADB from fixed paths and environment variables.

添加了AHK脚本，支持从固定路径、环境变量获取ADB。

For Shizuku versions below 1360, activation is done using .sh; for versions 1360 and above, activation is done using .so.

shizuku版本1360以下使用.sh激活，1360以上使用.so激活。
# About AutoHotkey
[AHK](https://www.autohotkey.com/)

When the compiler `AutoHotkey.exe` is launched without parameters, it will load the `.ahk` script with the same filename as itself by default. This feature enables the portability of AHK.

编译器`AutoHotkey.exe`无参数启动时默认加载与自己文件名相同的`.ahk`脚本，基于这一特性可以实现AHK的可移植性。

[Portability of AutoHotkey.exe](https://www.autohotkey.com/docs/v2/Program.htm#portability)

[defaultfile](https://www.autohotkey.com/docs/v2/Scripts.htm#defaultfile)

# Features:

1. Automatic Device Detection: The script automatically detects connected Android devices and ensures they're ready for Shizuku.

2. Shizuku Authorization: If Shizuku isn't authorized, the script will handle the authorization process.

3. No Need for Manual Setup: Users don't need to manually handle Shizuku authorization—just run the script and let it do the work!

# Prerequisites:

1. Android Studio installed on your machine.
  
2. USB Debugging enabled on your Android device.

3. Shizuku installed on your Android device.

# Usage:

1. Ensure you have Android Studio installed on your machine.

2. Download the batch from this repository.

3. Run the Shiz-ify.bat file.

The script will check if your device is connected, verify Shizuku authorization, and if necessary, authorize it automatically.

**Unfortunately, Windows Defender might flag the batch file as malicious. This is because it thinks batch files downloaded from the internet may be malicious. However, i ensure you it is 100% safe to use this script.**
# License:
This project is licensed under the MIT License. Feel free to modify and distribute the script as needed!
