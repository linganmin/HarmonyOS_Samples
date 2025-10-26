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
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

class DirectoryItem {
  title: ResourceStr = '';
  uri: string = '';
  id: string = '';
}

@Entry
@Component
struct Index {
  private directory: DirectoryItem[] = [
    {
      title: $r('app.string.redundant_operation'),
      uri: 'views/RedundantOperation',
      id: 'RedundantOperation'
    },
    {
      title: $r('app.string.no_redundant_operation'),
      uri: 'views/NoRedundantOperation',
      id: 'NoRedundantOperation'
    },
    {
      title: $r('app.string.negative_of_grid'),
      uri: 'views/NegativeOfGrid',
      id: 'NegativeOfGrid'
    },
    {
      title: $r('app.string.positive_of_grid'),
      uri: 'views/PositiveOfGrid',
      id: 'PositiveOfGrid'
    },
    {
      title: $r('app.string.negative_of_lazy_forEach'),
      uri: 'views/NegativeOfLazyForEach',
      id: 'NegativeOfLazyForEach'
    },
    {
      title: $r('app.string.positive_of_lazy_forEach'),
      uri: 'views/PositiveOfLazyForEach',
      id: 'PositiveOfLazyForEach'
    },
    {
      title: $r('app.string.negative_of_property'),
      uri: 'views/NegativeOfProperty',
      id: 'NegativeOfProperty'
    },
    {
      title: $r('app.string.positive_of_property'),
      uri: 'views/PositiveOfProperty',
      id: 'PositiveOfProperty'
    },
    {
      title: $r('app.string.get_str_of_resource'),
      uri: 'views/GetStrOfResource',
      id: 'GetStrOfResource'
    },
    {
      title: $r('app.string.get_str_of_id'),
      uri: 'views/GetStrOfId',
      id: 'GetStrOfId'
    },
    {
      title: $r('app.string.use_async'),
      uri: 'views/UseAsync',
      id: 'UseAsync'
    },
    {
      title: $r('app.string.use_task_pool'),
      uri: 'views/UseTaskPool',
      id: 'UseTaskPool'
    }
  ]

  build() {
    Column() {
      Text($r('app.string.EntryAbility_label'))
        .fontSize(30)
        .fontWeight(700)
        .width('100%')
        .height(56)
        .margin({ top: 92 })
        .padding({ left: 16 })
      Column() {
        Grid() {
          ForEach(this.directory, (item: DirectoryItem) => {
            GridItem() {
              Button(item.title)
                .id(item.id)
                .fontSize(16)
                .width('100%')
                .height(40)
                .backgroundColor('#0A59F7')
                .onClick(() => {
                  this.getUIContext().getRouter().pushUrl({
                    url: item.uri
                  }).catch((error: BusinessError)=>{
                    hilog.error(0x0000,'',`pushUrl failed. code=${error.code}, message=${error.message}`);
                  });
                })
            }
          }, (item: DirectoryItem) => JSON.stringify(item))
        }
        .columnsGap(12)
        .rowsGap(12)
        .padding({ left: 16, right: 16 })
        .columnsTemplate('1fr 1fr')
        .height(314)

        Column({ space: 12 }) {
          Button($r('app.string.negative_of_onScroll'))
            .id('NegativeOfOnScroll')
            .fontSize(16)
            .width('100%')
            .height(40)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'views/NegativeOfOnScroll'
              }).catch((error: BusinessError)=>{
                hilog.error(0x0000,'',`pushUrl failed. code=${error.code}, message=${error.message}`);
              });
            })
          Button($r('app.string.positive_of_onScroll'))
            .id('PositiveOfOnScroll')
            .fontSize(16)
            .width('100%')
            .height(40)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'views/PositiveOfOnScroll'
              }).catch((error: BusinessError)=>{
                hilog.error(0x0000,'',`pushUrl failed. code=${error.code}, message=${error.message}`);
              });
            })
          Button($r('app.string.conditional_rendering'))
            .id('ConditionalRendering')
            .fontSize(16)
            .width('100%')
            .height(40)
            .backgroundColor('#0A59F7')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'views/ConditionalRendering'
              }).catch((error: BusinessError)=>{
                hilog.error(0x0000,'',`pushUrl failed. code=${error.code}, message=${error.message}`);
              });;
            })
        }
        .padding({ left: 16, right: 16, bottom: 44 })
      }
    }
    .backgroundColor('#F5F5F5')
    .height('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}