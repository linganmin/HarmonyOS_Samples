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

/**
 *  最佳实践：点击响应优化
 */
import taskpool from '@ohos.taskpool';
import hiTraceMeter from '@ohos.hiTraceMeter';
import { AppConstant } from '../common/constants/AppConstant';
import router from '@ohos.router';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const DOMAIN = 0x0000;
const alphabets = ['#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K',
  'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z'];

// [Start compute_task]
@Concurrent
function computeTask(): string[] {
  let array: string[] = []
  // AppConstant.CITYS 为需要加载的数据
  for (let t of AppConstant.CITYS) {
    array.push(t.trim())
  }
  let collator = new Intl.Collator("zh-CN", { localeMatcher: "lookup", usage: "sort" });
  array.sort((a, b) => collator.compare(a, b))
  return array;
}

@Entry
@Component
struct CityList {
  isAsync: boolean = (this.getUIContext().getRouter().getParams() as Record<string, boolean>)['isAsync'];
  // Interface data
  @State citys: string[] = []
  private listScroller: Scroller = new Scroller();

  aboutToAppear() {
    this.computeTaskAsync(); // invoke asynchronous computation function
  }

  // asynchronous thread
  computeTaskAsync() {
    let task: taskpool.Task = new taskpool.Task(computeTask);
    try {
      taskpool.execute(task).then((res) => {
        this.citys = res as string[]
      });
    } catch (e) {
      let err = e as BusinessError;
      hilog.error(DOMAIN, 'testTag', `failed code=${err.code}, message=${err.message}`);
    }

  }

  // [StartExclude onpage_show]
  onPageShow() {
    hiTraceMeter.finishTrace("clickCity", 1);
  }

  build() {
    Column() {
      Row() {
        Image($r("app.media.ic_back"))
          .width(26).height(26)
          .fillColor('#99000000')
          .margin(10)
        Text('选择地区')
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20, top: 20 })
          .alignSelf(ItemAlign.Center)
          .textAlign(TextAlign.Center)
          .layoutWeight(1)
        Image($r('app.media.ic_public_search'))
          .width(26)
          .height(26)
          .fillColor('#99000000')
          .visibility(Visibility.Hidden)
          .margin(10)
      }
      .padding({ left: 5, right: 5 })

      Row() {
        Text('安徽省')
          .margin({ left: 25, bottom: 20 })
          .fontSize(17)
          .fontWeight(FontWeight.Medium)
        Text('城市')
          .fontSize(17)
          .fontColor(Color.Gray)
          .fontWeight(FontWeight.Medium)
          .margin({ left: 25, bottom: 20 })
      }
      .margin({ top: 10 })
      .width('100%')
      .justifyContent(FlexAlign.Start)

      Stack({ alignContent: Alignment.End }) {

        List({ space: 10, scroller: this.listScroller }) {
          ForEach(this.isAsync ? this.citys : AppConstant.CITYS, (item: string) => {
            ListItem() {
              Row() {
                Text(item)
                  .fontSize(17)
              }
              .padding(17)
              .width('100%')
              .margin({ left: 5 })
              .justifyContent(FlexAlign.Start)
            }
          })
        }
        .divider({
          strokeWidth: 1,
          startMargin: 25,
          endMargin: 0,
          color: '#ffe9f0f0'
        })
        .scrollBar(BarState.Auto)
        .width('100%')
        .height('100%')

        AlphabetIndexer({ arrayValue: alphabets, selected: 1 })
          .margin({ right: 5 })
      }
    }
  }

  // [EndExclude onpage_show]
}

// [End compute_task]

