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
  pageStack: NavPathStack = new NavPathStack();

  build() {
    Navigation(this.pageStack) {
      Column({ space: CommonConstants.BUTTON_SPACING }) {
        Button($r('app.string.common_style_extract'))
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName('AttributeStylePage', null, true);
          })
        Button($r('app.string.common'))
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName('CommonComponent', null, true);
          })
        Button($r('app.string.factory'))
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName('ComponentFactory', null, true);
          })
        Button($r('app.string.dialog'))
          .width(CommonConstants.ONE_HUNDRED_PERCENT)
          .onClick(() => {
            this.pageStack.pushPathByName('DialogComponent', null, true);
          })
      }
      .padding($r('app.float.padding'))
      .justifyContent(FlexAlign.End)
      .alignItems(HorizontalAlign.Center)
      .height(CommonConstants.ONE_HUNDRED_PERCENT)
      .width(CommonConstants.ONE_HUNDRED_PERCENT)
    }
    .title($r('app.string.scenario'))
  }
}