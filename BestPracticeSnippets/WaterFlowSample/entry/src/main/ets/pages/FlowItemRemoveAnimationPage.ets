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
import { hilog } from "@kit.PerformanceAnalysisKit";
import { CommonConstants } from "../common/constants/CommonConstants";
import { SectionsWaterFlowDataSource } from "../model/SectionsWaterFlowDataSource";

const TAG: string = 'FlowItemRemoveAnimationPage';

// [StartExclude quick_start]
@Reusable
struct ReusableFlowItem {
  @State item: number = 0;

  aboutToReuse(params: Record<string, number>): void {
    this.item = params.item;
  }

  build() {
    RelativeContainer() {
      Image($rawfile(`sections/${this.item % 4}.jpg`))
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

      Text('NO. ' + (this.item + 1))
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

// [EndExclude quick_start]
@Entry
@Component
struct FlowItemRemoveAnimationPage {
  // [StartExclude quick_start]
  @State currentItem: number = -1;
  @State isRefreshing: boolean = false;
  @State minSize: number = 80;
  @State maxSize: number = 180;
  scroller: Scroller = new Scroller();
  dataSource: SectionsWaterFlowDataSource = new SectionsWaterFlowDataSource();
  private itemHeightArray: number[] = [];
  @State sections: WaterFlowSections = new WaterFlowSections();
  @StorageProp(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  sectionMargin: Margin = {
    top: 8,
    left: 16,
    bottom: 0,
    right: 16
  };
  oneColumnSection: SectionOptions = {
    itemsCount: 3,
    crossCount: 1,
    columnsGap: 5,
    rowsGap: 10,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return 170;
    }
  }
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return 100;
    }
  }
  dataSection: SectionOptions = {
    itemsCount: 20,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return this.itemHeightArray[index % 100];
    }
  }

  @Builder
  headerRefresh(): void {
    Column() {
      LoadingProgress()
        .color(Color.Black)
        .opacity(0.6)
        .width(36)
        .height(36)
    }
    .justifyContent(FlexAlign.Center)
  }

  refresh(): void {
    this.currentItem = -1;
    setTimeout(() => {
      // Add new data.
      this.dataSource.dataArray = [];
      let value: number = Math.floor(Math.random() * 100);
      for (let i: number = 0; i < 100; i++) {
        this.dataSource.dataArray.push(i + value);
        this.dataSource.notifyDataAdd(i);
      }
      // Update sections itemsCount.
      this.oneColumnSection.itemsCount = 3;
      this.oneColumnSection.crossCount = 1;
      this.twoColumnSection.itemsCount = 2;
      this.twoColumnSection.crossCount = 2;
      this.dataSection.itemsCount = 95;
      this.dataSection.crossCount = 2;
      this.sections.update(0, this.oneColumnSection);
      this.sections.update(1, this.twoColumnSection);
      this.sections.update(2, this.dataSection);
      this.isRefreshing = false;
    }, 2000);
  }

  getSize(): number {
    let ret: number = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray(): void {
    for (let i: number = 0; i < 100; i++) {
      this.itemHeightArray.push(this.getSize());
    }
  }

  initSections(): void {
    let sectionOptions: SectionOptions[] = [];
    let count: number = 0;
    let oneOrTwo: number = 0;
    let dataCount: number = this.dataSource.totalCount();
    while (count < dataCount) {
      if (dataCount - count < 96) {
        this.dataSection.itemsCount = dataCount - count;
        sectionOptions.push(this.dataSection);
        break;
      }
      if (oneOrTwo++ % 2 === 0) {
        sectionOptions.push(this.oneColumnSection);
        count += this.oneColumnSection.itemsCount;
      } else {
        sectionOptions.push(this.twoColumnSection);
        count += this.twoColumnSection.itemsCount;
      }
    }
    this.sections.splice(0, 0, sectionOptions);
  }

  aboutToAppear(): void {
    this.setItemSizeArray();
    this.initSections();
  }

  removeItem(item: number): void {
    let index: number = this.dataSource.indexOf(item);
    this.dataSource.deleteItem(index);
    const sections: Array<SectionOptions> = this.sections.values();
    let newSection: SectionOptions;
    let tmpIndex: number = 0;
    let sectionIndex: number = 0;
    for (let i: number = 0; i < sections.length; i++) {
      tmpIndex += sections[i].itemsCount;
      if (index < tmpIndex) {
        sectionIndex = i;
        break;
      }
    }
    newSection = sections[sectionIndex];
    newSection.itemsCount -= 1;
    if (newSection.crossCount && newSection.crossCount > newSection.itemsCount) {
      newSection.crossCount = newSection.itemsCount;
    }
    this.sections.update(sectionIndex, newSection);
  }

  // [EndExclude quick_start]
  build() {
    Column({ space: 0 }) {
      Refresh({ refreshing: $$this.isRefreshing, builder: this.headerRefresh() }) {
        WaterFlow({ scroller: this.scroller, sections: this.sections }) {
          LazyForEach(this.dataSource, (item: number) => {
            FlowItem() {
              Stack() {
                Row() {
                  Button($r('app.string.delete'))
                    .fontColor(Color.Red)
                    .backgroundColor(Color.White)
                    .onClick(() => {
                      // 2、Execute the animateTo animation when triggering the delete operation.
                      try {
                        this.getUIContext().animateTo({ duration: 300 }, () => {
                          this.removeItem(item);
                        });
                      } catch (err) {
                        hilog.error(0x0000, TAG, `animateTo get exception, error:${JSON.stringify(err)}.`);
                      }
                    })
                }
                // [StartExclude quick_start]
                .width('100%')
                .height('100%')
                .borderRadius(8)
                .justifyContent(FlexAlign.Center)
                .zIndex(1)
                .visibility(this.currentItem === item ? Visibility.Visible : Visibility.Hidden)
                .backgroundColor('#33000000')

                ReusableFlowItem({ item: item })
                // [EndExclude quick_start]
              }
            }
            // 1、Add a transition property to FlowItem and configure the transition parameters.
            .transition({ type: TransitionType.Delete, opacity: 0 })
            .priorityGesture(LongPressGesture()
              .onAction(() => {
                this.currentItem = item;
              }))
            .width('100%')
            .borderRadius(8)
            .backgroundColor(Color.Gray)
          }, (item: string) => item)
        }
        // [StartExclude quick_start]
        .cachedCount(12)
        .columnsGap(8)
        .rowsGap(8)
        .width('100%')
        .height('100%')
        .layoutWeight(1)
        // For better experience, pre load data.
        .onScrollIndex((first: number, last: number) => {
          setTimeout(() => {
            let totalCount: number = this.dataSource.totalCount();
            if (last + 20 >= totalCount) {
              for (let i: number = 0; i < 20; i++) {
                this.dataSource.addLastItem();
              }
              // Update sections itemsCount.
              this.dataSection.itemsCount += 20;
              this.sections.update(2, this.dataSection);
            }
          }, 1000);
        })

        // [EndExclude quick_start]
      }
      // [StartExclude quick_start]
      .refreshOffset(56)
      .onRefreshing(() => {
        this.refresh();
      })

      // [EndExclude quick_start]
    }
    .padding({
      top: this.statusBarHeight
    })
  }
}

// [End quick_start]