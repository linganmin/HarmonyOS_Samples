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

import { CommonConstants } from '../common/CommonConstants';

@Entry
@Component
struct Index {
  pathStack: NavPathStack = new NavPathStack();

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.title'))
        .fontSize($r('app.float.text_fontsize'))
        .lineHeight($r('app.float.text_lineHeight'))
        .fontWeight(CommonConstants.TEXT_FONT_WEIGHT)
    }
    .width(CommonConstants.FULL_PERCENT)
  }

  build() {
    Navigation(this.pathStack) {
      Column({ space: CommonConstants.COLUMN_SPACE }) {
        Button($r('app.string.base_request'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('BaseRequest', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)
        Button($r('app.string.multipart_form'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('MultipartForm', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)
        Button($r('app.string.request_response'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('RequestAndResponse', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)
        Button($r('app.string.dns_setting'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('DNSSetting', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)
        Button($r('app.string.tracing_point'), { stateEffect: true, type: ButtonType.Capsule })
          .onClick(() => {
            this.pathStack.pushPathByName('TracingPoint', null, false);
          })
          .width(CommonConstants.FULL_PERCENT)
      }
      .justifyContent(FlexAlign.End)
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding($r('app.float.padding'))
    }
    .title(this.NavigationTitle())
    .titleMode(NavigationTitleMode.Full)
  }
}