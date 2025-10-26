/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { Constants } from '../constants/Constants';

@Component
export struct Page1 {
  @Consume('pageInfos') pageInfos: NavPathStack;
  private desc: string = '';

  aboutToAppear(): void {
    this.desc = this.pageInfos.getParamByIndex(0) as string;
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text(`This is detail Page\n\n AppLinking is ${Constants.APP_LINK_PAGE}\n\n${this.desc}.`)
            .fontColor($r('sys.color.font_primary'))
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .padding(16)
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
        .margin({ top: 12 })
        .foregroundColor($r('sys.color.ohos_id_color_component_normal_dark'))
      }
      .width('100%')
      .height('100%')
      .foregroundColor($r('sys.color.comp_background_secondary'))
    }.title('Page1')
  }
}