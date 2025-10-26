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

import AudioCapabilityManager from '../viewmodel/AudioCapabilityManager';
import { DefaultPickerComponent } from '../view/DefaultPickerComponent';
import { CustomPickerComponent } from '../view/CustomPickerComponent';
import { Constants } from '../common/constants/Constants';

@Entry
@Component
struct Index {
  @State audioCapabilityManager: AudioCapabilityManager = new AudioCapabilityManager();
  @Provide('pageInfos') pathStack: NavPathStack = new NavPathStack();

  @Builder
  pagesMap(name: string, param: number) {
    if (name === Constants.DEFAULT_PAGE_NAME) {
      DefaultPickerComponent({
        audioCapabilityManager: $audioCapabilityManager
      })
    } else if (name === Constants.CUSTOM_PAGE_NAME) {
      CustomPickerComponent({
        audioCapabilityManager: $audioCapabilityManager
      })
    }
  }

  build() {
    Navigation(this.pathStack) {
      Row() {
        Column({ space: Constants.MAIN_PAGE_BUTTON_SPACE }) {
          Button($r('app.string.default_AVCastPicker'))
            .size({
              width: $r('app.float.main_page_button_width'),
              height: $r('app.float.main_page_button_height')
            })
            .onClick(()=>{
              this.pathStack.pushPathByName(Constants.DEFAULT_PAGE_NAME, 0);
            })

          Button($r('app.string.custom_AVCastPicker'))
            .size({
              width: $r('app.float.main_page_button_width'),
              height: $r('app.float.main_page_button_height')
            })
            .margin({ bottom: $r('app.float.distance_from_Navigation_bar')})
            .onClick(()=>{
              this.pathStack.pushPathByName(Constants.CUSTOM_PAGE_NAME, 0);
            })
        }
        .justifyContent(FlexAlign.End)
        .alignItems(HorizontalAlign.Center)
        .size({
          width: $r('app.string.full_width'),
          height: $r('app.string.full_height')
        })
      }
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
      .size({
        width: $r('app.string.full_width'),
        height: $r('app.string.full_height')
      })
    }
    .hideToolBar(true)
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .size({
      width: $r('app.string.full_width'),
      height: $r('app.string.full_height')
    })
    .navDestination(this.pagesMap)
    .backgroundColor($r('app.color.main_window_background'))
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}