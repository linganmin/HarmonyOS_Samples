# 基于ScrollComponents实现网格

## 项目简介

本示例展示了使用ScrollComponents构建网格页面，覆盖场景包括

- 网格单元格组件复用，以及跨页面的组件复用场景
- 网格加速首屏渲染的场景
- 网格数据处理场景：下拉刷新、上拉加载、长按删除
- 网格设置排列方式场景
- 网格显示数据场景
- 网格设置行列间距场景
- 网格可滚动布局场景
- 网格控制滚动位置场景
- 网格嵌套滚动场景
- 网格单元格拖拽场景
- 网格自适应和自适应列场景
- 网格以当前行最高的单元格的高度为其他单元格的高度场景
- 网格设置边缘渐隐场景
- 网格设置单元格样式场景

## 效果预览

<img src="./screenshots/img.webp" width = "320" alt="图片名称"/>

## 使用说明

1. 打开应用首页，显示场景列表。点击PhotoGridPage，实现网格单元格结构相同的组件复用场景、网格设置排列方式场景。
2. 返回首页，点击WorkGridPage，实现网格单元格结构类型不同的组件复用场景、和PhotoGridPage.ets的网格跨页面复用场景、网格下拉刷新场景、网格上拉加载更多场景、网格单元格拖拽场景、网格嵌套滚动场景、网格设置边缘渐隐场景。
3. 返回首页，点击CardGridPage，实现网格单元格内子结构可拆分组合的组件复用场景、网格加速首屏渲染场景、网格显示数据场景、网格设置行列间距场景、网格可滚动布局场景、网格设置单元格格式场景、网格长按删除单元格场景。
4. 返回首页，点击NumberGridPage，实现网格自适应场景。
5. 返回首页，点击WordGridPage，实现网格自适应列场景、网格以当前行最高的单元格高度为其他单元格高度场景

## 工程目录

```
├──entry/src/main/ets                     // 代码区
│  ├──common
│  │  ├──constants
│  │  │  └──CommonConstants.ets           // 常量
│  │  └──utils           
│  │     ├──ContextUtil.ets               // 工具
│  │     ├──Logger.ets                    // 日志
│  │     └──Utils.ets                     // 工具
│  ├──entryability
│  │  └──GridAbility.ets                  // 应用入口
│  ├──model
│  │  ├──mock.ets                         // 模拟数据
│  │  ├──types.ets                        // 数据模型
│  │  ├──PhotoModel.ets                   // 图片数据
│  │  ├──WorkModel.ets                    // 作品数据
│  │  ├──UserInfoModel.ets                // 用户信息数据
│  │  ├──NumberModel.ets                  // 数字数据
│  │  └──WordModel.ets                    // 文本数据
│  ├──view
│  │  ├──PhotoCellComponent.ets           // 图片单元格view
│  │  ├──PhotoGridComponent.ets           // 图片网格view
│  │  ├──PictureWorkComponent.ets         // 图片作品view
│  │  ├──VideoWorkComponent.ets           // 视频作品view
│  │  ├──WorkTabsComponent.ets            // 作品布局view
│  │  ├──WorkComponent.ets                // 作品网格view
│  │  ├──WorkHeadComponent.ets            // 作品页头部view
│  │  ├──CardComponent.ets                // 卡片view
│  │  ├──ManagerCardComponent.ets         // 管理员view
│  │  ├──UserCardComponent.ets            // 用户view
│  │  ├──CardGridComponent.ets            // 卡片网格view
│  │  ├──NumberCellComponent.ets          // 数字单元格view
│  │  ├──NumberGridComponent.ets          // 数字网格view
│  │  ├──WordCellComponent.ets            // 文本单元格view
│  │  └──WordGridComponent.ets            // 文本网格view
│  ├──viewModel
│  │  ├──PhotoSizeViewModel.ets           // 图片尺寸ViewModel
│  │  ├──PhotoViewModel.ets               // 图片ViewModel
│  │  ├──PhotoGridViewModel.ets           // 图片网格页ViewModel
│  │  ├──WorkViewModel.ets                // 作品ViewModel
│  │  ├──WorkGridViewModel.ets            // 作品网格页ViewModel
│  │  ├──UserInfoViewModel.ets            // 用户信息ViewModel
│  │  ├──CardGridViewModel.ets            // 卡片网格页ViewModel
│  │  ├──NumberViewModel.ets              // 数字ViewModel
│  │  ├──NumberGridViewModel.ets          // 数字网格页ViewModel
│  │  ├──WordViewModel.ets                // 文本ViewModel
│  │  └──WordGridViewModel.ets            // 文本网格页ViewModel
│  └──pages
│     ├──Index.ets                        // 导航页
│     ├──PhotoGridPage.ets                // 图片网格页
│     ├──WorkGridPage.ets                 // 作品网格页
│     ├──CardGridPage.ets                 // 卡片网格页
│     ├──NumberGridPage.ets               // 数字网格页
│     └──WordGridPage.ets                 // 文本网格页
└──entry/src/main/resources               // 应用资源目录
```

