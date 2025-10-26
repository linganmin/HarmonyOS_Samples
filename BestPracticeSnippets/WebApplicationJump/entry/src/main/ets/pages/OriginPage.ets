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

import { Constants } from '../common/Constants';

@Component
export struct OriginPage {
  @Consume('navPathStack') navPathStack: NavPathStack;
  @StorageProp(Constants.SYSTEM_LANGUAGE_KEY) la: string = '';

  build() {
    // [Start nav_dest]
    NavDestination() {
      Column() {
        Button('return to the web page')
          .width('100%')
          .height(40)
          .onClick(() => {
            this.navPathStack.pop();
          })
      }
      // [StartExclude nav_dest]
      .width(Constants.FULL_SCREEN)
      .height(Constants.FULL_SCREEN)
      .justifyContent(FlexAlign.End)
      .padding({
        left: $r('app.float.space_24'),
        right: $r('app.float.space_24'),
        bottom: $r('app.float.space_bottom')
      })
    }
    // [EndExclude nav_dest]
    .title(this.la = 'en-Latn-CN' ? 'OriginPage' : 'NativePage')
    // [End nav_dest]
  }
}