# daed Android Magisk 模块

daed Android Magisk 模块版本，可在已 root 的 Android 设备上以 Magisk 模块形式安装，开机自启 daed 后端，并通过快捷方式打开 Web 配置面板。

**适用平台：** Android arm64，需要已安装 Magisk（推荐 Magisk 24+）。

## 📦 安装

**前置条件：**

- 已 root 的 Android 设备
- 已安装 Magisk
- 获取 `daed-magisk-<version>.zip` 安装包

**安装步骤：**

1. 将 `daed-magisk-<version>.zip` 传入手机存储
2. 打开 Magisk 应用 → 模块 → 从存储安装
3. 选择 zip 文件，等待安装完成
4. 重启设备

**安装后文件位置：**

- 二进制：`/data/adb/modules/daed/system/bin/daed`
- 快捷跳转脚本：`/data/adb/modules/daed/system/bin/daed-open`
- 配置目录：`/data/adb/daed`

## 🚀 开机自启

模块通过 `service.sh` 在 Android 启动完成后自动拉起 daed 后端：

```bash
daed run -c /data/adb/daed
```

- 监听地址：`http://127.0.0.1:2023`
- 脚本内置重复启动保护（通过 `pgrep`/`pidof` 检测已有进程），无需担心多次执行导致端口冲突
- 如需手动启动，可在终端执行：

```bash
su -c 'daed run -c /data/adb/daed &'
```

## 🔗 快捷跳转配置地址

这是本模块的特色功能，提供两种方式快速打开 daed Web 配置面板。

### 方式一：命令行快捷跳转

在 Termux 或 adb shell 中执行：

```bash
daed-open
```

该脚本通过 `am start -a android.intent.action.VIEW -d http://127.0.0.1:2023` 调起系统默认浏览器打开配置面板。

### 方式二：桌面快捷方式配置

模块目录下预置 `shortcut.json`，第三方快捷方式工具（如「快捷方式」类 App）可读取该 JSON 生成桌面图标。

`shortcut.json` 内容示例：

```json
{
  "name": "daed",
  "url": "http://127.0.0.1:2023",
  "description": "Open daed web configuration panel"
}
```

## 🗑️ 卸载

- 在 Magisk 应用中删除模块即可
- 卸载时会自动停止 daed 进程
- 配置目录 `/data/adb/daed` 默认保留，如需彻底清理请手动删除：

```bash
rm -rf /data/adb/daed
```

## ⚠️ 注意事项

- 需要 root 权限
- 当前仅支持 Android arm64 架构
- eBPF 功能依赖内核版本（建议内核版本 >= 5.10，且开启 BPF 相关选项）
- 如遇网络异常，可尝试重启设备或检查 daed 配置
- 与 Linux 版本功能一致，但 Android 环境下部分高级网络配置可能受限
