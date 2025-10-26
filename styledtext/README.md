# 实现富文本信息的显示

### 介绍

本示例针对高亮显示的超链接文本、自定义表情、图标与文本的组合元素、自定义的图文元素四个场景的富文本信息的效果实现。

### 效果预览

<img src="./screenshots/device/result.gif" style="width:320px">

**使用说明**

1. 点击按钮跳转到不同的页面。
2. 点击话题、@用户、视频可以跳转到对应的详情页。

### 工程目录

   ```  
   ├──entry/src/main/ets
   │  ├──common 
   │  │  └──HandleData.ets           // 公共处理方法    
   │  ├──components 
   │  │  └──MyDrawCustomSpan.ets     // 自定义组件    
   │  ├──mock 
   │  │  └──MockData.ets             // mock测试模拟数据          
   │  ├──model                                
   │  │  └──MyCustomSpan.ets         // 数据类型定义
   │  └──pages                       // 视图层
   │     ├──CustomizeEmoji.ets       // 自定义表情页面 
   │     ├──Home.ets                 // 主页面
   │     ├──ImageText.ets            // 自定义的图文元素页面
   │     ├──TitleDetail.ets          // 跳转页面-#话题点击跳转页面
   │     ├──TitleLink.ets            // 高亮显示的超链接文本页面
   │     ├──UserDetails.ets          // 跳转页面-@用户点击跳转页面            
   │     └──VideoLink.ets            // 图标与文本的组合元素页面
   └──entry/src/main/resources       // 应用资源目录                                                     
   ```

### 具体实现

TextAndSpanComponent 组件通过自定义Span对象区分不同类型的文本，在Text组件中遍历自定义Span对象数组并检查字符长度，根据自定义Span对象的类型生成不同样式和功能的Span组件。

1. 遍历 spans 中的 MyCustomSpan 对象，根据不同的 Span 类型生成不同样式功能和事件的属性。
2. 通过设置点击回调linkClickCallback，可以根据点击的span类型，执行对应操作，例如跳转详情页或视频页。

### 相关权限
不涉及

### 依赖
不涉及

### 约束与限制
1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.1.0 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.1.0 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.1.0 Release SDK及以上。