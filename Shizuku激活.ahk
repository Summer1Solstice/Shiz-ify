#Requires AutoHotkey v2.0
Persistent

^c:: ExitApp()
;==========TipText========
LOCATED_ADB := "找到 ADB: "
ADB_NOT_FOUND := "未找到 ADB！"
LOCATED_ADB_IN_THE_ENVIRONMENT_VARIABLES := "在环境变量中找到ADB: "
NO_DEVICE_CONNECTED := "无设备连接！"
ACTIVATE_WITH_SH := "使用 start.sh 激活..."
ACTIVATE_WITH_SO := "使用 libshizuku.so 激活..."
ACTIVATION_SUCCESSFUL := "激活成功！"
ACTIVATION_FAILED := "激活失败！"
PROCESSING_MACRODROID_PERMISSIONS := "处理 MacroDroid 权限..."
;=========================
DllCall("AllocConsole") ; 分配控制台窗口
stdin := FileOpen("*", "r")
stdout := FileOpen("*", "w")
Print(text) {
    stdout.Write(text)
    stdout.Read(0) ; 清除写入缓冲区.
}
PrintLine(text) {
    stdout.WriteLine(text)
    stdout.Read(0) ; 清除写入缓冲区.
}
PrintError(text) {
    stdout.Write("[Error] " text)
    stdout.Write("`nCTRL+C to exit...")
    stdout.Read(0) ; 清除写入缓冲区.
    stdin.ReadLine()
}
RunWaitOne(command) {
    shell := ComObject("WScript.Shell")
    exec := shell.Exec(A_ComSpec " /C " command)
    return exec.StdOut.ReadAll()
}
ADB := EnvGet("USERPROFILE") "\AppData\Local\Android\Sdk\platform-tools\adb.exe"
if not FileExist(ADB) {
    if WhereADB := RunWaitOne("where adb") {
        ADB := RTrim(WhereADB, "`n`r")  ; 因where命令返回结果有换行符，排查问题浪费不少时间，特此记录。
        PrintLine(LOCATED_ADB_IN_THE_ENVIRONMENT_VARIABLES "`n`t" ADB)
    } else {
        PrintError(ADB_NOT_FOUND)
        Exit()
    }
} else {
    PrintLine(LOCATED_ADB "`n`t" ADB)
}
if not InStr(RunWaitOne(ADB " devices"), "device", , 24) {
    PrintError(NO_DEVICE_CONNECTED)
    Exit()
}
TCP := RunWaitOne(ADB " tcpip 5555")
if InStr(TCP, "restarting in TCP mode port: 5555") {
    PrintLine(RTrim(TCP, "`r`n"))
    loop 10 {
        Sleep 1000
        if InStr(RunWaitOne(ADB " devices"), "device", , 24) {
            break
        }
    }
}
shizuku_pkgName := "moe.shizuku.privileged.api"
shizuku_version := RunWaitOne(ADB ' shell "dumpsys package ' shizuku_pkgName ' |grep versionName"')
PrintLine(Trim(shizuku_version, " `r`n"))
if RegExMatch(shizuku_version, "([\d.]+)", &match) {
    shizuku_version := StrReplace(match[1], ".")
}
if shizuku_version <= 1354 {
    PrintLine(ACTIVATE_WITH_SH)
    result := RunWaitOne(ADB " shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh")
} else if shizuku_version >= 1360 {
    PrintLine(ACTIVATE_WITH_SO)
    shizuku_app_path := RunWaitOne(ADB " shell pm path " shizuku_pkgName)
    if RegExMatch(shizuku_app_path, "\/data\/app\/(.*?)\/base", &match) {
        result := RunWaitOne(ADB " shell /data/app/" match[1] "/lib/x86_64/libshizuku.so")
    }
}
PrintLine(result)
if InStr(result, "shizuku_starter exit with 0") {
    PrintLine(ACTIVATION_SUCCESSFUL)
} else {
    PrintLine(ACTIVATION_FAILED)
    Exit()
}
PrintLine(PROCESSING_MACRODROID_PERMISSIONS)
MacroDroid := "
(
    adb shell pm grant com.arlosoft.macrodroid com.termux.permission.RUN_COMMAND
    adb shell pm grant com.arlosoft.macrodroid android.permission.WRITE_SECURE_SETTINGS
    adb shell pm grant com.arlosoft.macrodroid android.permission.CHANGE_CONFIGURATION
    adb shell pm grant com.arlosoft.macrodroid android.permission.DUMP
    adb shell pm grant com.arlosoft.macrodroid android.permission.SET_VOLUME_KEY_LONG_PRESS_LISTENER
    adb shell pm grant com.arlosoft.macrodroid android.permission.READ_LOGS
    adb shell pm grant com.arlosoft.macrodroid.helper android.permission.WRITE_SECURE_SETTINGS
)"
for i in StrSplit(MacroDroid, "`n") {
    RunWaitOne(i)
    PrintLine(i)
}
PrintLine("end")
Print("`nCTRL+C to exit...")
