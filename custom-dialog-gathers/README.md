# 实现多种自定义弹窗的效果

### 介绍

本示例通过CustomDialog、bindContentCover、bindSheet等接口，实现多种样式的弹窗。帮助开发者掌握自定义弹窗开发的步骤，灵活的实现自己业务需要用到的弹窗场景。

### 效果预览

| 滑动选择弹窗                                   | 模态弹窗                                      | 半模态弹窗                                      | toast弹窗                                |
|------------------------------------------|-------------------------------------------|--------------------------------------------|----------------------------------------|
| ![image](screenshots/device/slide.gif)   | ![image](screenshots/device/modality.gif) | ![image](screenshots/device/semimodal.gif) | ![image](screenshots/device/toast.gif) |
| 隐私协议弹窗                                   | 全屏弹窗                                      | 自定义日历选择器弹窗                                 | 两级半模态+全屏弹窗                             |
| ![image](screenshots/device/privacy.gif) | ![image](screenshots/device/screen.gif)   | ![image](screenshots/device/customize.gif) | ![image](screenshots/device/add.gif)   |

### 使用说明：

加载完成后显示首页的8个自定义弹窗类别，点击对应按钮，进入相应的弹窗页面：
1. 滑动选择弹窗：点击页面底部两个按钮，会弹出对应的12小时制的时间选择器弹窗和文本选择器弹窗。
2. 模态弹窗：点击页面底部选择乘车人，会弹出模态弹窗，点击模态弹窗底部确认按钮，关闭模态弹窗。
3. 半模态弹窗：点击页面中选择点餐口味和餐具按钮，弹出半模态弹窗，点击遮罩层关闭弹窗。
4. toast弹窗：点击底部按钮，会弹出登陆成功的toast弹窗，3s后弹窗淡出消失。
5. 隐私协议弹窗：点击底部按钮弹出隐私协议弹窗，弹窗内容可以滚动，橙色的隐私协议可以点击，点击后会跳转到新页面，点击新页面的返回按钮回到隐私弹窗页面，弹窗不会关闭，点击同意或不同意关闭弹窗。
6. 全屏弹窗：点击底部按钮弹出全屏弹窗，点击左上角向下箭头可直接关闭弹窗；通过向下滑动会有阻尼效果，当滑动距离大于300时，弹窗会关闭，否则回弹到原位置。
7. 自定义日历选择器弹窗：点击页面中的日期会弹出日期选择器弹窗，当前日期之前的日期不可选，之后的日期可选，选择完成后弹窗关闭，日期更改为选中的日期。
8. 两级半模态+全屏弹窗：点击"open sheet1"按钮弹出第一个半模态弹窗，点击里面的输入框，弹出的键盘不避让，点击close sheets1按钮会关闭第一个弹窗；点击""open sheets2"按钮会打开第二个半模态弹窗，第二个半模态弹窗中有两个按钮，点击"close sheets2"按钮只会关闭第二个半模态弹窗，点击"close sheet1 sheet2"按钮会关闭第一个和第二个半模态弹窗。

### 工程目录

```
├──entry/src/main/ets/
│  ├──common/constant
│  │  └──CommonConstants.ets                   // 公共常量类
│  ├──entryability
│  │  └──EntryAbility.ets                      // 程序入口类
│  ├──pages                 
│  │  ├──Index.ets                             // 首页
│  │  ├──BindContentCoverDemo.ets              // 模态弹窗页面
│  │  ├──BindSheet.ets                         // 半模态弹窗页面
│  │  ├──CustomCalendar.ets                    // 自定义日历选择器弹窗页面
│  │  ├──FullScreen.ets                        // 全屏弹窗页面
│  │  ├──Privacy.ets                           // 隐私协议弹窗页面
│  │  ├──ScrollOption.ets                      // 滑动选择弹窗页面
│  │  └──TwoLevelPageSheet.ets                 // 两级半模态+全屏弹窗页面
│  ├──view                  
│  │  └──CustomCalendarPickerDialog.ets        // 自定义日历弹窗组件
│  └──viewmodel 
│     ├──BindContentModel.ets                  // 模态弹窗接口和数据
│     ├──DataManager.ets                       // 数据存储类
│     ├──DateModel.ets                         // 日期类
│     ├──GetDate.ets                           // 获取日期函数
│     └──MonthDataSource.ets                   // 月份数据类
└──entry/src/main/resources                    // 应用资源目录
```

### 具体实现
1. 滑动选择弹窗：通过TimePickerDialog.show(时间选择器弹窗)和TextPickerDialog.show(文本选择器弹窗)两个组件来实现。
2. 模态弹窗：通过bindContentCover属性为组件绑定全屏模态页面，点击后显示模态页面。模态页面内容自定义，显示方式可设置无动画过渡，上下切换过渡以及透明渐变过渡方式。
3. 半模态弹窗：通过bindSheet属性为组件绑定半模态页面，点击后显示半模态页面。
4. toast弹窗：使用自定义弹窗(CustomDialog)来模拟toast提示弹窗，通过设置CustomDialogController类的各种属性值实现效果。
5. 隐私协议弹窗：通过Stack组件层叠模拟实现弹窗，使用visibility属性控制弹窗显示隐藏，实现点击跳转到新页面，点击新页面的返回按钮回到隐私弹窗页面，弹窗不会关闭的效果。
6. 全屏弹窗：通过translate属性将全屏页面隐藏在可视区外，点击全屏弹窗按钮，通过显示动画将全屏弹窗显示出来；在gesture属性内通过PanGesture拖动手势事件，来实现当向下滑动大于300时，弹窗会关闭，否则回弹到原位置。
7. 自定义日历选择器弹窗：使用自定义弹窗(CustomDialog)来实现自定义日历选择器，使用LazyForEach组件循环遍历实现月份，本示例值显示两个月(当前月份与下一个月)，使用ForEach来遍历每个月的每一天。
8. 两级半模态+全屏弹窗：通过bindSheet属性为open sheet1按钮组件绑定第一个半模态页面，给第一个半模态页面中open sheet2绑定第二个半模态页面，从而实现两级半模态弹窗。

### 相关权限
不涉及

### 依赖
不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。 

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。