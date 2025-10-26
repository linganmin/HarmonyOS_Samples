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

import { display, typeNode } from '@kit.ArkUI';
import { NodeItem, RecyclerView, WaterFlowManager } from '@hadss/scroll_components';
import { CommonConstants } from '../common/constants/CommonConstants'
import { Logger } from '../common/util/Logger';
import { isChinese } from '../model/mock';
import { BusinessError } from '@kit.BasicServicesKit'

interface Params3 {
  item: number
}

class MyWaterFlowManager extends WaterFlowManager {
  onWillCreateItem(index: number, data: Params3): NodeItem {
    let nodeItem: NodeItem = this.dequeueReusableNodeByType('StickyBlogItemContainer')
    nodeItem?.setData({ item: data })
    return nodeItem;
  }
}

@Component
struct StickyFlowItem {
  @State item: number = 0;

  // In reusable components, you must use aboutToReuse to update data, just like native recycling.
  aboutToReuse(params: ESObject): void {
    this.item = params.item
  }

  build() {
    if (this.item !== 1) {
      RelativeContainer() {
        Image($rawfile(`sections/${this.item % 4}.jpg`))
          .objectFit(ImageFit.Cover)
          .width(CommonConstants.FULL_WIDTH)
          .layoutWeight(1)
          .borderRadius($r('app.float.sections_item_radius'))
          .alignRules({
            top: { anchor: "__container__", align: VerticalAlign.Top },
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            left: { anchor: "__container__", align: HorizontalAlign.Start },
            right: { anchor: "__container__", align: HorizontalAlign.End }
          })
          .id('image')

        Stack() {
        }
        .linearGradient({
          angle: 0,
          colors: [[$r('app.color.linearGradient_first_color'), 0.0],
            [$r('app.color.linearGradient_last_color'), 1.0]]
        })
        .width(CommonConstants.FULL_WIDTH)
        .height($r('app.float.sections_item_blur_height'))
        .borderRadius($r('app.float.sections_item_radius'))
        .hitTestBehavior(HitTestMode.None)
        .alignRules({
          bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
          left: { anchor: "__container__", align: HorizontalAlign.Start },
          right: { anchor: "__container__", align: HorizontalAlign.End }
        })
        .id('mask')

        Text($r('app.string.want_to_eat'))
          .fontSize($r('app.float.sections_item_text_size'))
          .fontColor(Color.White)
          .alignRules({
            bottom: { anchor: "__container__", align: VerticalAlign.Bottom },
            middle: { anchor: "__container__", align: HorizontalAlign.Center }
          })
          .margin({ bottom: $r("app.float.sections_item_center_text_margin_bottom") })
          .id('text')
      }
    }
  }
}

@Builder
function StickyBlogItemContainer(param: Params3) {
  StickyFlowItem({ item: param.item })
}

