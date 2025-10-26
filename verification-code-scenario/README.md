# 实现多种验证码场景的效果

### 介绍

本示例实现了5种验证码场景，基本涵盖了大部分应用的验证码场景。开发者可按需下载代码，实现自己应用的验证码场景。

### 效果预览
| 文本框显示光标                                | 底部加横条                                   | 背景颜色改变                                      | 选择验证码                                   |
|----------------------------------------|-----------------------------------------|---------------------------------------------|-----------------------------------------|
| ![image](screenshots/device/text.gif)  | ![image](screenshots/device/bottom.gif) | ![image](screenshots/device/background.gif) | ![image](screenshots/device/choose.gif) |
| 滑动验证码                                  |
| ![image](screenshots/device/slide.gif) |

### 使用说明：

加载完成后显示首页的5个验证码实例，点击对应按钮，进入相应的验证码页面：
1. 文本框显示光标：输入数字光标会移动到下一个文本框，同时下边框变色。
2. 底部加横条：在输入框内输入6位数字。
3. 背景颜色改变：输入数字后背景颜色改变。
4. 选择验证码：按照提示文字的顺序点击图片上的文字，然后点击提交。
5. 滑块验证码：点击滑块按钮向右滑动，直到将图片拼接完整时松手。

### 工程目录

```
├──entry/src/main/ets/
│  ├──common
│  │  ├──Constants.ets                         // 公共常量类
│  │  └──GlobalBuilderContext.ets              // 全局页面信息
│  ├──entryability
│  │  └──EntryAbility.ets                      // 程序入口类
│  ├──pages                 
│  │  ├──BackgroundColorChange.ets             // 背景颜色改变
│  │  ├──BottomWithBar.ets                     // 底部加横条
│  │  ├──Index.ets                             // 首页
│  │  ├──SelectVerificationCode.ets            // 选择验证码
│  │  ├──SliderVerificationCode.ets            // 滑块验证码
│  │  └──TextBoxShowCursor.ets                 // 文本框显示光标
│  └──viewmodel 
│     └──NavDestinationItem.ets                // 路由类型
└──entry/src/main/resources                    // 应用资源目录
```

### 具体实现
1. 文本框显示光标：当前TextInput暂时无法监听到删除键，这里使用了Text组件，订阅输入法插入、删除事件，从而获取输入内容，当组件的可视面积变化的时候进行绑定与解绑，光标通过属性动画显隐效果实现。
2. 底部加横条：通过TextInput实现，限制最大输入个数为6个数字，使用Divider在下面添加一条横线实现效果。
3. 背景颜色改变：与文本框显示光标相同的原理，背景颜色改变是通过判断是否输入了数字，有数字的背景颜色改变。
4. 选择验证码：通过Stack组件将数字覆盖到图片上，当点击数字时获取当前点击位置相对于页面的横纵坐标和点击的文字内容，并将文字添加到数组中，通过坐标移动代表点击顺序的数字，点击提交按钮判断数组中的文字内容和顺序是否正确。
5. 滑块验证码：通过Slider组件的onChange方法获取互动的距离，从而移动图片上的滑块把图片拼接完整。

### 相关权限
不涉及。

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。 

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。