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

const TAG: string = 'StickOnTopPage';

// [StartExclude quick_start]
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
            if (isVisible && currentRatio >= 1.0) {
              this.controller.start();
            }
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
      }
      .width('100%')
      .borderRadius(8)
      .backgroundColor(Color.Gray)
    }
  }
}

// [EndExclude quick_start]
@Component
export struct StickyPage {
  // [StartExclude quick_start]
  @State arr: number[] = [1, 2, 3, 4, 5, 6];
  @State colors: number[] = [0xFFC0CB, 0xDA70D6, 0x6B8E23, 0x6A5ACD, 0x00FFFF, 0x00FF7F];
  @State minSize: number = 80;
  @State maxSize: number = 210;
  @State sections: WaterFlowSections = new WaterFlowSections();
  @State isFoldStatus: boolean = true;
  scroller: Scroller = new Scroller();
  dataSource: StickyWaterFlowDataSource = new StickyWaterFlowDataSource();
  private itemWidthArray: number[] = [];
  private itemHeightArray: number[] = [];
  // [EndExclude quick_start]
  // 1、Define the height of the ceiling layout.
  @State scrollOffset: number = 0;
  private stickItemHeight: number = 90;
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
        // 2、Set the ceiling layout height in the group.
        return this.stickItemHeight;
      } else {
        return 200;
      }
    }
  };
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return 250;
    }
  };

  // [StartExclude quick_start]
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

  // [EndExclude quick_start]
  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      WaterFlow({ scroller: this.scroller, sections: this.sections }) {
        LazyForEach(this.dataSource, (item: MediaItem) => {
          FlowItem() {
            // 3、A location is reserved for the ceiling part, and the ceiling position is at the second element location, so the id is 1.
            FlowVideoItem({ item: item })
          }
          .width('100%')
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
      .onWillScroll((offset: number) => {
        // 4、Listen to the waterfall scrolling event.
        this.scrollOffset = this.scroller.currentOffset().yOffset + offset;
      })

      Stack() {
        // [StartExclude quick_start]
        Column() {
          Scroll() {
            Row({ space: 0 }) {
              ForEach(this.getResourceStringArray($r('app.strarray.tab_titles')), (item: string) => {
                Row() {
                  Text(item)
                    .constraintSize({ minWidth: 56 })
                    .textAlign(TextAlign.Center)
                    .fontSize(14)
                    .fontColor(Color.Black)
                    .padding({ left: 16, right: 16 })
                    .height('100%')
                    .backgroundColor('#12000000')
                    .borderRadius(21)
                }
                .padding({
                  top: 0,
                  bottom: 0,
                  left: 0,
                  right: 8
                })
                .justifyContent(FlexAlign.Center)
                .height(36)
                .align(Alignment.Center)
              }, (item: string) => item.toString())
            }
            .padding({
              left: 16,
              right: 16
            })
          }
          .width('100%')
          .scrollBar(BarState.Off)
          .scrollable(ScrollDirection.Horizontal)
          .backgroundColor(Color.White)
          .padding({ top: 8 })

          Row() {
            Select([{ value: $r('app.string.distance') },
              { value: '<1km' },
              { value: '<5km' },
              { value: '>5km' }])
              .selected(1)
              .value($r('app.string.distance'))
              .font({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .fontColor(Color.Black)
              .selectedOptionFont({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .optionFont({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .backgroundColor('#12000000')
            Select([{ value: $r('app.string.category') },
              { value: $r('app.string.food') },
              { value: $r('app.string.leisure') },
              { value: $r('app.string.amusement') }])
              .selected(1)
              .value($r('app.string.category'))
              .font({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .fontColor(Color.Black)
              .selectedOptionFont({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .optionFont({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .backgroundColor('#12000000')
              .margin({ left: 8 })
            Select([{ value: $r('app.string.sort') },
              { value: '1' },
              { value: '2' },
              { value: '3' }])
              .selected(1)
              .value($r('app.string.sort'))
              .font({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .fontColor(Color.Black)
              .selectedOptionFont({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .optionFont({
                size: 16,
                family: 'serif',
                style: FontStyle.Normal
              })
              .backgroundColor('#12000000')
              .margin({ left: 8 })

          }
          .justifyContent(this.isFoldStatus ? FlexAlign.Start : FlexAlign.Center)
          .backgroundColor(Color.White)
          .width('100%')
          .padding({
            top: 8,
            bottom: 8,
            left: 16,
            right: 16
          })
        }.alignItems(HorizontalAlign.Start)

        // [EndExclude quick_start]
      }
      .width('100%')
      .height(100)
      .backgroundColor(Color.White)
      .hitTestBehavior(HitTestMode.Transparent)
      // 5、Dynamically adjust the sticky position according to the waterfall flow sliding offset.
      .position({ x: 0, y: this.scrollOffset >= 210 ? 0 : 210 - this.scrollOffset })
    }
  }
}

// [StartExclude quick_start]
@Entry
@Component
struct StickOnTopPage {
  @State currentIndex: number = 0;
  @State changeValue: string = '';
  @State tabsIndex: number = 0;
  tabsController: TabsController = new TabsController();
  controller: SearchController = new SearchController();
  @StorageProp(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT) statusBarHeight: number = 0;

  @Builder
  tabBuilder(index: number, name: string | Resource): void {
    Row() {
      Text(name)
        .constraintSize({ minWidth: 56 })
        .textAlign(TextAlign.Center)
        .fontSize(14)
        .fontColor(this.tabsIndex === index ? Color.White : Color.Black)
        .height('100%')
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.tabsIndex === index ? '#0A59F7' : '#12000000')
        .borderRadius(21)
    }
    .padding({
      top: 10,
      bottom: 10,
      left: 16,
      right: 16
    })
    .justifyContent(FlexAlign.Center)
    .height(56)
    .align(Alignment.Center)
    .onClick(() => {
      this.tabsIndex = index;
      this.tabsController.changeIndex(index);
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.ic_public_arrow_left'))
          .width(40)
          .height(40)
          .padding(8)
          .borderRadius(21)
          .backgroundColor('#10000000')
          .onClick(() => {
            this.getUIContext().getRouter().back();
          })
        Search({ value: this.changeValue, placeholder: '', controller: this.controller })
          .searchButton('search')
          .layoutWeight(1)
          .margin({ left: 8 })
          .backgroundColor('#10000000')
      }
      .margin({
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      })

      Tabs({ index: this.currentIndex, controller: this.tabsController }) {
        TabContent() {
          StickyPage()
        }
        .tabBar(this.tabBuilder(0, $r('app.string.synthesis')))

        TabContent() {
          StickyPage()
        }
        .tabBar(this.tabBuilder(1, $r('app.string.businesses')))

        TabContent() {
          StickyPage()
        }
        .tabBar(this.tabBuilder(2, $r('app.string.note')))

        TabContent() {
          StickyPage()
        }
        .tabBar(this.tabBuilder(3, $r('app.string.buy')))

        TabContent() {
          StickyPage()
        }
        .tabBar(this.tabBuilder(4, $r('app.string.user')))

        TabContent() {
          StickyPage()
        }
        .tabBar(this.tabBuilder(5, $r('app.string.other')))
      }
      .scrollable(true)
      .barMode(BarMode.Scrollable)
      .onChange((index: number) => {
        this.tabsIndex = index;
      })
    }
    .padding({
      top: this.statusBarHeight
    })
  }
}

// [EndExclude quick_start]
// [End quick_start]