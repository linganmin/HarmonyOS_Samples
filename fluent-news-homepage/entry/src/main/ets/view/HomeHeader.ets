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
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { ResourceUtil } from '../utils/ResourceUtil';

@Component
export struct HomeHeader {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('topRectHeight') topRectHeight: number = CommonConstants.ZERO;
  @StorageProp('local') location: string = '';

  build() {
    Column() {
      this.SearchBar()
    }
  }

  getString(id: number): string {
    try {
      return this.getUIContext().getHostContext()!.resourceManager.getStringSync(id);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'HomeHeader', `getStringSync failed, error code=${err.code}, message=${err.message}`);
      return '';
    }
  }

  @Builder
  SearchBar() {
    Row() {
      Image($r('app.media.down'))
        .width($r('app.float.img_size'))
        .height($r('app.float.img_size'))
        .margin({
          left: this.currentBreakpoint === BreakpointConstants.BREAKPOINT_SM ?
          $r('app.float.search_img_margin_sm') : $r('app.float.search_img_margin'),
          right: $r('app.float.search_img_margin_right')
        })
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/CitySearch'
          });
        })

      Text(this.location === '' ? this.getString($r('app.string.get_location').id) : this.location)
        .height(ResourceUtil.getCommonImgSize()[0])
        .onClick(() => {
          this.getUIContext().getRouter().pushUrl({
            url: 'pages/CitySearch'
          });
        })

      Stack({ alignContent: Alignment.Start }) {
        TextInput({ placeholder: $r('app.string.search_text') })
          .placeholderFont({
            size: $r('app.float.search_input_font'),
            weight: FontWeight.Normal
          })
          .backgroundColor(ResourceUtil.getCommonBackgroundColor()[1])
          .placeholderColor($r('app.color.normal_font_color'))
          .height($r('app.float.search_input_height'))
          .fontSize($r('app.float.search_input_font'))
          .padding({
            left: $r('app.float.search_input_left'),
            right: $r('app.float.search_input_right')
          })
          .border({ width: $r('app.string.text_input_border') })
          .width($r('app.string.home_header_stack_width'))
          .enableKeyboardOnFocus(false)

        // Search image.
        Image($r('app.media.ic_public_search'))
          .width($r('app.float.search_img_size'))
          .height($r('app.float.search_img_size'))
          .margin({ left: $r('app.float.search_img_left') })
      }
      .alignSelf(ItemAlign.Start)
      .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
      .padding({ left: $r('app.float.search_img_left') })
    }
    .justifyContent(FlexAlign.Start)
    .width(CommonConstants.FULL_PERCENT)
    .margin({
      top: $r('app.float.search_bar_margin'),
      bottom: $r('app.float.search_bar_margin')
    })
  }
}