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
import { ArkTSPerfTag } from './ArkTSPerfTag';
import { NativePerfTag } from './NativePerfTag';
import { LifeCyclePerfTag } from './LifeCyclePerfTag';
import { ComponentCBPerfTag } from './ComponentCBPerfTag';
import CommonConstants from '../common/CommonConstants';

@Entry
@Component
struct MainPages {
  // Used for avoiding the status bar.
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageProp('bottomRectHeight') bottomRectHeight: number = 0;
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  // Page redirection logic.
  @Builder
  PageMap(name: string) {
    if (name === CommonConstants.ARK_TS_PERF_TAG_PAGE) {
      ArkTSPerfTag();
    } else if (name === CommonConstants.NATIVE_PERF_TAG_PAGE) {
      NativePerfTag();
    } else if (name === CommonConstants.LIFECYCLE_PERF_TAG_PAGE) {
      LifeCyclePerfTag();
    } else if (name === CommonConstants.COMPONENT_CB_PERF_TAG_PAGE) {
      ComponentCBPerfTag();
    } else {
      MainPages();
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Row() {
        Column() {
          Text($r('app.string.Module_title'))
            .fontSize(CommonConstants.TITLE_FONT_SIZE)
            .width(CommonConstants.FULL_PARENT)
            .textAlign(TextAlign.Start)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 64 })

          Blank();

          Button($r('app.string.ArkTSPerfTag_Title'))
            .width(CommonConstants.FULL_PARENT)
            .fontWeight(CommonConstants.BUTTON_FONT_WEIGHT)
            .fontSize(CommonConstants.BUTTON_FONT_SIZE)
            .onClick(() => {
              this.pageInfos.pushPath({ name: CommonConstants.ARK_TS_PERF_TAG_PAGE });
            })

          Button($r('app.string.NativePerfTag_Title'))
            .width(CommonConstants.FULL_PARENT)
            .fontWeight(CommonConstants.BUTTON_FONT_WEIGHT)
            .fontSize(CommonConstants.BUTTON_FONT_SIZE)
            .margin({ top: 12 })
            .onClick(() => {
              this.pageInfos.pushPath({ name: CommonConstants.NATIVE_PERF_TAG_PAGE });
            })

          Button($r('app.string.ComponentCBPerfTag_Title'))
            .width(CommonConstants.FULL_PARENT)
            .fontWeight(CommonConstants.BUTTON_FONT_WEIGHT)
            .fontSize(CommonConstants.BUTTON_FONT_SIZE)
            .margin({ top: 12 })
            .onClick(() => {
              this.pageInfos.pushPath({ name: CommonConstants.COMPONENT_CB_PERF_TAG_PAGE });
            })

          Button($r('app.string.LifeCyclePerfTag_Title'))
            .width(CommonConstants.FULL_PARENT)
            .fontWeight(CommonConstants.BUTTON_FONT_WEIGHT)
            .fontSize(CommonConstants.BUTTON_FONT_SIZE)
            .margin({ top: 12 })
            .onClick(() => {
              this.pageInfos.pushPath({ name: CommonConstants.LIFECYCLE_PERF_TAG_PAGE });
            })
        }
        .width(CommonConstants.FULL_PARENT)
        .height(CommonConstants.FULL_PARENT)
        .justifyContent(FlexAlign.End)
        .padding({ left: 16, right: 16, bottom: 16 })
      }
      .height(CommonConstants.FULL_PARENT)
      .padding({ top: this.topRectHeight, bottom: this.bottomRectHeight })
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .backgroundColor($r('app.color.window_background_color'))
    .navDestination(this.PageMap)
  }
}