## 具体实现

1. 定义网格视图管理类，注册子节点模板  
    GridManager是网格视图管理器的基础类，可以根据业务自定义GridViewManager视图管理器进行扩展。
    ```arkts
    // entry\src\main\ets\view\WordCellComponent.ets

    @Component
    export default struct WordCell {
      @State word: WordViewModel = new WordViewModel();

      // 组件复用需要实现aboutToReuse函数
      aboutToReuse(params: Record<string, ESObject>) {
        let input = params as WordCellData;
        this.word = input.word;
      }

      build() {
        Text(this.word.value)
      }
    }
    ```
    ```arkts
    // entry\src\main\ets\view\WordGridComponent.ets

    import { GridManager, NodeItem, RecyclerView } from "@hadss/scroll_components";
    import WordCell from "./WordCellComponent";
    
    @Component
    export default struct WordGridComponent {
      // 网格视图管理器实例
      gridViewManager: GridViewManager = new GridViewManager({ defaultNodeItem: 'word', context: this.getUIContext() });
    
      aboutToAppear(): void {
        // 注册节点模板，建立标识符和builder函数的映射
        this.gridViewManager.registerNodeItem('word', wrapBuilder(buildWordCell));
      }
    }

    // 扩展实现自定义视图管理器
    class GridViewManager extends GridManager {
      
      // 根据唯一标识符获取复用节点，传递节点数据
      onWillCreateItem(index: number, data: WordViewModel) {
        let node: NodeItem<WordCellData> | null = this.dequeueReusableNodeByType('word');
        node.setData({ word: data })
        return node;
      }
    }

    @Builder
    function buildWordCell(data: ESObject) {
      WordCell({ word: data.data })
    }
    ```
2. 网格组件初始化
    ```arkts
    // entry\src\main\ets\view\WordGridComponent.ets

    aboutToAppear(): void {
      this.gridViewManager.setViewStyle()
        .alignItems(GridItemAlignment.STRETCH);

      this.gridViewManager.setViewStyle()
        .columnsTemplate('repeat(auto-fill, 70)')
        .columnsGap(5)
        .rowsGap(5);
    }
    ```
3. 设置数据源并渲染组件
    ```arkts
    // entry\src\main\ets\view\WordGridComponent.ets
    
    @Component
    export default struct WordGridComponent {
      gridViewManager: GridViewManager = new GridViewManager({ defaultNodeItem: 'word', context: this.getUIContext() });
      viewModel: WordGridViewModel = new WordGridViewModel(this.gridViewManager);

      aboutToAppear(): void {
        // viewModel加载数据
        this.viewModel.loadData();
      }

      build() {
        Column() {
          // 渲染视图组件
          RecyclerView({
            viewManager: this.gridViewManager
          })
        }
        .width('100%')
      }
    }
    ```
    ```arkts
    // entry\src\main\ets\viewModel\WordGridViewModel.ets

    async loadData() {
      setTimeout(() => {
        for (let index = 0; index < 15; index++) {
          // 模拟请求数据
          let model: WordModel = new WordModel();
          model.value = `N ${index}`;
          let viewModel: WordViewModel = new WordViewModel();
          viewModel.updateModel(model);
          this.data.push(viewModel);
        }
        // 设置数据源
        this.gridViewManager?.setDataSource(this.data);
      }, 100);
    }
    ```

## 相关权限

- 示例涉及网络资源下载，需要`ohos.permission.INTERNET`权限

## 约束与限制

1. 本示例仅支持标准系统上运行，支持设备：华为手机。
2. HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。
3. DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。
4. HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
5. 不支持设置子组件所占行列数。
6. 不支持捏合手势识别。

# ScrollComponents简介

ScrollComponents作为高性能滑动解决方案，可以帮助开发者在长列表、瀑布流等复杂页面场景下实现更好的滑动流畅度。

底座通过使用自定义复用池解决复杂场景下组件复用的效率问题，相比原生的Reusable组件复用效率更高。

开发者无需关注复杂的组件复用池管理和其它性能优化方案的交互细节，使用少量的代码即可快速实现高性能滑动的开发体验。

# 特性

- 支持网格页面的流畅滑动
- 默认支持懒加载；
- 支持组件复用，解决滑动丢帧，提升滑动性能
- 支持复用池共享，满足跨页面跨父组件复用能力
- 支持预创建，减少冷启首次滑动丢帧，提升滑动性能
- 支持预加载，滑动过程提前加载数据，提升浏览体验

# FAQ
[查看详情](https://gitcode.com/openharmony-sig/scroll_components/blob/master/docs/FAQ.md)

# 原理介绍
[查看详情](https://gitcode.com/openharmony-sig/scroll_components/blob/master/README.md#%E5%8E%9F%E7%90%86%E4%BB%8B%E7%BB%8D)

# 相关仓

[scroll_components](https://gitcode.com/openharmony-sig/scroll_components/tree/master)