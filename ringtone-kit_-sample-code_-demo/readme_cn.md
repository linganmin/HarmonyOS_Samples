# 简介

Ringtone Kit（铃声服务）是一个用于设置铃声的工具库。通过使用Ringtone Kit，开发者可以在鸿蒙应用中提供铃声设置的功能，为用户提供简单一致、安全高品质的铃声设置体验。

|                         **应用首页**                         |
| :----------------------------------------------------------: |
| <img src="./screenshots/main.jpg"  width="250" align="middle" /> |

# 使用说明

使用前需要`先打开DEMO`，再使用 `hdc` 命令，将音频文件推入手机。

```bash
// 推送音乐命令
hdc file send 音乐文件.mp3 /storage/media/100/local/files/Docs/Download/com.example.uiextension
```

打开铃声设置Demo页面。

- 输入音乐文件名称，例如`6.mp3`，点击按钮`设为铃声`。
- 拉起设置铃声弹窗。
- 点击相应的设置按钮，设置不同的铃声类型。
- 点击我的铃声，跳转到系统设置铃声。

# 工程目录结构

```bash
├──entry/src/main
│  └──ets                           // 代码区
│     ├──entryability
│     │  └──EntryAbility.ets        // 程序入口类
│     └──pages                      // 页面文件
│        └──Index.ets               // 主界面
└──entry/src/main/resources         // 资源文件目录
```

# 约束与限制

1. 本实例仅支持标准系统上运行，支持设备：华为手机、华为平板。
2. HarmonyOS系统：HarmonyOS NEXT Developer Beta3及以上。
3. DevEco Studio版本：DevEco Studio NEXT Developer Beta3及以上。
4. HarmonyOS SDK版本：HarmonyOS NEXT Developer Beta3 SDK及以上。