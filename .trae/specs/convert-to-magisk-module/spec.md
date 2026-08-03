# daed Android Magisk 模块改造 Spec

## Why

当前 `daed` 项目仅面向 Linux 桌面/服务器场景（systemd 服务、Docker、deb/rpm 包、桌面 `.desktop` 快捷方式），无法在已 root 的 Android 设备上以 Magisk 模块形式一键安装与开机自启。Android 用户需要一个开箱即用、能在开机后自动拉起 `daed` 后端、并可通过快捷方式一键跳转到 Web 配置面板（`http://127.0.0.1:2023`）的打包方案。本次改造在保留原有 Linux 发行方式的前提下，新增一套 Magisk 模块构建与安装产物，并同步更新项目介绍。

## What Changes

- 新增 Magisk 模块骨架目录 `android/magisk/`，包含 `module.prop`、`customize.sh`、`service.sh`、`post-fs-data.sh`、`uninstall.sh` 等标准 Magisk 模块文件。
- 新增「快捷跳转配置地址」能力：在 `system/bin/` 下安装一个 `daed-open` 脚本，通过 Android `am start` 调起系统浏览器打开 `http://127.0.0.1:2023`；同时在模块中预置一个可在桌面生成的快捷方式配置（`shortcut.json`），供启动器/快捷方式工具读取。
- 新增 `android/magisk/README.md` 模块说明（与项目根 README 区分），描述安装、启动、卸载、快捷跳转使用方式与注意事项。
- 新增 Makefile 目标 `magisk` 与 `magisk-zip`，用于将 Android arm64 的 `daed` 二进制与 Web 资源打包成 `daed-magisk-<version>.zip`。
- 修改根 `README.md` 介绍：在标题区/部署章节加入「Android Magisk 模块」入口说明，更新特性列表与适用平台描述，体现项目已支持 Android。
- 修改 `install/friendly-filenames.json`，新增 `android-arm64` 友好命名条目，便于产物识别。
- **BREAKING**：无（所有新增均为可选产物，不破坏现有 Linux 构建流程）。

## Impact

- Affected specs: 无既有 spec 文档（项目当前未使用 spec-driven 流程）。
- Affected code:
  - 新增：`android/magisk/module.prop`、`android/magisk/customize.sh`、`android/magisk/service.sh`、`android/magisk/post-fs-data.sh`、`android/magisk/uninstall.sh`、`android/magisk/system/bin/daed-open`、`android/magisk/shortcut.json`、`android/magisk/README.md`、`android/magisk/.gitignore`
  - 修改：`Makefile`（新增 `magisk` / `magisk-zip` 目标）、`README.md`（介绍与平台说明）、`install/friendly-filenames.json`（新增 android-arm64 条目）
- 依赖：模块产物依赖外部已编译的 Android arm64 `daed` 二进制（由上游 `wing` Makefile 产出 `GOOS=android GOARCH=arm64` 版本），本仓库不引入 Android NDK 工具链。

## ADDED Requirements

### Requirement: Magisk 模块结构

系统 SHALL 在 `android/magisk/` 目录下提供符合 Magisk 模块规范的最小文件集合，使模块可被 Magisk 识别并安装。

#### Scenario: Magisk 识别模块
- **WHEN** 用户在 Magisk 应用中选择「从存储安装」并选中打包后的 `daed-magisk-<version>.zip`
- **THEN** Magisk 能正确解析 `module.prop` 中的 `id`、`name`、`version`、`versionCode`、`author`、`description` 字段并显示在安装界面

#### Scenario: 安装后文件落位
- **WHEN** 模块安装完成
- **THEN** `daed` 二进制被放置到 `/data/adb/modules/daed/system/bin/daed`，`daed-open` 脚本被放置到 `/data/adb/modules/daed/system/bin/daed-open`，且两者均具备可执行权限

### Requirement: 开机自启 daed 服务

系统 SHALL 通过 `service.sh` 在 Android 启动完成后自动拉起 `daed run`，使设备无需手动操作即可使用代理。

#### Scenario: 开机后服务运行
- **GIVEN** 模块已安装且设备已重启
- **WHEN** Android 进入 `late_start service` 阶段
- **THEN** `daed run -c /data/adb/daed` 进程以 root 身份在后台运行，并监听 `127.0.0.1:2023`

#### Scenario: 重复启动保护
- **GIVEN** `daed` 进程已在运行
- **WHEN** `service.sh` 被再次执行
- **THEN** 脚本检测到已有进程后跳过启动，避免端口冲突

### Requirement: 快捷跳转配置地址

系统 SHALL 提供一键打开 daed Web 配置面板的方式，使用户无需手动输入 URL。

#### Scenario: 命令行快捷跳转
- **GIVEN** 模块已安装且 `daed` 服务正在运行
- **WHEN** 用户在终端（如 Termux 或 adb shell）执行 `daed-open`
- **THEN** 系统通过 `am start -a android.intent.action.VIEW -d http://127.0.0.1:2023` 调起默认浏览器并打开配置面板

#### Scenario: 桌面快捷方式配置可读
- **WHEN** 安装完成
- **THEN** 模块目录下存在 `shortcut.json`，包含 `name`、`url`、`description` 字段，便于第三方快捷方式工具或启动器读取并生成桌面图标

### Requirement: 模块卸载清理

系统 SHALL 在模块被卸载时清理 `daed` 运行进程与配置残留。

#### Scenario: 卸载时停止进程
- **GIVEN** 模块已安装且 `daed` 正在运行
- **WHEN** 用户在 Magisk 中禁用/删除模块触发 `uninstall.sh`
- **THEN** `daed` 进程被终止，但 `/data/adb/daed` 配置目录默认保留（提示用户手动备份）

### Requirement: 构建产物打包

系统 SHALL 提供 Makefile 目标，将 Android arm64 二进制、Web 资源与模块脚本打包为可分发的 zip。

#### Scenario: 打包生成 zip
- **GIVEN** 已存在 Android arm64 `daed` 二进制与 `apps/web/dist` Web 资源
- **WHEN** 执行 `make magisk-zip`
- **THEN** 在仓库根目录生成 `daed-magisk-<version>.zip`，其内部结构符合 Magisk 模块规范（`module.prop` 位于 zip 根目录）

## MODIFIED Requirements

### Requirement: 项目介绍（README）

根 `README.md` 的介绍 SHALL 反映项目已支持 Android Magisk 模块这一新部署形态。

#### Scenario: 读者了解平台支持
- **WHEN** 访客打开根 `README.md`
- **THEN** 能在显著位置（特性列表或部署章节）看到「Android Magisk 模块」入口，并可通过链接跳转到 `android/magisk/README.md` 获取详细安装说明

### Requirement: 友好文件名映射

`install/friendly-filenames.json` SHALL 包含 Android 平台产物的友好命名条目。

#### Scenario: Android 产物可识别
- **WHEN** 构建/发布流程读取 `friendly-filenames.json` 解析 `android-arm64` 平台
- **THEN** 返回友好名 `android-arm64`，与现有 Linux 条目风格一致
