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
import { CommonConstants } from "../common/constants/CommonConstants";
import { SectionsWaterFlowDataSource } from "../model/SectionsWaterFlowDataSource";

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
struct SectionOptionsUsePage {
  // [StartExclude quick_start]
  @State minSize: number = 120;
  @State maxSize: number = 260;
  scroller: Scroller = new Scroller();
  // [EndExclude quick_start]
  dataSource: SectionsWaterFlowDataSource = new SectionsWaterFlowDataSource();
  private itemHeightArray: number[] = [];
  sectionMargin: Margin = {
    top: 8,
    left: 16,
    bottom: 0,
    right: 16
  }
  // 1、Create group information.
  @State sections: WaterFlowSections = new WaterFlowSections();
  @StorageProp(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  // 2、Create the first group.
  oneColumnSection: SectionOptions = {
    itemsCount: 3,
    crossCount: 1,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return 120;
    }
  }
  // 3、Create the second group.
  twoColumnSection: SectionOptions = {
    itemsCount: 2,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return 160;
    }
  }
  // 4、Create the third group.
  dataSection: SectionOptions = {
    itemsCount: 20,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return this.itemHeightArray[index % 100];
    }
  }

  // [StartExclude quick_start]
  getSize(): number {
    let ret: number = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray(): void {
    for (let i: number = 0; i < 100; i++) {
      this.itemHeightArray.push(this.getSize());
    }
  }

  // [EndExclude quick_start]

  aboutToAppear(): void {
    this.setItemSizeArray();
    this.initSections();
  }

  // 5、Initialise group data.
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

  build() {
    Column({ space: 0 }) {
      Row() {
        Text($r('app.string.section_sort'))
          .width('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: '18vp', left: '16vp', bottom: '8vp' })
      }

      // 6、Link the grouping information to WaterFlow.
      WaterFlow({ scroller: this.scroller, sections: this.sections }) {
        // [StartExclude quick_start]
        LazyForEach(this.dataSource, (item: number) => {
          FlowItem() {
            ReusableFlowItem({ item: item })
          }
          .width('100%')
          .borderRadius(8)
          .backgroundColor(Color.Gray)
        }, (item: string) => item)
        // [EndExclude quick_start]
      }
      .cachedCount(12)
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

// [End quick_start]