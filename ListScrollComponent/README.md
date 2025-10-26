# 基于ScrollComponents实现长列表

## 项目简介

本示例展示了使用ScrollComponents构建长列表页面，覆盖场景包括

- 长列表Item组件复用
- 长列表分组布局场景
- 长列表跨页面复用场景
- 加速首屏渲染场景
- 长列表数据处理场景：下拉刷新、上拉加载；
- 长列表无限滑动场景
- 长列表侧滑删除场景
- 长列表多类型列表项场景
- 长列表Tabs吸顶场景
- 分组吸顶场景
- 长列表二级联动场景
- 长列表动态切换列数场景
- 设置边缘渐隐场景

## 效果预览

<img src="./screenshots/img.gif" width = "40%" alt="图片名称"/>

## 使用说明

1. 打开应用首页，显示场景列表。点击SameItemListPage，实现了列表项结构相同的组件复用场景、长列表加速首屏渲染场景、长列表侧滑删除场景、设置边缘渐隐场景、长列表动态切换列数场景。
2. 返回首页，点击CombineItemListPage，实现了列表项内子组件可拆分组合的复用场景、长列表加速首屏渲染场景、长列表无限滑动场景。
3. 返回首页，点击DifferentItemListPage，实现了列表项结构类型不同的组件复用场景、长列表下拉刷新和上拉加载场景。
4. 返回首页，点击GroupLayoutListPage，实现了长列表分组布局场景、长列表多类型列表项（ListHeaderView）场景、长列表分组吸顶场景、长列表二级联动场景。
5. 返回首页，点击TabsCeilingListPage，实现了Tabs吸顶场景、跨页面复用场景。

## 工程目录

```
├─entry/src/main/ets
├── common  
│  ├── contants  
│  │  └── CommonConstants.ets         // 常量
│  └── utils   
│     ├── Logger.ets                  // 日志类
│     ├── ToastUtil.ets               // 弹窗工具类
│     └── Utils.ets                   // 工具类
├── component  
│  └── PublicView.ets                 // 公共组件类
├── entryability  
│  └── EntryAbility.ets               // 程序入口类
├── entrybackupability  
│  └── EntryBackupAbility.ets         // 数据备份恢复类
├── model                              
│  ├── mock.ets                       // 模拟加载数据类
│  ├── types.ets                      // 数据模型
│  └── CategoryModel.ets              // 分类模型
├── viewmodel   
│  ├── SameItemViewModel.ets          // 列表项结构类型相同页面ViewModel
│  ├── CombineItemViewModel.ets       // 列表项内子组件可拆分组合页面ViewModel
│  ├── DifferentItemViewModel.ets     // 列表项结构类型不同页面ViewModel
│  ├── GroupLayoutViewModel.ets       // 分组布局页面ViewModel
│  └── TabsCeilingViewModel.ets       // Tabs吸顶页面ViewModel
└── pages                                   
   ├── Index.ets                      // 首页
   ├── SameItemListPage.ets           // 列表项结构类型相同页面
   ├── CombineItemListPage.ets        // 列表项内子组件可拆分组合页面
   ├── DifferentItemListPage.ets      // 列表项结构类型不同页面
   ├── GroupLayoutListPage.ets        // 分组布局页面
   └── TabsCeilingListPage.ets        // Tabs吸顶页面
```

## 具体实现

> 下文介绍高效无限长列表页面渲染。

### 1. 定义长列表视图管理类，注册item节点模板

ListManager是视图管理器，开发者根据业务需要自定义视图管理器类。

- 页面初始化时，开发者自定义子节点模板和组件绑定，即可实现复用能力
- 如果使用预创建节点，需在预创建前注册节点模板

```c
// src/main/ets/pages/StandardWaterFlowPage.ets

import { ListManager, NodeItem, RecyclerView } from '@hadss/scroll_components';

@Builder
function StandardGridImageContainer($$: ESObject) {
  GridImageView({blogItem: $$.blogItem})
}

// 1. 自定义视图管理器
class MyListManager extends ListManager {
  onWillCreateItem(index: number, data: BlogData) {
    // 3. 根据唯一标识获取复用节点，传递节点数据
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('EasyBlogItemContainer');
    node?.setData({ blogItem: data });
    return node;
  }
}

@Component
export struct SameItemListPage {
  // 视图管理器实例化
  myListManager: MyListManager = new MyListManager({
    defaultNodeItem: 'EasyBlogItemContainer',
    context: this.getUIContext()
  });
  ...
  
  aboutToAppear(): void {
    ...
    this.initView();
    // 2. 注册节点模板
    this.myListManager.registerNodeItem('EasyBlogItemContainer', wrapBuilder(EasyBlogItemContainer));
  }
  ...
}
```

### 2. List组件初始化

