#Requires AutoHotkey v2.0
Persistent

;==========TipText========
located_ADB := "找到 ADB: "
ADB_not_found := "未找到 ADB！"
Located_ADB_in_the_environment_variables := "在环境变量中找到ADB: "
No_device_connected := "无设备连接！"
Activate_with_sh := "使用 start.sh 激活..."
Activate_with_so := "使用 libshizuku.so 激活..."
Activation_Successful := "激活成功！"
Activation_Failed := "激活失败！"
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
        PrintLine(Located_ADB_in_the_environment_variables "`n`t" ADB)
    } else {
        PrintError(ADB_not_found)
        Exit()
    }
} else {
    PrintLine(located_ADB "`n`t" ADB)
}
if not InStr(RunWaitOne(ADB " devices"), "device", , 24) {
    PrintError(No_device_connected)
    Exit()
}
shizuku_pkgName := "moe.shizuku.privileged.api"
shizuku_version := RunWaitOne(ADB ' shell "dumpsys package ' shizuku_pkgName ' |grep versionName"')
PrintLine(Trim(shizuku_version, " `r`n"))
if RegExMatch(shizuku_version, "([\d.]+)", &match) {
    shizuku_version := StrReplace(match[1], ".")
}
if shizuku_version <= 1354 {
    PrintLine(Activate_with_sh)
    result := RunWaitOne(ADB " shell sh /storage/emulated/0/Android/data/moe.shizuku.privileged.api/start.sh")
} else if shizuku_version >= 1360 {
    PrintLine(Activate_with_so)
    shizuku_app_path := RunWaitOne(ADB " shell pm path " shizuku_pkgName)
    if RegExMatch(shizuku_app_path, "\/data\/app\/(.*?)\/base", &match) {
        result := RunWaitOne(ADB " shell /data/app/" match[1] "/lib/x86_64/libshizuku.so")
    }
}
PrintLine(result)
if InStr(result, "shizuku_starter exit with 0") {
    PrintLine(Activation_Successful)
} else {
    PrintLine(Activation_Failed)
    Exit()
}
PrintLine("end")
Print("`nCTRL+C to exit...")