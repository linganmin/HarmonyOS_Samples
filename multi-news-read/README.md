# 多设备新闻阅读界面

## 介绍

本示例基于自适应布局和响应式布局，实现一次开发，多端部署的新闻阅读页面。根据手机、折叠屏以及平板不同的设备尺寸实现对应页面。

## 效果预览
手机运行效果图如下：

<img src="screenshots/device/phone.png"/>

折叠屏运行效果图如下：

<img src="screenshots/device/foldable.png"/>

tablet运行效果图如下：

<img src="screenshots/device/tablet.png"/>


## 工程目录结构

```
├──entry/src/main/ets                                   // 代码区
│  ├──common                                            // 媒体查询工具类
│  |  └──Constants.ets                                  // 常量
│  ├──entryability
│  |   └──EntryAbility.ets
│  ├──pages
│  |  ├──Index.ets                                      // 主页界面
│  |  ├──MediaNews.ets                                  // 媒体新闻
│  |  ├──NewsChannel.ets                                // 新闻频道
│  |  └──NewsListPage.ets                               // 新闻列表界面
│  ├──view
│  |  ├──Header.ets                                     // 页签头部组件
│  |  ├──HotList.ets                                    // 热门列表组件
│  |  ├──LeftTextRightImageBgGray.ets                   // 左文右图组件1
│  |  ├──LeftTextRightImageBgWhite.ets                  // 左文右图组件2
│  |  ├──NewsWithImages.ets                             // 上文下图组件
│  |  ├──TopImageBottomText.ets                         // 上图下文组件
│  |  ├──TopTextBottomVideo.ets                         // 上文下视频组件
│  |  └──VideoCard.ets                                  // 视频卡片组件
│  └──viewmodel
│     ├──HotListViewModel.ets                           // 热门列表数据
│     ├──ImageAndTextViewModel.ets                      // 左文右图数据
│     ├──ImageAndTextViewModelForPageNewsChannel.ets    // NewsChannel界面数据
│     ├──MultiImageViewModel.ets                        // 多图卡片数据
│     ├──MultiImageViewModelForMediaNews.ets            // MediaNews界面数据
│     ├──TopImageBottomTextViewModel.ets                // 上文下图数据
│     └──VideoListViewModel.ets                         // 视频卡片数据
└──entry/src/main/resources                             // 应用资源目录
```

## 具体实现

媒体新闻界面采用使用重复布局。使用栅格布局，根据断点控制显示的列数，并使用GridRow组件的onBreakChange事件回调，在界面大小变更时，更新断点值与渲染的数据源条数。具体而言，在sm和md断点下，设置GridRow的columns属性为1，而在lg断点及以上时，设置columns属性为2。

新闻频道界面也采用重复布局。使用栅格布局，根据断点控制显示列数，同样的在sm和md断点下，设置GridRow的columns属性为1，而在lg断点及以上时，设置columns属性为2。与媒体新闻不同的是，新闻频道界面的新闻内容摘要需要控制在sm和md断点下不显示，而在lg断点下以最多两行显示。具体实现为根据断点控制Text组件的visibility属性，在sm和md断点下设置为Visibility.Hidden，在lg断点下设置为Visibility.Visible。最多两行显示的实现为设置Text组件的maxLines为2，即最多两行显示，同时设置textOverflow为overflow: TextOverflow.Ellipsis，即多出部分以省略号显示。

新闻列表界面使用列表变宫格。具体实现为在sm断点下设置整体布局为使用List组件进行布局，而在sm断点以上不包括sm断点使用栅格布局，在md断点下设置内容占用两列，并按需设置GridCol占用的列数。在lg断点下设置内容占用四列，同样按需设置GridCol占用的列数。


## 相关权限

不涉及

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机、平板。

2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。