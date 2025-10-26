# 实现手写绘制图片功能

### 介绍

本示例使用Drawing库的Pen和Path结合NodeContainer组件实现手写绘制功能，并通过Image库的packToFile和packing接口将手写板的绘制内容保存为图片。通过该示例，开发者可以掌握图片绘制相关接口的使用以及如何将画布保存为图片。

### 效果图预览

![](screenshots/device/HandWriteToImage.gif)

**使用说明**

1. 在虚线区域手写绘制，点击撤销按钮撤销前一笔绘制，点击重置按钮清空绘制。 
2. 点击箭头可以跳转到预览界，预览界面可以进行图片预览以及图片保存。 
3. 预览界面点击packToFile保存图片按钮和packing保存图片按钮可以将绘制内容保存为图片并写入文件，显示图片保存路径。

### 实现思路

1. 创建NodeController的子类MyNodeController，用于获取根节点的RenderNode和绑定的NodeContainer组件宽高。
2. 创建RenderNode的子类MyRenderNode，初始化画笔和绘制path路径。
3. 创建变量currentNode用于存储当前正在绘制的节点，变量nodeCount用来记录已挂载的节点数量。
4. 创建自定义节点容器组件NodeContainer，接收MyNodeController的实例，将自定义的渲染节点挂载到组件上，实现自定义绘制。 
5. 在NodeContainer组件的onTouch回调函数中，手指按下创建新的节点并挂载到rootRenderNode，nodeCount加一，手指移动更新节点中的path对象，绘制移动轨迹，并将节点重新渲染。 
6. rootRenderNode调用getChild方法获取最后一个挂载的子节点，再使用removeChild方法移除，实现撤销上一笔的效果。 
7. 使用clearChildren清除当前rootRenderNode的所有子节点，实现画布重置，nodeCount清零。
8. 使用componentSnapshot.get获取组件NodeContainer的PixelMap对象，用于保存图片。 
9. 使用Image库的packToFile()和packing()将获取的PixelMap对象保存为图片。

### 高性能知识点

不涉及

### 工程结构&模块类型

```
├──entry/src/main/ets                         // ets 代码区
│  ├──constants
│  │  └──CommonConstants.ets                  // 常量定义文件  
│  ├──entryability
│  │  └──EntryAbility.ets       
│  ├──model
│  │  └──RenderNodeModel.ets                  // MyRenderNode类模版页面
│  └──pages
│     ├──SavePages.ets                        // 预览保存界面
│     └──Index.ets                            // 绘制界面
└──entry/src/main/resources                   // 应用资源目录
```

### 参考资料

1. Drawing绘制模块。
2. NodeController。
3. 自渲染节点RenderNode。
4. Image图片处理。
5. FileIo文件管理。

### 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
