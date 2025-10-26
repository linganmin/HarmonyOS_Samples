/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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

enum StatusEnum {
  UNAVAILABLE = 0,  // unavailable
  AVAILABLE = 1,    // available
  SELECTED = 2      // selected
}

@Component
export struct MultiStatusButton {
  @State status: number = StatusEnum.SELECTED;
  @State text: string = 'NONE';

  build() {
    Column() {
      if (this.status === StatusEnum.UNAVAILABLE) {
        Text(this.text)
          .width('100%')
          .height('100%')
          .fontColor($r('sys.color.dialog_outer_border_color'))
          .backgroundColor($r('sys.color.container_modal_button_hover_baseboard'))
          .borderRadius(16)
          .padding({left: 16})
          .margin({top: 8})
      } else if (this.status === StatusEnum.AVAILABLE) {
        Text(this.text)
          .width('100%')
          .height('100%')
          .fontColor($r('sys.color.black'))
          .backgroundColor($r('sys.color.container_modal_button_hover_baseboard'))
          .borderRadius(16)
          .padding({left: 16})
          .margin({top: 8})
          .onTouch(()=>{
            this.status = StatusEnum.SELECTED;
          })
      } else if (this.status === StatusEnum.SELECTED) {
        Text(this.text)
          .width('100%')
          .height('100%')
          .fontColor('#0A59F7')
          .backgroundColor('#0C0A59F7')
          .borderRadius(16)
          .padding({left: 16})
          .margin({top: 8})
          .borderWidth(1)
          .borderColor('#0A59F7')
      }
    }
    .margin({top: 8})
    .width('100%')
    .height(56)
  }
}
