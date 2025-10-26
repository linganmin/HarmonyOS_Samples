# 窗口元数据配置

### 介绍

本示例主要展示了窗口metadata标签相关功能，实现配置主窗口默认大小和位置、是否移除启动页、主窗启动时是否已最大化状态显示等功能

metadata标签标识HAP的自定义元信息，标签值为数组类型，包含name、value、resource三个子标签。

**表1** metadata标签说明

| 属性名称 | 含义 | 数据类型 | 是否可缺省 |
| -------- | -------- | -------- | -------- |
| name | 标识数据项的名称，取值为长度不超过255字节的字符串。 | 字符串 | 该标签可缺省，缺省值为空。 |
| value | 标识数据项的值，取值为长度不超过255字节的字符串。 | 字符串 | 该标签可缺省，缺省值为空。 |
| resource | 标识了用户自定义数据，取值为长度不超过255字节的字符串，内容为该数据的资源索引，例如配置成$profile:shortcuts_config，表示指向了/resources/base/profile/shortcuts_config.json配置文件。| 字符串 | 该标签可缺省，缺省值为空。 |

### 使用说明

1. 使用metadata标签配置主窗口的默认大小和位置（单位为vp）。仅在自由多窗场景和2in1设备上生效。

其中name取值及对应含义如下：

    * name取值为ohos.ability.window.height表示主窗口的默认高度，value表示高度大小。
    * name取值为ohos.ability.window.width表示主窗口的默认宽度，value表示宽度大小。
    * name取值为ohos.ability.window.left表示主窗口默认左边的位置。value表示配置格式，取值：对齐方式 +/- 偏移量。对齐方式包括center、left和right，默认值为left；当偏移量为0时可以省略。
    * name取值为ohos.ability.window.top表示主窗口顶部的位置。value表示配置格式，取值：对齐方式 +/- 偏移量。对齐方式包括center、top和bottom，默认值为top。如果对齐方式和偏移量同时省略，则按照系统默认的层叠规格处理。

2. 使用metadata标签配置是否移除启动页。配置项为：name取值为enable.remove.starting.window，value取值为true或false，取值为true表示移除启动页、取值为false表示不移除启动页，未配置时默认为false。该标签使用时需要搭配"[removeStartingWindow](https://developer.huawei.com/consumer/cn/doc/harmonyos-references/arkts-apis-window-windowstage#removestartingwindow14)"接口使用

3. 使用metadata标签配置主窗启动时是否以最大化状态显示。配置项为：name为ohos.ability.window.isMaximize，value取值为true或false，取值为true表示最大化启动、取值为false表示不以最大化状态启动，未配置时默认为false。主窗最大化显示配置的约束与限制可参考[窗口元数据配置](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/window-config-m)。仅在自由多窗场景和2in1设备上生效。

4. 使用metadata配置[自由多窗](https://developer.huawei.com/consumer/cn/doc/design-guides/pad-0000001823654157#section1768267204717)下的可支持窗口模式。配置项为：name为ohos.ability.window.supportWindowModeInFreeMultiWindow，value取值为：fullscreen（表示全屏模式）、split（表示分屏模式）、floating（表示悬浮窗模式）。value取值为字符串，可以配置多种模式，每个模式之间用逗号分隔开，不区分顺序，不添加空格，例如：fullscreen,split。仅在自由多窗场景和2in1设备上生效。

   自由多窗下的可支持窗口模式可以采用多种方法进行配置，配置优先级可参考[窗口元数据配置](https://developer.huawei.com/consumer/cn/doc/harmonyos-guides/window-config-m)。

   非自由多窗模式下只能通过配置module.json5中abilities标签下的SupportWindowMode属性配置窗口支持模式，其他配置方式均不生效。

5. 使用metadata标签配置主窗边角以直角显示。配置项为：name为ohos.ability.window.isRightAngle，value取值为true或false，取值为true表示窗口边角以直角显示、取值为false则使用系统默认圆角，未配置时默认为false。主窗直角配置仅在2in1设备上生效，且仅支持系统应用。

### 工程目录

```
entry/src/
 ├── main
 │   ├── ets
 │   ├── module.json5                    // metadata所在文件
 │   └── resources
 ├── ohosTest
 ├── mock
 ├── test
```

### 相关权限

不涉及

### 依赖

不涉及

### 约束与限制

1.本示例仅支持标准系统上运行, 支持设备：手机、平板、2in1。（部分字段可能仅支持部分设备，可参考使用说明）

### 下载

如需单独下载本工程，执行如下命令：

````
git init
git config core.sparsecheckout true
echo ArkUIKit/WindowMetaDataSample/ > .git/info/sparse-checkout
git remote add origin https://gitee.com/harmonyos_samples/guide-snippets.git
git pull origin master
````
