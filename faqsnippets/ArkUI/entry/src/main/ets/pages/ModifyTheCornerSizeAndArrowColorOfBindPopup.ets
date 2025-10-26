/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:如何修改bindPopup绑定的弹窗圆角大小和箭头颜色
*/

// [Start modify_the_corner_size_and_arrow_color_of_bindPopup]
@Entry
@Component
struct BindPopupDemo {
  @State handlePopup: boolean = false;
  @State customPopup: boolean = false;


  // Popup constructor defines the content of the popup box
  @Builder
  popupBuilder() {
    Row({ space: 2 }) {
      Image($r('app.media.startIcon'))
        .width(24)
        .height(24)
        .margin({ left: -5 })
      Text('Custom Popup')
        .fontSize(10)
    }
    .width(100)
    .height(50)
    .padding(5)
  }


  build() {
    RelativeContainer() {
      Button('CustomPopupOptions')
        .onClick(() => {
          this.customPopup = !this.customPopup;
        })
        .bindPopup(this.customPopup, {
          builder: this.popupBuilder,
          radius: 30,
          popupColor: Color.Yellow,
          enableArrow: true,
          onStateChange: (e) => {
            if (!e.isVisible) {
              this.customPopup = false;
            }
          }
        })
    }
  }
}
// [End modify_the_corner_size_and_arrow_color_of_bindPopup]