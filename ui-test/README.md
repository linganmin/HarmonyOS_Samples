# 测试框架（UiTest）

### 介绍

本示例展示测试框架中UI测试框架的使用示例。便于开发者正确使用UI测试框架。

本实例需要引入UiTest接口@ohos.UiTest。

如需日志打印调试，需要引入日志打印接口@ohos.hilog。

### 效果预览

不涉及

使用说明

- 将uitest目录下的项目工程整体导入到DevEco Studio开发工具中。
- 查看ohostest目录下的测试代码实现。
- 在DevEco Studio中执行测试用例代码查看执行效果，执行方式请参考官网的测试框架。
- 本工程执行测试用例代码的结果，根据实际开发设备不同会有变更。请根据具体的开发设备修改代码中对应参数。

### 工程目录

```
├──entry/src/main/ets                             // 代码区
│  ├──clickability  
│  │  └──ClickAbility.ets                         // 点击入口类
│  ├──dragability  
│  │  └──DragAbility.ets                          // 拖拽入口类
│  ├──entryability  
│  │  └──EntryAbility.ets                         // 主程序入口类
│  ├──flingability  
│  │  └──FlingAbility.ets                         // 惯性滚动入口类
│  ├──inputability  
│  │  └──InputAbility.ets                         // 输入入口类
│  ├──mouseability  
│  │  └──MouseAbility.ets                         // 鼠标入口类
│  ├──pages  
│  │  ├──Click.ets                                // 点击页面
│  │  ├──Drag.ets                                 // 拖拽页面
│  │  ├──Fling.ets                                // 惯性滚动页面
│  │  ├──Fourth.ets                               // 第四页面
│  │  ├──Index.ets                                // 首页页面
│  │  ├──Input.ets                                // 输入页面
│  │  ├──Mouse.ets                                // 鼠标页面
│  │  ├──Pinch.ets                                // 捏合页面
│  │  ├──Scroller.ets                             // 滑动页面
│  │  ├──Swipe.ets                                // 滑块页面
│  │  └──Third.ets                                // 第三页面
│  ├──pinchability  
│  │  └──PinchAbility.ets                         // 捏合入口类
│  ├──pointmatrixability  
│  │  └──PointMatrixAbility.ets                   // 矩阵入口类
│  ├──scrollerability  
│  │  └──ScrollerAbility.ets                      // 滑动入口类
│  ├──swipeAbility  
│  │  └──SwipeAbility.ets                         // 滑块入口类
│  └──util  
│     └──Logger.ets                               // 日志工具类
├──entry/src/main/resources                       // 应用资源目录
├──entry/src/ohosTest/ets                         // 代码区
│  ├──test
│  │  ├──BasicExampleTest                        
│  │  │  └──BasicExample.test.ets                 // 基础自动化测试脚本
│  │  ├──findCommentExampleTest                        
│  │  │  ├──component
│  │  │  │  └──FindCommentExample.test.ets        // 寻找组件自动化脚本
│  │  │  └──window
│  │  │     └──FindWindowExample.test.ets         // 寻找窗口自动化脚本
│  │  ├──operationExampleTest                        
│  │  │  ├──ui
│  │  │  │  ├──ClickEvent.test.ets                // 点击事件自动化脚本
│  │  │  │  ├──FlingEvent.test.ets                // 惯性滚动事件自动化脚本
│  │  │  │  ├──InputEvent.test.ets                // 输入事件自动化脚本
│  │  │  │  ├──MouseEvent.test.ets                // 点击事件自动化脚本
│  │  │  │  ├──PinchEvent.test.ets                // 捏合事件自动化脚本
│  │  │  │  ├──PointMatrixEvent.test.ets          // 矩阵事件自动化脚本
│  │  │  │  ├──ScreenCapEvent.test.ets            // 捕获屏幕事件自动化脚本
│  │  │  │  ├──ScrollerEvent.test.ets             // 滑动事件自动化脚本
│  │  │  │  └──SwipeEvent.test.ets                // 滑块事件自动化脚本
│  │  │  └──window
│  │  │     ├──MoveToEvent.test.ets               // 移动事件自动化脚本
│  │  │     ├──ReSizeWindow.test.ets              // 窗口大小自动化脚本
│  │  │     └──WindowAttr.test.ets                // 获取窗口自动化脚本
│  │  └──List.test.ets                            // 测试脚本列表
│  ├──testability
│  │  ├──pages
│  │  │  └──Index.ets                             // 首页页面
│  │  └──TestAbility.ets   
│  ├──testrunner                       
│  │  └──OpenHarmonyTestRunner.ets  
│  └──util                       
│     └──Logger.ts                                // 日志工具类
└──entry/src/ohosTest/resources                   // 应用资源目录
```

 须知

- 前提：引入UiTest依赖：import {Driver,ON,Component,Uiwindow,MatchPattern} from '@ohos.UiTest'  
1、On类提供的接口全部是同步接口，使用者可以使用builder模式链式调用其接口构造控件筛选条件。  
2、Driver和Component类提供的接口全部是异步接口(Promise形式)，需使用await语法。  
3、Ui测试用例均需使用异步语法编写用例，需遵循单元测试框架异步用例编写规范。

### 具体实现

#### uitestUI测试框架示例内容

- 1）在entry的index.ets中放页面组件。
- 2）在ohosTest的test/basicExample.test.ets中it()定义一条测试用例，支持三个参数：用例名称，过滤参数和用例函数。用例操作的行为以异步的形式编写。
- 3）指定唯一的ability即entry：通过want()中指定bundleName和abilityName：EntryAbility。
- 4）启动指定ability(相当于手动运行hap)：通过abilityDelegatorRegistry.getAbilityDelegator.startAbility(want)。
- 5）获取当前应用最顶层的ability对象：通过abilityDelegatorRegistry.getAbilityDelegator.getCurrentTopAbility().then((ability)=>{}) 。
- 6）引入Driver类作为UiTest测试框架的总入口，提供查找控件,定时器，断言，单机back键等能力。
- 7）在第5步.then()中加入需要测试内容 ：  
  - 例如本案例中需要检验是否可以有back键能力：通过driver.pressBack()。  
  - 检验是否可以定时1s后执行能力:通过driver.delayMs(1000)。  
  - 日志打印：建议用例名称中的包名和日志中的包名单独用常量表示，方便包名变更整改，例如：hilog.info(DOMAIN, TAG, BUNDLE + "StartAbility_001, begin")。
- 8）结束事件done();

### 相关权限

不涉及

### 依赖

不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
