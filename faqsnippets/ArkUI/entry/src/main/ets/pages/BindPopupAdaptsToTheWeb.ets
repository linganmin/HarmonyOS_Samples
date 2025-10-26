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
* FAQ:bindPopup适配Web组件长按菜单功能，设置offset控制弹窗的偏移
*/

// [Start bindPopup_adapts_to_the_web]
import { webview } from '@kit.ArkWeb';


@Entry
@Component
struct BindPopupOffset {
  controller: webview.WebviewController = new webview.WebviewController();
  private result: WebContextMenuResult | undefined = undefined;
  @State linkUrl: string = '';
  @State offsetX: number = 0;
  @State offsetY: number = 0;
  @State showMenu: boolean = false;


  @Builder
  menuBuilder() {
    Menu() {
      MenuItem({
        content: 'copy picture',
      })
        .width(100)
        .height(50)
        .onClick(() => {
          this.result?.copyImage();
          this.showMenu = false;
        })
      MenuItem({
        content: 'cut'
      })
        .width(100)
        .height(50)
        .onClick(() => {
          this.result?.cut();
          this.showMenu = false;
        })
    }
    .width(150)
    .backgroundColor('#eeeeee')
  }


  build() {
    Column() {
      Row()
        .width(0)
        .height(0)
        .position({ x: 0, y: 0 })
        .bindPopup(this.showMenu,
          {
            builder: this.menuBuilder(),
            enableArrow: false,
            placement: Placement.LeftTop,
            targetSpace: 0,
            shadow: {
              radius: 0
            },
            offset: {
              x: this.offsetX - 7,
              y: this.offsetY
            },
            mask: false,
            onStateChange: (e) => {
              if (!e.isVisible) {
                this.showMenu = false;
                this.result?.closeContextMenu();
              }
            }
          })

      // index.html It should include elements that trigger the contextmenu event.
      Web({ src: $rawfile('index.html'), controller: this.controller })//Trigger custom pop ups
        .onContextMenuShow((event) => {
          if (event) {
            this.result = event.result;
            this.showMenu = true;
            this.offsetX = Math.max(this.getUIContext().px2vp(event?.param.x() ?? 0) - 0, 0);
            this.offsetY = Math.max(this.getUIContext().px2vp(event?.param.y() ?? 0) - 0, 0);
          }
          return true;
        })
    }
  }
}
// [End bindPopup_adapts_to_the_web]