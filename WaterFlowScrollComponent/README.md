# 基于ScrollComponents实现瀑布流

## 简介
本示例展示了使用ScrollComponents构建瀑布流页面，覆盖场景包括

- 瀑布流Item组件复用，以及跨页面的组件复用场景；
- 瀑布流加速首屏渲染的场景；
- 瀑布流无限滑动的场景；
- 瀑布流数据处理场景：下拉刷新、上拉加载、长按删除；
- 瀑布流分组混合布局场景；
- 瀑布流滑动吸顶场景；
- 旋转屏幕瀑布流动态切换列数场景；
- 瀑布流动效场景：边缘渐隐效果、删除滑动错位效果；

## 效果预览
<img src="./screenshots/img.gif" width = "40%" alt="图片名称"/>

## 依赖系统版本
- HarmonyOS 6.0.0 Release及以上

## 工程目录
```        
├─entry/src/main/ets
├─common
│  ├─constants
│  │  └─CommonConstants.ets
│  │
│  └─util
│     ├─Logger.ets
│     └─Utils.ets
│
├─entryability
│  └─EntryAbility.ets
│
├─entrybackupability
│  └─EntryBackupAbility.ets
│
├─model
│  ├─mock.ets
│  └─types.ets
│
├─pages
│  ├─CombineWaterFlowPage.ets           // 瀑布流列表项内子组件可拆分组合复用
│  ├─Index.ets
│  ├─MultiFlowItemPage.ets
│  ├─SharedPoolPage.ets
│  ├─SharedPoolSecondPage.ets
│  ├─StandardWaterFlowPage.ets          // 瀑布流列表项结构相同复用
│  ├─StickyWaterFlowPage.ets            // 瀑布流滑动吸顶
│  └─TabBarPage.ets                     // 瀑布流跨页面复用
│
└─workers
   ├─FetchAgent.ets
   └─GetNetworkData.ets
```

## 功能说明
1. StandardWaterFlowPage.ets：实现了列表项结构相同的组件复用、瀑布流加速首屏渲染场景，瀑布流自适应屏幕旋转动态修改列数场景、瀑布流长按删除和删除滑动错位效果场景、瀑布流边缘渐隐效果场景；
2. CombineWaterFlowPage.ets：实现了列表项内子组件可拆分组合的复用、瀑布流加速首屏渲染场景、瀑布流无限滑动场景；
3. TabBarPage.ets：实现了SharedPoolPage.ets和SharedPoolSecondPage.ets之间的跨页面复用功能, 瀑布流下拉刷新和上拉加载场景；
4. StickyWaterFlowPage.ets：实现了瀑布流滑动吸顶场景、瀑布流分组混合布局场景；


## 实现说明
> 下文介绍高效无限瀑布流页面渲染。

### 1. 定义瀑布流视图管理类，注册item节点模板
WaterFlowManager是视图管理器，开发者根据业务需要自定义视图管理器类。
- 页面初始化时，开发者自定义子节点模板和组件绑定，即可实现复用能力
- 如果使用预创建节点，需在预创建前注册节点模板

```c
// src/main/ets/pages/StandardWaterFlowPage.ets

import { NodeItem, RecyclerView } from '@hadss/scroll_components';

/**
 * item模板
 * */
@Builder
function StandardGridImageContainer($$: ESObject) {
  GridImageView({blogItem: $$.blogItem})
}

// 1. 自定义视图管理器
class MyWaterFlowManager extends WaterFlowManager {

  onWillCreateItem(index: number, data: BlogData) {
    // 3. 根据唯一标识获取复用节点，传递节点数据
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('StandardGridImageContainer');
    node?.setData({ blogItem: data });
    return node;
  }
}

@Entry
@Component
export struct StandardWaterFlowPage {
    // 视图管理器实例化
    waterFlowView: MyWaterFlowManager = new MyWaterFlowManager({
        defaultNodeItem: 'StandardGridImageContainer',
        context: this.getUIContext()
    });
    // ...

    aboutToAppear(): void {
        // ...
        this.initView();
        // 2. 注册节点模板
        this.waterFlowView.registerNodeItem('StandardGridImageContainer', wrapBuilder(StandardGridImageContainer));
    }
    // ...
}
```

### 2. WaterFlow组件初始化

```c
// src/main/ets/pages/StandardWaterFlowPage.ets

initView() {
    this.waterFlowView.setViewStyle({scroller: this.scroller})
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .columnsTemplate(CommonConstants.WATER_FLOW_COLUMNS_TEMPLATE)
      .columnsGap(CommonConstants.COLUMNS_GAP)
      .rowsGap(CommonConstants.ROWS_GAP)
      .padding(CommonConstants.PADDING)
}
```

### 3. 设置数据源渲染组件
- ScrollComponents默认支持懒加载，使用setDataSource设置普通数组即可。开发者无需繁琐的定义类似lazyForEach的Datasource数据源
- RecyclerView组件占位，绑定视图容器实例即可渲染瀑布流列表
```c
// src/main/ets/pages/StandardWaterFlowPage.ets

import { RecyclerView } from '@hadss/scroll_components';

@Observed
class BlogData{
  id: number = -1;
  images: string[] = [];
  imagePixelMap: image.PixelMap | undefined;
  // ...
}

@Entry
@Component
export struct StandardWaterFlowPage {
    waterFlowView: MyWaterFlowManager = new MyWaterFlowManager({
        defaultNodeItem: 'StandardGridImageContainer',
        context: this.getUIContext()
    });
    scroller: Scroller = new Scroller();
    @State data: BlogData[] = [];
    // ...

    aboutToAppear(): void {
        // ...
        this.initView();
        // 1. setDataSource设置瀑布流数据
        this.waterFlowView.setDataSource(data);
    }

    build() {
        Column() {
            // ...
            // 2. 绑定视图容器实例
            RecyclerView({
                viewManager: this.waterFlowView
            })
        }
    }
}
```

# ScrollComponents简介

ScrollComponents 作为高性能滑动解决方案，可以帮助开发者在长列表、瀑布流等复杂页面场景下实现更好的滑动流畅度。

底座通过使用自定义复用池解决复杂场景下组件复用的效率问题，相比原生的Reusable组件复用效率更高。

开发者无需关注复杂的组件复用池管理和其它性能优化方案的交互细节，使用少量的代码即可快速实现高性能滑动的开发体验。

# 特性
- 支持瀑布流页面的流畅滑动；
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