```c
// src/main/ets/pages/SameItemListPage.ets

initView() {
  this.myListManager.setItemViewStyle((item, index, data: ESObject) => {
    item({ style: ListItemStyle.NONE })
      .width('100%')
      .height('auto')
      .swipeAction({
        end: {
          builder: () => {
            this.ItemActionEnd(index)
          },
        },
        start: {
          builder: () => {
            this.ItemActionStart(index)
          },
        },
        onOffsetChange: (offset: number) => {
          Logger.info("offset:" + offset)
        }
      })
      .onClick(() => {
        Logger.info("index:" + index)
      })
  })

  this.myListManager.setViewStyle({ space: 10, scroller: this.scroller, })
    .cachedCount(2)
    .width('100%')
    .layoutWeight(1)
    .contentStartOffset(20) 
    .contentEndOffset(20) 
    .scrollBar(BarState.On)
    .divider({
      strokeWidth: 2,
      color: '#F5F5F5',
      startMargin: 20,
      endMargin: 20
    })  
    .onClick((event) => {
      Logger.info('ListView onClick')
    })
    .onScrollIndex((start: number, end: number, center: number) => {
      Logger.info('SameItemListPage onScrollIndex: start: ' + start + ' end: '+ end + ' center ' + center)
    })
    .onScrollVisibleContentChange((start: VisibleListContentInfo, end: VisibleListContentInfo) => {
      Logger.info(' start index: ' + start.index + ' end index: ' + end.index);
    })
    .onDidScroll((scrollOffset: number, scrollState: ScrollState) => {
      Logger.info(`onScroll scrollState = ScrollState` + scrollState + `, scrollOffset = ` + scrollOffset);
    })
    .alignListItem(ListItemAlign.Start)
    .lanes(1)
    .childrenMainSize(this.listChildrenSize) 
    .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(80) }) 
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
}
```

### 3. 设置数据源渲染组件

- ScrollComponents默认支持懒加载，使用setDataSource设置普通数组即可。开发者无需繁琐的定义类似lazyForEach的Datasource数据源
- RecyclerView组件占位，绑定视图容器实例即可渲染长列表

```c
// src/main/ets/pages/SameItemListPage.ets

import { RecyclerView } from '@hadss/scroll_components';

@Observed
class BlogData {
  id: number = -1;
  images: string[] = [];
  imagePixelMap: image.PixelMap | undefined;
  ...
}

@Component
export struct SameItemListPage {
  myListManager: MyListManager = new MyListManager({
    defaultNodeItem: 'EasyBlogItemContainer',
    context: this.getUIContext()
  });
  @State myViewModel: SameItemViewModel = new SameItemViewModel(this.myListManager);
  scroller: Scroller = new Scroller();
  @State data: BlogData[] = [];
  ...
  
  aboutToAppear(): void {
    ...
    this.initView();
    // 1. setDataSource设置长列表数据
    this.myViewModel.loadData();
  }
  
  build() {
    Column() {
      ...
      // 2. 绑定视图容器实例
      RecyclerView({
        viewManager: this.waterFlowView
      })
    }
  }
}
```

```c
@Observed
export class SameItemViewModel {
  ...
  loadData() {
    setTimeout(() => {
      generateRandomBlogData(300, false).then((data: BlogData[]) => {
        this.data = data;
        this.myListManager.setDataSource(data);
      })
    }, this.NetworkTime)
  }
}
```

## 相关权限

- 示例涉及网络资源下载，需要`ohos.permission.INTERNET`权限

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 6.0.0 Beta1及以上。
3. DevEco Studio版本：DevEco Studio 6.0.0 Beta1及以上。
4. HarmonyOS SDK版本：HarmonyOS 6.0.0 Beta1 SDK及以上。
5. 不支持捏合手势识别。

# ScrollComponents简介

ScrollComponents 作为高性能滑动解决方案，可以帮助开发者在长列表、瀑布流等复杂页面场景下实现更好的滑动流畅度。

底座通过使用自定义复用池解决复杂场景下组件复用的效率问题，相比原生的Reusable组件复用效率更高。

开发者无需关注复杂的组件复用池管理和其它性能优化方案的交互细节，使用少量的代码即可快速实现高性能滑动的开发体验。

# 特性

- 支持长列表页面的流畅滑动；
- 默认懒加载；
- 支持组件分帧预创建，帮助开发者减少组件单帧耗时；
- 支持跨页面共享复用池，减少页面打开后的滑动丢帧；
- 支持内容动态预加载，减少滑动过程中的白块问题；

# FAQ

[查看详情](https://gitcode.com/openharmony-sig/scroll_components/blob/master/docs/FAQ.md)

# 原理介绍

[查看详情](https://gitcode.com/openharmony-sig/scroll_components/blob/master/README.md#%E5%8E%9F%E7%90%86%E4%BB%8B%E7%BB%8D)

# 开源协议

本项目基于 [Apache License 2.0](./LICENSE) ，请自由地享受和参与开源。