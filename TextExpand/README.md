## 实现富文本收起展开功能

### 介绍

本示例展示列表中的博文、评论等应用场景在展示文本内容，超过多行时，往往需要提供“展开”“折叠”的功能。

### 效果预览

| 首页                                  | 富文本显示展开按钮                                    | 富文本显示收起按钮                                  | 纯文本显示收起按钮                                  | 纯文本显示展开按钮                                    |
|-------------------------------------|----------------------------------------------|--------------------------------------------|--------------------------------------------|----------------------------------------------|
| ![](./screenshots/devices/home.png) | ![](./screenshots/devices/rich_collapse.png) | ![](./screenshots/devices/rich_expand.png) | ![](./screenshots/devices/text_expand.png) | ![](./screenshots/devices/text_collapse.png) |

使用说明：
1. 打开应用，首页点击富文本折叠，跳转到富文本展示页面，点击展开按钮列表展开，点击收起按钮，列表收起。
2. 打开应用，首页点击纯文本折叠，跳转到纯文本展示页面，点击展开按钮列表展开，点击收起按钮，列表收起。

### 工程目录

```
├──ets
│  ├──entryability
│  │  └──EntryAbility.ets
│  ├──entrybackupability
│  │  └──EntryBackupAbility.ets
│  ├──pages
│  │  ├──index .ets              // 主页
│  │  ├──RichTextExpand .ets     // 富文本场景
│  │  ├──TextExpand.ets          // 纯文本场景
│  ├──utils
│  │  ├──Models .ets             // 数据模型
│  │  ├──TextUtils .ets          // 文本处理工具
│  └──view
│     ├──ItemPart.ets            // 纯文本场景List数据展示组件
│     ├──RichItemPart.ets        // 富文本场景List数据展示组件
│     ├──RichTextExpandView.ets  // 封装的富文本展开折叠组件
│     ├──TextExpandView.ets      // 封装的纯文本展开折叠组件
└──resources
```

### 具体实现

1. 使用[MeasureText](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-components-canvas-canvasrenderingcontext2d#measuretext)
对文本文字内容进行预排版，测量计算折叠展开按钮位置，进而实现折叠展开功能。

2. 使用[ParagraphBuilder](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-graphics-text#paragraphbuilder)
进行段落排版，根据排版内容计算截断位置，进而实现折叠展开功能。

### 相关权限

不涉及。

### 依赖

不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.1.1 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.1.1 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.1.1 Release SDK及以上。

