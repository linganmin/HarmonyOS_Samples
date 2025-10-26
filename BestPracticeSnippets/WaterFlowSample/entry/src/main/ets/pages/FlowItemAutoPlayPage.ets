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

// [Start quick_start]
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConstants } from '../common/constants/CommonConstants';
import MediaItem, { ItemType } from '../model/MediaItem';
import { StickyWaterFlowDataSource } from '../model/StickyWaterFlowDataSource';

const TAG: string = 'FlowItemAutoPlayPage';

@Component
struct FlowVideoItem {
  @Prop item: MediaItem;
  controller: VideoController = new VideoController();

  aboutToReuse(params: Record<string, MediaItem>): void {
    this.item = params.item as MediaItem;
  }

  build() {
    if (this.item.type === ItemType.VIDEO) {
      Stack({ alignContent: Alignment.BottomStart }) {
        Video({ src: this.item.videoUri, previewUri: this.item.videoCover, controller: this.controller })
          .controls(false)
          .muted(true)
          .loop(true)
          .borderRadius(8)
          .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
            // 1、Slide to play the video when visible.
            if (isVisible && currentRatio >= 1.0) {
              this.controller.start();
            }
            // 2、Slide to pause the video when hidden.
            if (!isVisible || currentRatio < 1.0) {
              this.controller.pause();
            }
          })
        Text('NO. ' + (this.item.id + 1))
          .fontSize(12)
          .fontColor(Color.White)
          .margin({
            left: 8,
            bottom: 4
          })
      }
    } else {
      // [StartExclude quick_start]
      RelativeContainer() {
        Image(this.item.imageUri)
          .objectFit(ImageFit.Cover)
          .width('100%')
          .layoutWeight(1)
          .borderRadius(8)
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
          colors: [['#80000000', 0.0],
            ['#03000000', 1.0]]
        })
        .width('100%')
        .height(32)
        .borderRadius(8)
        .hitTestBehavior(HitTestMode.None)
        .alignRules({
          bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
          left: { anchor: '__container__', align: HorizontalAlign.Start },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        })
        .id('mask')

        Text('NO. ' + (this.item.id + 1))
          .fontSize(12)
          .fontColor(Color.White)
          .alignRules({
            bottom: { anchor: '__container__', align: VerticalAlign.Bottom },
            left: { anchor: '__container__', align: HorizontalAlign.Start }
          })
          .margin({
            left: 8,
            bottom: 4
          })
          .id('text')
      }
      .width('100%')
      .borderRadius(8)
      .backgroundColor(Color.Gray)

      // [EndExclude quick_start]
    }
  }
}

// [StartExclude quick_start]
@Entry
@Component
struct FlowItemAutoPlayPage {
  @State arr: number[] = [1, 2, 3, 4, 5, 6];
  @State colors: number[] = [0xFFC0CB, 0xDA70D6, 0x6B8E23, 0x6A5ACD, 0x00FFFF, 0x00FF7F];
  @State scrollOffset: number = 0;
  @State minSize: number = 80;
  @State maxSize: number = 210;
  @State sections: WaterFlowSections = new WaterFlowSections();
  @StorageProp(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  scroller: Scroller = new Scroller();
  dataSource: StickyWaterFlowDataSource = new StickyWaterFlowDataSource();
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];
  sectionMargin: Margin = {
    top: 8,
    left: 16,
    bottom: 0,
    right: 16
  };
  oneColumnSection: SectionOptions = {
    itemsCount: 3,
    crossCount: 1,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      if (index === 1) {
        return 150;
      } else {
        return 220;
      }
    }
  };
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return 270;
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

  getSize(): number {
    let ret: number = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray(): void {
    for (let i: number = 0; i < 100; i++) {
      this.itemWidthArray.push(this.getSize());
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear(): void {
    this.setItemSizeArray();
    let sectionOptions: SectionOptions[] = [];
    let count: number = 0;
    let oneOrTwo: number = 0;
    while (count < 100) {
      if (oneOrTwo++ % 2 === 0) {
        sectionOptions.push(this.oneColumnSection);
        count += this.oneColumnSection.itemsCount;
      } else {
        sectionOptions.push(this.twoColumnSection);
        count += this.twoColumnSection.itemsCount;
      }
    }
    this.sections.splice(-1, 0, sectionOptions);
  }

  build() {
    Column() {
      Row() {
        Text($r('app.string.scroll_stop_auto_play'))
          .width('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: '18vp', left: '16vp', bottom: '16vp' })
      }

      WaterFlow({ scroller: this.scroller, sections: this.sections }) {
        LazyForEach(this.dataSource, (item: MediaItem) => {
          FlowItem() {
            FlowVideoItem({ item: item })
          }
          .width('100%')
          .height(this.itemHeightArray[item.id % 100])
          .backgroundColor(Color.White)
        }, (item: MediaItem) => item.id.toString())
      }
      .cachedCount(12)
      .columnsTemplate('1fr 1fr')
      .columnsGap(8)
      .rowsGap(8)
      .width('100%')
      .height('100%')
      .layoutWeight(1)
    }
    .padding({
      top: this.statusBarHeight
    })
  }
}

// [EndExclude quick_start]
// [End quick_start]