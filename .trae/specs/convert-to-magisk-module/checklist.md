# Checklist

- [x] `android/magisk/module.prop` 存在且包含 id/name/version/versionCode/author/description 六个字段，id 为 `daed`
- [x] `android/magisk/.gitignore` 忽略 `daed` 二进制、`web/` 目录与最终 `*.zip` 产物
- [x] `android/magisk/customize.sh` 为 `daed` 与 `daed-open` 设置可执行权限 (0755)
- [x] `android/magisk/service.sh` 在 `late_start service` 阶段以 root 后台方式启动 `daed run -c /data/adb/daed`
- [x] `android/magisk/service.sh` 包含重复启动保护逻辑（pgrep/pidof 检测）
- [x] `android/magisk/post-fs-data.sh` 创建 `/data/adb/daed` 配置目录
- [x] `android/magisk/uninstall.sh` 终止 `daed` 进程
- [x] `android/magisk/system/bin/daed-open` 调用 `am start -a android.intent.action.VIEW -d http://127.0.0.1:2023`
- [x] `android/magisk/system/bin/daed-open` 文件具备可执行权限声明（shebang + 模式说明在 customize.sh 中设置）
- [x] `android/magisk/shortcut.json` 包含 name/url/description 三个字段
- [x] `android/magisk/README.md` 涵盖安装、开机自启、快捷跳转、卸载、注意事项五个章节
- [x] `Makefile` 新增 `magisk` 目标，可拷贝 Android arm64 二进制与 Web 资源到模块目录
- [x] `Makefile` 新增 `magisk-zip` 目标，生成的 zip 内 `module.prop` 位于根目录
- [x] `install/friendly-filenames.json` 包含 `android-arm64` 条目，friendlyName 为 `android-arm64`
- [x] 根 `README.md` 在显著位置提及 Android Magisk 模块并链接到 `android/magisk/README.md`
- [x] 根 `README.md` 的适用平台描述已更新，体现支持 Android
- [x] 所有新增 shell 脚本使用 `#!/system/bin/sh` shebang（Magisk 环境）
- [x] 所有新增脚本不含硬编码绝对路径二进制位置错误（统一使用 `$MODPATH` 与 `/data/adb/daed`）
