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

import { buffer, taskpool } from '@kit.ArkTS';
import { Item, ResponseData, dataToItem } from '../common/Item';
import { WaterFlowDataSource } from './WaterFlowDataSource';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

@Entry
@Component
struct WaterFlowExample {
  @State fontSize: number = 24;
  scroller: Scroller = new Scroller();
  dataSource: WaterFlowDataSource = new WaterFlowDataSource();
  UIContext: UIContext = this.getUIContext()

  @Builder
  itemFoot() {
    Text('Footer')
      .fontSize(10)
      .backgroundColor(Color.Red)
      .width(50)
      .height(50)
      .align(Alignment.Center)
      .margin({ top: 2 })
  }

  @Builder
  imageCom(item: number) {
    Image($r(`app.media.waterFlowTest${item % 3}`))
      .width('100%')
      .layoutWeight(1)
      .objectFit(ImageFit.Fill)
  }

  // [Start use_task_pool]
  build() {
    Column({ space: 2 }) {
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

        Text($r('app.string.use_async'))
          .fontSize(20)
          .fontWeight(700)
          .height(26)
      }
      .width('100%')
      .height(56)
      .margin({ top: 20 })

      WaterFlow() {
        LazyForEach(this.dataSource, (item: number) => {
          FlowItem() {
            // [StartExclude use_task_pool]
            this.imageCom(item)
            // [EndExclude use_task_pool]
          }
          .onAppear(() => {
            // Add data in advance when you are about to hit the bottom
            if (item + 20 === this.dataSource.totalCount()) {
              // Simulate the time it takes for the network to acquire data
              taskPoolExecute(this.UIContext).then((data: Item[]) => {
                for (let i = 0; i < data.length; i++) {
                  this.dataSource.addLastItem();
                }
              })
            }
          })
          // [StartExclude use_task_pool]
          .width('100%')
          .height(320)

          // [EndExclude use_task_pool]
        }, (item: number) => item.toString())
      }
      // [StartExclude use_task_pool]
      .cachedCount(2)
      .columnsTemplate('1fr 1fr')
      .columnsGap(12)
      .rowsGap(12)
      .width('100%')
      .height('100%')
      .onScrollFrameBegin((offset: number) => {
        return { offsetRemain: offset };
      })

      // [EndExclude use_task_pool]
    }
    .padding(16)
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // [End use_task_pool]
}

// [Start task_pool_execute]
// The following methods are defined outside of the component
async function taskPoolExecute(UIContext: UIContext): Promise<Item[]> {
  let task: taskpool.Task = new taskpool.Task(mockRequestData, UIContext);
  let result: Item[] = [];
  try {
    result = await taskpool.execute(task) as Item[]
  } catch (error) {
    hilog.error(0x0000,'',`execute failed. code=${error.code}, message=${error.message}`);
  }
  return result;
}

@Concurrent
async function mockRequestData(context: Context): Promise<Item[]> {
  let res: ResponseData = new ResponseData();
  // data.json is the local json data, which is about 20 MB in size, and simulates getting data from the network
  await context.resourceManager.getRawFileContent('data.json').then((data: Uint8Array) => {
    // parse json
    try {
      let str: string = buffer.from(data).toString();
      res = JSON.parse(str);
    } catch (error) {
      hilog.error(0x0000,'',`buffer.from failed. code=${error.code}, message=${error.message}`);
    }
  }).catch((error: BusinessError)=>{
    hilog.error(0x0000,'',`getRawFileContent failed. code=${error.code}, message=${error.message}`);
  });
  let arr: Item[] = dataToItem(res.data);
  return arr;
}

// [End task_pool_execute]