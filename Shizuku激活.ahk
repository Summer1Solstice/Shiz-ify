#Requires AutoHotkey v2.0
Persistent
#Include <XZ\RunWait>

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

ADB := EnvGet("USERPROFILE") "\AppData\Local\Android\Sdk\platform-tools\adb.exe"
if not FileExist(ADB) {
    if WhereADB := RunWaitOne("where adb") {
        ADB := RTrim(WhereADB, "`n`r")  ; 因where命令返回结果有换行符，浪费不少时间，特此记录。
        PrintLine("在环境变量中找到ADB：" ADB)
    } else {
        PrintError("ADB not found!")
    }
}
if not InStr(RunWaitOne(ADB " devices"), "device",,24) {
    PrintError("No device connected!")
}
shizuku_pkgName := "moe.shizuku.privileged.api"
shizuku_version := RunWaitOne(ADB ' shell "dumpsys package ' shizuku_pkgName ' |grep versionName"')
PrintLine(Trim(shizuku_version, " `r`n"))
if RegExMatch(shizuku_version, "([\d.]+)", &match) {
    shizuku_version := StrReplace(match[1], ".")
}
if shizuku_version <= 1354 {
    PrintLine("使用 start.sh 激活...")
    result := RunWaitOne(ADB " shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh")
} else if shizuku_version >= 1360 {
    PrintLine("使用 libshizuku.so 激活...")
    shizuku_app_path := RunWaitOne(ADB " shell pm path " shizuku_pkgName)
    if RegExMatch(shizuku_app_path, "\/data\/app\/(.*?)\/base", &match) {
        result := RunWaitOne(ADB " shell /data/app/" match[1] "/lib/x86_64/libshizuku.so")
    }
}
PrintLine(result)
if InStr(result, "shizuku_starter exit with 0") {
    Print("激活成功")
} else {
    Print("激活失败")
}
; PrintLine("`n处理 MacroDroid 权限...")
; MacroDroid:= "
; (
; adb shell pm grant com.arlosoft.macrodroid com.termux.permission.RUN_COMMAND
; adb shell pm grant com.arlosoft.macrodroid android.permission.WRITE_SECURE_SETTINGS
; adb shell pm grant com.arlosoft.macrodroid android.permission.CHANGE_CONFIGURATION
; adb shell pm grant com.arlosoft.macrodroid android.permission.DUMP
; adb shell pm grant com.arlosoft.macrodroid android.permission.SET_VOLUME_KEY_LONG_PRESS_LISTENER
; adb shell pm grant com.arlosoft.macrodroid android.permission.READ_LOGS
; adb shell pm grant com.arlosoft.macrodroid.helper android.permission.WRITE_SECURE_SETTINGS
; )"
; for i in StrSplit(MacroDroid, "`n"){
;     RunWaitOne(i)
;     PrintLine(i)
; }
; PrintLine("end")
Print("`nCTRL+C to exit...")
