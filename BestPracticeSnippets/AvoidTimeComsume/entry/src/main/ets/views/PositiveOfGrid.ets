/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';

class MyDataSource implements IDataSource {
  private dataArray: number[] = [];

  public pushData(data: number): void {
    this.dataArray.push(data);
  }

  // The total amount of data from the data source
  public totalCount(): number {
    return this.dataArray.length;
  }

  // Returns data for the specified index location
  public getData(index: number): number {
    return this.dataArray[index];
  }

  registerDataChangeListener(): void {
  }

  unregisterDataChangeListener(): void {
  }
}

@Entry
@Component
struct PositiveOfGrid {
  // Data sources
  private data: MyDataSource = new MyDataSource();

  aboutToAppear(): void {
    for (let i = 1; i < 1000; i++) {
      this.data.pushData(i);
    }
  }

  build() {
    Column() {
      Row({ space: 5 }) {
        Column() {
          Image($r('app.media.chevron_left'))
            .width(16)
            .height(16)
        }
        .width(40)
        .height(40)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#E8E8E8')
        .borderRadius(40)
        .onClick(() => {
          this.getUIContext().getRouter().back({
            url: 'pages/Index'
          });
        })

        Text($r('app.string.positive_of_grid'))
          .fontSize(20)
          .fontWeight(700)
          .height(26)
      }
      .padding({ left: 16, right: 16 })
      .width('100%')
      .height(56)
      .margin({ top: 36 })

      Column({ space: 5 }) {
        Grid() {
          LazyForEach(this.data, (item: number) => {
            GridItem() {
              // Use reusable custom components
              ReusableChildComponent({ item: item })
            }
          }, (item: number) => item.toString())
        }
        .cachedCount(2)
        .columnsTemplate('1fr 1fr 1fr 1fr')
        .columnsGap(10)
        .rowsGap(10)
      }
      .margin({ top: 12 })
    }
    .backgroundColor('#F5F5F5')
  }
}

// Custom components are decorated @Reusable decorators, which signify their ability to be reused by components
@Reusable
@Component
struct ReusableChildComponent {
  @State item: number = 0;

  // [Start positive_of_grid]
  // ...
  aboutToReuse(params: Record<string, number>): void {
    hiTraceMeter.startTrace('ReuseOfGrid', 1001);
    this.item = params.item;
    hiTraceMeter.finishTrace('ReuseOfGrid', 1001)
  }

  // ...
  // [End positive_of_grid]

  build() {
    Column() {
      Image($r('app.media.app_icon'))
        .width(48)
        .height(48)
        .margin({ bottom: 12 })
      Text(`image${this.item}`)
        .fontSize(12)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height(82)
  }
}