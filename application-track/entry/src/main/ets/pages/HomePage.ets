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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct HomePage {
  @Provide('pathStack') pathStack: NavPathStack = new NavPathStack();

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (error) {
      hilog.error(0x0000, '[getResourceString]', `getResourceString err: ${JSON.stringify(error)}`);
    }
    return resourceString;
  }

  build() {
    Column() {
      Navigation(this.pathStack) {
        Row() {
          Column() {
            Row() {
              Text($r('app.string.click_tracing_point'))
                .width('100%')
                .fontSize(18)
            }
            .height(56)

            Row() {
              Text($r('app.string.click_tracing_point_detail'))
                .fontSize(16)
                .fontWeight(500)
                .height('100%')
                .align(Alignment.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ left: 12 })
              Column()
                .layoutWeight(1)
              Image($r('app.media.ic_public_arrow_right'))
                .width(24)
                .height(24)
                .margin({ right: 12 })
            }
            .height(48)
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(18)
            .onClick(() => {
              this.pathStack.pushPath({ name: 'ClickPage' });
            })

            Row() {
              Text($r('app.string.exposure_embedment_point'))
                .width('100%')
                .fontSize(18)
            }
            .height(56)

            Row() {
              Text($r('app.string.exposure_embedment_point_detail'))
                .fontSize(16)
                .fontWeight(500)
                .height('100%')
                .align(Alignment.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ left: 12 })
              Column()
                .layoutWeight(1)
              Image($r('app.media.ic_public_arrow_right'))
                .width(24)
                .height(24)
                .margin({ right: 12 })
            }
            .height(48)
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(18)
            .onClick(() => {
              this.pathStack.pushPath({ name: 'WaterFlowPage' });
            })

            Row() {
              Text($r('app.string.page_tracing_point'))
                .width('100%')
                .fontSize(18)
            }
            .height(56)

            Row() {
              Text($r('app.string.navigation_route'))
                .fontSize(16)
                .fontWeight(500)
                .height('100%')
                .align(Alignment.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ left: 12 })
              Column()
                .layoutWeight(1)
              Image($r('app.media.ic_public_arrow_right'))
                .width(24)
                .height(24)
                .margin({ right: 12 })
            }
            .height(48)
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(18)
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({ url: 'pages/NavigationPage' });
            })

            Row() {
              Text($r('app.string.router_route'))
                .fontSize(16)
                .fontWeight(500)
                .height('100%')
                .align(Alignment.Center)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .margin({ left: 12 })
              Column()
                .layoutWeight(1)
              Image($r('app.media.ic_public_arrow_right'))
                .width(24)
                .height(24)
                .margin({ right: 12 })
            }
            .height(48)
            .width('100%')
            .backgroundColor(Color.White)
            .borderRadius(18)
            .margin({ top: 16 })
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({ url: 'pages/RouterPageA' })
            })
          }
          .height('100%')
        }
        .width('100%')
        .height('100%')
        .padding({
          right: 16,
          bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16,
          left: 16
        })
      }
      .titleMode(NavigationTitleMode.Full)
      .mode(NavigationMode.Stack)
      .title(this.getResourceString($r('app.string.application_tracing_point_example')))
      .padding({
        top: AppStorage.get<number>('statusBarHeight') ?? 0
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
  }
}