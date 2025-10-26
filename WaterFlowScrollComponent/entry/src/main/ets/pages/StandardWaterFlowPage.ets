/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// [Start quick_start_3]
// [Start quick_start_1]
import { NodeItem, RecyclerView, WaterFlowManager } from '@hadss/scroll_components';
// [End quick_start_1]
// [End quick_start_3]
import { LengthMetrics, typeNode, window } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../common/constants/CommonConstants';
import { Logger } from '../common/util/Logger';
import { BlogData, Params } from '../model/types';

@Concurrent
async function generateRandomBlogData(): Promise<BlogData[]> {
  const module = await import('../model/mock');
  return module.generateRandomBlogData(300, true);
}

// [Start quick_start_4_a]
// [Start quick_start_1]
class MyWaterFlowManager extends WaterFlowManager {
  onWillCreateItem(index: number, data: BlogData) {
    // [StartExclude quick_start_1]
    let node: NodeItem<Params> | null = this.dequeueReusableNodeByType('StandardGridImageContainer');
    node?.setData({ blogItem: data });
    return node;
    // [EndExclude quick_start_1]
  }
}
// [End quick_start_1]
// [End quick_start_4_a]

// [Start quick_start_4_a]
// [Start quick_start_1]
// [Start quick_start_3]
@Entry
@Component
struct StandardWaterFlowPage {
  waterFlowView: MyWaterFlowManager = new MyWaterFlowManager({
    defaultNodeItem: 'StandardGridImageContainer',
    context: this.getUIContext()
  });
  // [StartExclude quick_start_4_a]
  // [StartExclude quick_start_3]
  // [StartExclude quick_start_1]
  scroller: Scroller = new Scroller();
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private windowClass = (this.context as common.UIAbilityContext).windowStage.getMainWindowSync();
  // [EndExclude quick_start_3]
  @State dataArray: BlogData[] = [] // Bind data source for data iteration
  // [EndExclude quick_start_4_a]

  // [Start Column_Change]
  aboutToAppear(): void {
    // [StartExclude quick_start_4_a]
    // [StartExclude quick_start_3]
    let orientation = window.Orientation.AUTO_ROTATION;
    this.windowClass.setPreferredOrientation(orientation, (err: BusinessError) => {
      const errCode: number = err.code;
      if (errCode) {
        Logger.error('Failed to set window orientation. Cause:' + JSON.stringify(err));
        return;
      }
      Logger.info('Succeed to setting window orientation');
    })
    this.windowClass.on('windowSizeChange', (size) => {
      let viewWidth = size.width;
      let viewHeight = size.height;

      let node = this.waterFlowView.__VIEW_CONTROLLER__.parentLayout as typeNode.WaterFlow;
      if (viewWidth > viewHeight) {
        node.attribute.columnsTemplate('1fr 1fr 1fr');
      } else {
        node.attribute.columnsTemplate('1fr 1fr');
      }
    })
    this.initView();
    // [StartExclude Column_Change]
    // [EndExclude quick_start_3]
    generateRandomBlogData().then((data: BlogData[]) => {
      this.waterFlowView.setDataSource(data);
      this.dataArray = data;
    });
    // [EndExclude quick_start_4_a]
    this.waterFlowView.registerNodeItem('StandardGridImageContainer', wrapBuilder(StandardGridImageContainer));
    // [StartExclude quick_start_4_a]
    // [StartExclude quick_start_3]
    this.waterFlowView.preCreate('StandardGridImageContainer', 30);

    // [Start Delete_2]
    // [Start AnimateTo]
    this.context.eventHub.on(CommonConstants.EVENT_REMOVE_ITEM, (blogItem: BlogData) => {

      let foundIndex =
        this.dataArray.findIndex((value: BlogData) => JSON.stringify(value) ===
        JSON.stringify(blogItem))
      if (foundIndex !== CommonConstants.NOT_FOUND_INDEX) {
        this.getUIContext().animateTo({ duration: 200 }, () => {
          this.waterFlowView.nodeAdapter.deleteData(foundIndex)
        })
      }
    })
    // [End AnimateTo]
    // [End Delete_2]
    // [EndExclude quick_start_3]
    // [EndExclude quick_start_4_a]
    // [EndExclude Column_Change]
  }
  // [End Column_Change]

