/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

// entry\src\main\ets\pages\ClickPage.ets
import { hilog } from '@kit.PerformanceAnalysisKit';
import { DataResource } from '../viewModel/DataResource';

@Builder
export function ClickPageBuilder() {
  ClickPage()
}

@Component
export struct ClickPage {
  onPageShow(): void {
    const uiContext: UIContext = this.getUIContext();
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'button-1',
      JSON.stringify(uiContext.getFrameNodeById('button-1')?.getCustomProperty('button-1')));
  }

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
    NavDestination() {
      Column() {
        // [Start composite_component]
        // entry\src\main\ets\pages\ClickPage.ets
        Row() {
          Text('Click Tracing Point - Composite Component')
            // [StartExclude composite_component]
            .fontSize(16)
            .fontWeight(500)
            .height('100%')
            .align(Alignment.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .margin({ left: 12 })
          Column()
            .layoutWeight(1)
          // [EndExclude composite_component]
          Image($r('app.media.ic_public_arrow_right'))
            // [StartExclude composite_component]
            .width(24)
            .height(24)
            .margin({ right: 12 })
          // [EndExclude composite_component]
        }
        // [StartExclude composite_component]
        .height(48)
        .backgroundColor(Color.White)
        .borderRadius(18)
        // [EndExclude composite_component]
        .id('button-2')
        .margin({ top: 12 })
        .customProperty('button-2', DataResource['Index']['button-2'])
        .onClick(() => {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'row');
        })

        Row() {
          // [Start click_tracing_point]
          // entry\src\main\ets\pages\ClickPage.ets
          Button('Click Tracing Point - Single Component')
            .width('100%')
            .id('button-1')
            .fontWeight(FontWeight.Bold)
            .customProperty('button-1', DataResource['Index']['button-1'])
            .onClick(() => {
              hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'btn');
            })
          // [End click_tracing_point]
        }
        // [End composite_component]
      }
      .padding({
        right: 16,
        left: 16
      })
      .justifyContent(FlexAlign.SpaceBetween)
      .height('100%')
      .width('100%')
    }
    .title(this.getResourceString($r('app.string.click_tracing_point_detail')))
    .backgroundColor('#F1F3F5')
    .padding({
      bottom: (AppStorage.get<number>('naviIndicatorHeight') ?? 0) + 16
    })
  }
}