@Entry
@Component
struct StickyWaterFlowPage {
  waterFlowView: MyWaterFlowManager =
    new MyWaterFlowManager({ defaultNodeItem: 'StickyBlogItemContainer', context: this.getUIContext() })
  @State arr: number[] = CommonConstants.ARR;
  @State colors: number[] = CommonConstants.COLORS;
  @State scrollOffset: number = 0;
  @State minSize: number = 80;
  @State maxSize: number = 180;
  // [Start Section]
  @State sections: WaterFlowSections = new WaterFlowSections();
  // [End Section]
  @State isFoldStatus: boolean = true;
  scroller: Scroller = new Scroller();
  dataCount: number = 100;
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];
  // [Start Section]
  oneColumnSection: SectionOptions = {
    itemsCount: 3,
    crossCount: 1,
    columnsGap: 5,
    rowsGap: 10,
    margin: {
      top: 8,
      left: 0,
      bottom: 8,
      right: 0
    },
    onGetItemMainSizeByIndex: (index: number) => {
      if (index === 1) {
        return 100;
      } else {
        return 200;
      }
    }
  };
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    onGetItemMainSizeByIndex: () => {
      return 250;
    }
  };
  // [End Section]

  getResourceStringArray(resource: Resource): Array<string> {
    let result: Array<string> = new Array<string>();
    try {
      result = this.getUIContext().getHostContext()?.resourceManager.getStringArrayValueSync(resource.id) as string[];
    } catch (e) {
      Logger.error(`[getResourceString]getStringSync failed, error:${JSON.stringify(e)}.`);
    }
    return result;
  }

  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray() {
    for (let i = 0; i < 100; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear() {
    this.setItemSizeArray();
    this.initView();

    let dataArray: number[] = [];
    for (let i = 0; i < 100; i++) {
      dataArray.push(i)
    }
    this.waterFlowView.setDataSource(dataArray)
    this.waterFlowView.registerNodeItem('StickyBlogItemContainer', wrapBuilder(StickyBlogItemContainer))
    this.waterFlowView.preCreate('StickyBlogItemContainer', 30)

    if (canIUse("SystemCapability.Window.SessionManager")) {
      try {
        display.on('foldStatusChange', (data: display.FoldStatus) => {
          if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
            this.isFoldStatus = true;
          } else if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
            this.isFoldStatus = false;
          }
        });
      } catch (err) {
        const error = err as BusinessError;
        Logger.error(`Display on foldStatusChange failed. code = ${error.code}, message = ${error.message}`)
      }
    }
  }

  // [Start Section_2]
  initView() {
    let sectionOptions: SectionOptions[] = [];
    let count = 0;
    let oneOrTwo = 0;
    while (count < this.dataCount) {
      if (oneOrTwo++ % 2 == 0) {
        sectionOptions.push(this.oneColumnSection);
        count += this.oneColumnSection.itemsCount;
      } else {
        sectionOptions.push(this.twoColumnSection);
        count += this.twoColumnSection.itemsCount;
      }
    }
    this.sections.splice(-1, 0, sectionOptions);
    // [Start Stick]
    // [Start Section_3]
    this.waterFlowView.setViewStyle({ scroller: this.scroller, sections: this.sections })
      // [StartExclude Stick]
      // [StartExclude Section_3]
      // [StartExclude Section_2]
      .columnsTemplate('1fr 1fr')
      .columnsGap(CommonConstants.COLUMNS_GAP)
      .rowsGap(CommonConstants.ROWS_GAP)
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        // [EndExclude Section_3]
      .onScrollIndex((_first: number, last: number) => {
        if (last + 20 >= this.waterFlowView.nodeAdapter.totalNodeCount) {
          let dataArray: number[] = [];
          for (let i = 0; i < 100; i++) {
            dataArray.push(i)
          }
          // update data when the page is scrolling.
          this.waterFlowView.nodeAdapter.pushData(dataArray)
          let newSection: SectionOptions = {
            itemsCount: 100,
            crossCount: 2,
            onGetItemMainSizeByIndex: () => {
              return 100;
            }
          }
          // update section
          this.sections.push(newSection);
          let waterFlow = this.waterFlowView.__VIEW_CONTROLLER__.parentLayout as typeNode.WaterFlow;
          waterFlow.initialize({
            scroller: this.scroller, // it's very important to do initialize that makes section update.
            sections: this.sections,
          })
        }
      })
      // [EndExclude Stick]
      // [StartExclude Section_3]
      .onWillScroll((offset: number) => {
        // Dynamically get the offset position of a waterfall flow
        this.scrollOffset = this.scroller.currentOffset().yOffset + offset;
      })
      // [EndExclude Section_3]
      // [EndExclude Section_2]
    // [End Section_3]
    // [End Stick]

    // [StartExclude Section_2]
    this.waterFlowView.setItemViewStyle((flowItem, _index, item: number) => {
      flowItem().width(CommonConstants.FULL_WIDTH)
        .height(this.itemHeightArray[item % 100])
        .backgroundColor(Color.White)
    })
    // [EndExclude Section_2]
  }
  // [End Section_2]

  aboutToDisappear(): void {
    if (canIUse("SystemCapability.Window.SessionManager")) {
      try {
        display.off('foldStatusChange');
      } catch (err) {
        const error = err as BusinessError;
        Logger.error(`Display off foldStatusChange failed. code = ${error.code}, message = ${error.message}`)
      }
    }
  }
  // [Start Stick]
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      RecyclerView({
        viewManager: this.waterFlowView
      })
      Stack() {
        // [StartExclude Stick]
        Column() {
          Scroll() {
            Row({ space: 0 }) {
              ForEach(isChinese() ? this.getResourceStringArray($r('app.strarray.tab_titles')) : this.getResourceStringArray($r('app.strarray.tab_titles_en')), (item: string) => {
                Row() {
                  Text(item)
                    .constraintSize({ minWidth: $r('app.float.tab_height') })
                    .textAlign(TextAlign.Center)
                    .fontSize($r('app.float.tab_font_size'))
                    .fontColor(Color.Black)
                    .padding({
                      left: $r('app.float.tab_text_padding_left'),
                      right: $r('app.float.tab_text_padding_right')
                    })
                    .height(CommonConstants.FULL_HEIGHT)
                    .backgroundColor($r('app.color.sections_tab_color_normal'))
                    .borderRadius($r('app.float.sections_tab_radius'))
                }
                .padding({
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: $r('app.float.tab_padding_right')
                })
                .justifyContent(FlexAlign.Center)
                .height($r('app.float.sections_sticky_tab_height'))
                .align(Alignment.Center)
              }, (item: string) => item.toString())
            }
          }
          .width(CommonConstants.FULL_WIDTH)
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .backgroundColor(Color.White)
          .padding({ top: $r('app.float.sections_margin') })

          Row() {
            Select([{ value: $r('app.string.distance') },
              { value: $r('app.string.less_1km') },
              { value: $r('app.string.less_5km') },
              { value: $r('app.string.more_5km') }])
              .selected(1)
              .value($r('app.string.distance'))
              .font({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .fontColor(Color.Black)
              .selectedOptionFont({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .optionFont({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .backgroundColor($r('app.color.sections_tab_color_normal'))
            Select([{ value: $r('app.string.classify') },
              { value: $r('app.string.food') },
              { value: $r('app.string.leisure') },
              { value: $r('app.string.entertainment') }])
              .selected(1)
              .value($r('app.string.classify'))
              .font({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .fontColor(Color.Black)
              .selectedOptionFont({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .optionFont({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .backgroundColor($r('app.color.sections_tab_color_normal'))
              .margin({ left: $r('app.float.sections_margin') })
            Select([{ value: $r('app.string.sort') },
              { value: $r('app.string.one') },
              { value: $r('app.string.two') },
              { value: $r('app.string.three') }])
              .selected(1)
              .value($r('app.string.sort'))
              .font({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .fontColor(Color.Black)
              .selectedOptionFont({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .optionFont({
                size: $r('app.float.sections_sticky_select_text_size'),
                family: 'serif',
                style: FontStyle.Normal
              })
              .backgroundColor($r('app.color.sections_tab_color_normal'))
              .margin({ left: $r('app.float.sections_margin') })
          }
          .justifyContent(this.isFoldStatus ? FlexAlign.Start : FlexAlign.Center)
          .backgroundColor(Color.White)
          .width(CommonConstants.FULL_WIDTH)
          .padding({ top: $r('app.float.sections_margin'), bottom: $r('app.float.sections_margin') })
        }.alignItems(HorizontalAlign.Start)
        // [EndExclude Stick]
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(100)
      .padding({ left: CommonConstants.PADDING, right: CommonConstants.PADDING })
      .backgroundColor(Color.White)
      .hitTestBehavior(HitTestMode.Transparent)
      // Set the sticky component's offset.
      .position({ x: 0, y: this.scrollOffset >= 220 ? 0 : 220 - this.scrollOffset })
    }
  }
  // [End Stick]
}