  // [StartExclude quick_start_4_a]
  // [StartExclude quick_start_3]
  aboutToDisappear(): void {
    this.context.eventHub.off(CommonConstants.EVENT_REMOVE_ITEM)
  }
  // [Start Fading]
  // [Start Column_Change]
  initView() {
    // [Start quick_start_2]
    this.waterFlowView.setViewStyle({ scroller: this.scroller })
      .height(CommonConstants.FULL_HEIGHT)
      .columnsTemplate(CommonConstants.WATER_FLOW_COLUMNS_TEMPLATE)
      .columnsGap(CommonConstants.COLUMNS_GAP)
      .rowsGap(CommonConstants.ROWS_GAP)
      .padding({
        top: CommonConstants.PADDING,
        left: CommonConstants.PADDING,
        right: CommonConstants.PADDING
      })
      .fadingEdge(true, { fadingEdgeLength: LengthMetrics.vp(80) })
    // [End quick_start_2]
  }
  // [EndExclude quick_start_3]
  // [End Column_Change]
  // [End Fading]
  build() {
    Column() {
      // [StartExclude quick_start_3]
      // Header navigation bar.
      Row({ space: 8 }) {
        Text($r('app.string.scenario_waterFlow'))
          .fontWeight(FontWeight.Bold)
          .fontSize($r('app.float.title_font_size'))
          .width(CommonConstants.FULL_WIDTH)
          .fontColor($r('app.color.text_color'))
      }
      .padding(CommonConstants.PADDING)
      .width(CommonConstants.FULL_WIDTH)
      .backgroundColor(Color.White)
      // [EndExclude quick_start_3]

      RecyclerView({
        viewManager: this.waterFlowView
      })

    }
    .height(CommonConstants.FULL_HEIGHT)
    .backgroundColor($r('app.color.home_background_color'))
  }
  // [EndExclude quick_start_1]
  // [EndExclude quick_start_4_a]
}
// [End quick_start_1]
// [End quick_start_3]
// [End quick_start_4_a]

// [Start quick_start_4_a]
// [Start quick_start_3]
// Define an item template
@Builder
function StandardGridImageContainer($$: Params) {
  GridImageView({ blogItem: $$.blogItem })
}
// [End quick_start_3]
// [End quick_start_4_a]

@Component
struct GridImageView {
  @State blogItem: BlogData = new BlogData();
  @State showMenu: boolean = false;
  @State flowHeight: Length = 0;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  // In reusable components, you must use aboutToReuse to update data, just like native recycling.
  aboutToReuse(params: ESObject): void {
    this.blogItem = params.blogItem;
  }

  build() {
    // [Start Delete_1]
    Stack() {
      Image(this.blogItem.images[0])
        // [StartExclude Delete_1]
        .sourceSize({ width: 100, height: 100 })
        .width(CommonConstants.FULL_WIDTH)
        .aspectRatio(1)
        .objectFit(ImageFit.Cover)
        .onAreaChange((_oldValue: Area, newValue: Area) => {
          this.flowHeight = newValue.height;
        })
      // [EndExclude Delete_1]
    }
    // [StartExclude Delete_1]
    .borderRadius(12)
    .clip(true)
    .bindPopup(this.showMenu, {
      builder: this.popUpBuilder,
      placement: Placement.Top,
      mask: { color: '#33000000' },
      popupColor: Color.Yellow,
      enableArrow: true,
      showInSubWindow: false,
      onStateChange: (e) => {
        if (!e.isVisible) {
          this.showMenu = false;
        }
      }
    })
    // [EndExclude Delete_1]
    .priorityGesture(
      GestureGroup(GestureMode.Exclusive,
        LongPressGesture().onAction(() => {
          this.showMenu = true;
        }))
    )
    // [End Delete_1]
  }
  // [Start Delete_2]
  @Builder
  popUpBuilder() {
    Row({ space: 2 }) {
      Text($r('app.string.not_interested_button_text'))
    }
    .width(100)
    .height(50)
    .padding(5)
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      this.context.eventHub.emit(CommonConstants.EVENT_REMOVE_ITEM, this.blogItem)
      this.showMenu = false;
    })
  }
  // [End Delete_2]
}