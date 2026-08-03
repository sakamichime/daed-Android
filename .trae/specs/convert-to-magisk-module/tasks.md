# Tasks

- [x] Task 1: 创建 Magisk 模块骨架与元数据文件
  - [x] SubTask 1.1: 新建 `android/magisk/module.prop`，填写 id/name/version/versionCode/author/description
  - [x] SubTask 1.2: 新建 `android/magisk/.gitignore`，忽略构建产物（daed 二进制、web 资源、最终 zip）
  - [x] SubTask 1.3: 新建 `android/magisk/customize.sh`，实现安装时权限设置与文件落位提示

- [x] Task 2: 实现开机自启与生命周期脚本
  - [x] SubTask 2.1: 新建 `android/magisk/service.sh`，在 `late_start service` 阶段拉起 `daed run -c /data/adb/daed`，包含进程重复启动保护
  - [x] SubTask 2.2: 新建 `android/magisk/post-fs-data.sh`，创建 `/data/adb/daed` 配置目录（若不存在）
  - [x] SubTask 2.3: 新建 `android/magisk/uninstall.sh`，停止 daed 进程并提示保留配置

- [x] Task 3: 实现快捷跳转配置地址能力
  - [x] SubTask 3.1: 新建 `android/magisk/system/bin/daed-open` 脚本，通过 `am start -a android.intent.action.VIEW -d http://127.0.0.1:2023` 打开浏览器
  - [x] SubTask 3.2: 新建 `android/magisk/shortcut.json`，包含 name/url/description 字段，供桌面快捷方式工具读取

- [x] Task 4: 编写模块说明文档
  - [x] SubTask 4.1: 新建 `android/magisk/README.md`，描述安装、启动、卸载、快捷跳转使用方式与注意事项

- [x] Task 5: 扩展构建系统支持 Magisk 打包
  - [x] SubTask 5.1: 在 `Makefile` 新增 `magisk` 目标：拷贝 Android arm64 二进制与 `apps/web/dist` 到模块目录
  - [x] SubTask 5.2: 在 `Makefile` 新增 `magisk-zip` 目标：将 `android/magisk/` 打包为 `daed-magisk-$(VERSION).zip`（`module.prop` 位于 zip 根）

- [x] Task 6: 修改友好文件名映射
  - [x] SubTask 6.1: 在 `install/friendly-filenames.json` 新增 `android-arm64` 条目，friendlyName 为 `android-arm64`

- [x] Task 7: 更新项目根 README 介绍
  - [x] SubTask 7.1: 在根 `README.md` 特性列表/部署章节加入「Android Magisk 模块」入口，链接到 `android/magisk/README.md`
  - [x] SubTask 7.2: 更新适用平台描述，体现已支持 Android

# Task Dependencies

- Task 2 依赖 Task 1（脚本依赖模块骨架存在）
- Task 3 依赖 Task 1（system/bin 目录在骨架内）
- Task 5 依赖 Task 1、Task 2、Task 3（打包需要所有模块文件就绪）
- Task 7 可与 Task 4 并行
