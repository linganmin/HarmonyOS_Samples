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

import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../common/constants/CommonConstants'
import { StickyWaterFlowDataSource } from '../viewmodel/StickyWaterFlowDataSource'
import MediaItem, { ItemType } from '../model/MediaItem';

const TAG = 'StickyPage';

@Component
struct FlowVideoItem {
  @Prop item: MediaItem;
  controller: VideoController = new VideoController();

  aboutToReuse(params: Record<string, MediaItem>) {
    this.item = params.item as MediaItem;
  }

  build() {
    if (this.item.type === ItemType.VIDEO) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Video({ src: this.item.videoUri, previewUri: this.item.videoCover, controller: this.controller })
          .controls(false)
          .muted(true)
          .loop(true)
          .borderRadius($r('app.float.sections_item_radius'))
          .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
            if (isVisible && currentRatio >= 1.0) {
              this.controller.start();
            }
            if (!isVisible || currentRatio < 1.0) {
              this.controller.pause();
            }
          })
        Text('NO. ' + (this.item.id + 1))
          .fontSize($r('app.float.sections_item_text_size'))
          .fontColor(Color.White)
          .margin({
            left: $r('app.float.sections_item_text_margin_left'),
            bottom: $r("app.float.sections_item_text_margin_bottom")
          })
      }
    } else {
      RelativeContainer() {
        Image(this.item.imageUri)
          .objectFit(ImageFit.Cover)
          .width(CommonConstants.FULL_WIDTH)
          .layoutWeight(1)
          .borderRadius($r('app.float.sections_item_radius'))
          .alignRules({
            top: { anchor: '__container__', align: VerticalAlign.Top },
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start },
            right: { anchor: '__container__', align: HorizontalAlign.End }
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
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .id('mask')

        Text('NO. ' + (this.item.id + 1))
          .fontSize($r('app.float.sections_item_text_size'))
          .fontColor(Color.White)
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .margin({
            left: $r('app.float.sections_item_text_margin_left'),
            bottom: $r("app.float.sections_item_text_margin_bottom")
          })
          .id('text')
      }
      .width(CommonConstants.FULL_WIDTH)
      .borderRadius($r('app.float.sections_item_radius'))
      .backgroundColor(Color.Gray)
    }
  }
}

@Preview
@Component
export struct StickyPage {
  @State arr: number[] = CommonConstants.ARR;
  @State colors: number[] = CommonConstants.COLORS;
  @State scrollOffset: number = 0;
  @State minSize: number = CommonConstants.FLOW_ITEM_MIN_HEIGHT;
  @State maxSize: number = CommonConstants.FLOW_ITEM_MAX_HEIGHT;
  @State sections: WaterFlowSections = new WaterFlowSections();
  @State isFoldStatus: boolean = true;
  scroller: Scroller = new Scroller();
  dataSource: StickyWaterFlowDataSource = new StickyWaterFlowDataSource();
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];
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
        return CommonConstants.SECTION2_ITEM_SIZE;
      } else {
        return CommonConstants.SECTION3_ITEM_SIZE;
      }
    }
  };
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    onGetItemMainSizeByIndex: (index: number) => {
      return CommonConstants.SECTION4_ITEM_SIZE;
    }
  };

  getResourceStringArray(resource: Resource): Array<string> {
    let result: Array<string> = new Array<string>();
    try {
      result = this.getUIContext().getHostContext()?.resourceManager.getStringArrayValueSync(resource.id) as string[];
    } catch (e) {
      hilog.error(0x0000, TAG, `[getResourceString]getStringSync failed, error:${JSON.stringify(e)}.`);
    }
    return result;
  }

  getSize() {
    let ret = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray() {
    for (let i = 0; i < CommonConstants.REFRESH_COUNT; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear() {
    this.setItemSizeArray();
    let sectionOptions: SectionOptions[] = [];
    let count = 0;
    let oneOrTwo = 0;
    while (count < CommonConstants.REFRESH_COUNT) {
      if (oneOrTwo++ % 2 === 0) {
        sectionOptions.push(this.oneColumnSection);
        count += this.oneColumnSection.itemsCount;
      } else {
        sectionOptions.push(this.twoColumnSection);
        count += this.twoColumnSection.itemsCount;
      }
    }
    this.sections.splice(-1, 0, sectionOptions);
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        if (data === display.FoldStatus.FOLD_STATUS_FOLDED) {
          this.isFoldStatus = true;
        } else if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
          this.isFoldStatus = false;
        }
      });
    } catch (err) {
      hilog.error(0x0000, TAG, `display.on('foldStatusChange') get exception, error:${JSON.stringify(err)}.`);
    }
  }

  aboutToDisappear(): void {
    try {
      display.off('foldStatusChange');
    } catch (err) {
      hilog.error(0x0000, TAG, `display.off('foldStatusChange') get exception, error:${JSON.stringify(err)}.`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      WaterFlow({ scroller: this.scroller, sections: this.sections }) {
        LazyForEach(this.dataSource, (item: MediaItem) => {
          FlowItem() {
            if (item.id != 1) {
              FlowVideoItem({ item: item })
            }
          }
          .width(CommonConstants.FULL_WIDTH)
          .height(this.itemHeightArray[item.id % CommonConstants.REFRESH_COUNT])
          .backgroundColor(Color.White)
        }, (item: MediaItem) => item.id.toString())
      }
      .cachedCount(CommonConstants.CACHED_COUNT)
      .columnsTemplate('1fr 1fr')
      .columnsGap($r('app.float.sections_margin'))
      .rowsGap($r('app.float.sections_margin'))
      .padding({ bottom: $r('app.float.water_flow_margin_bottom') })
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.FULL_HEIGHT)
      .layoutWeight(1)
      .onScrollIndex((first: number, last: number) => {
        if (last + CommonConstants.LOAD_MORE_COUNT >= this.dataSource.totalCount()) {
          for (let i = 0; i < CommonConstants.LOAD_MORE_COUNT; i++) {
            this.dataSource.addLastItem();
          }
          this.twoColumnSection.itemsCount += CommonConstants.LOAD_MORE_COUNT;
          this.sections.update(-1, this.twoColumnSection);
        }
      })
      .onWillScroll((offset: number) => {
        this.scrollOffset = this.scroller.currentOffset().yOffset + offset;
      })

      Stack() {
        Column() {
          Scroll() {
            Row({ space: 0 }) {
              ForEach(this.getResourceStringArray($r('app.strarray.tab_titles')), (item: string) => {
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
      }
      .width(CommonConstants.FULL_WIDTH)
      .height(CommonConstants.STICKY_HEIGHT)
      .hitTestBehavior(HitTestMode.Transparent)
      .position({
        x: 0, y: this.scrollOffset >= CommonConstants.STICK_MAX_OFFSET ?
          0 : CommonConstants.STICK_MAX_OFFSET - this.scrollOffset
      })
    }
  }
}