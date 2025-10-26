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
import { CommonConstants } from '../common/constants/CommonConstants';
import { MyDataSource } from '../model/MyDataSource'

@Entry
@Component
struct MergeDoubleWaterFlowPage {
  // [StartExclude quick_start]
  @State minSize: number = 80
  @State maxSize: number = 210;
  @State fontSize: number = 24;
  scroller: Scroller = new Scroller();
  private data: MyDataSource = new MyDataSource();
  private itemHeightArray: number[] = [];
  @State sections: WaterFlowSections = new WaterFlowSections();
  @StorageProp(CommonConstants.AS_KEY_STATUS_BAR_HEIGHT) statusBarHeight: number = 0;
  sectionMargin: Margin = {
    top: 8,
    left: 16,
    bottom: 8,
    right: 16
  };
  oneColumnSection: SectionOptions = {
    itemsCount: 21,
    crossCount: 2,
    columnsGap: '5vp',
    rowsGap: 10,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return this.itemHeightArray[index % 100];
    }
  };
  twoColumnSection: SectionOptions = {
    itemsCount: 1,
    crossCount: 1,
    columnsGap: '5vp',
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return this.itemHeightArray[index % 100];
    }
  };
  lastSection: SectionOptions = {
    itemsCount: 78,
    crossCount: 2,
    margin: this.sectionMargin,
    onGetItemMainSizeByIndex: (index: number) => {
      return this.itemHeightArray[index % 100];
    }
  };

  getSize(): number {
    let ret: number = Math.floor(Math.random() * this.maxSize);
    return (ret > this.minSize ? ret : this.minSize);
  }

  setItemSizeArray(): void {
    for (let i: number = 0; i < 100; i++) {
      this.itemHeightArray.push(this.getSize());
    }
  }

  aboutToAppear(): void {
    for (let i: number = 0; i < 100; i++) {
      this.data.pushData(i);
    }
    this.setItemSizeArray();
    let sectionOptions: SectionOptions[] = [];
    sectionOptions.push(this.oneColumnSection);
    sectionOptions.push(this.twoColumnSection);
    sectionOptions.push(this.lastSection);
    this.sections.splice(0, 0, sectionOptions);
  }

  // [EndExclude quick_start]
  build() {
    Column({ space: 2 }) {
      Row() {
        Text($r('app.string.merge_double_waterflow'))
          .width('100%')
          .fontSize(24)
          .fontWeight(FontWeight.Bold)
          .margin({ top: '18vp', left: '16vp', bottom: '12vp' })
      }

      WaterFlow({ scroller: this.scroller, sections: this.sections }) {
        LazyForEach(this.data, (item: number) => {
          FlowItem() {
            if (item === 21) {
              // 1、This is the content for stitching the item.
              Column() {
                Text($r('app.string.recommend_goods'))
                  .align(Alignment.Center)
                  .width('100%')
                  .margin({ left: 16, top: 24, bottom: 24 })
                  .fontSize(24)
                  .fontWeight(FontWeight.Bold)
              }
            } else {
              // 2、Other data within WaterFlow.
              Column() {
                Text('N ' + item)
                  .fontSize(12)
                  .height('16vp')
                Image($rawfile(`sections/${item % 4}.jpg`))
                  .objectFit(ImageFit.Cover)
                  .width('100%')
                  .layoutWeight(1)
              }
            }
          }
          .width('100%')
        }, (item: number) => item.toString())
      }
      .cachedCount(10)
      .rowsGap(5)
      .backgroundColor('#efefef')
      .width('100%')
      .height('100%')
    }
    .padding({
      top: this.statusBarHeight
    })
    .backgroundColor('#efefef')
  }
}

// [End quick_start]