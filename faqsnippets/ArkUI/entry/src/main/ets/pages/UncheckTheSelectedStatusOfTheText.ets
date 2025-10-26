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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

/*
* FAQ:如何在Text组件关闭bindSelection自定义菜单时，取消文本的选中状态
*/

// [Start uncheck_the_selected_status_of_the_text]
@Entry
@Component
struct TextMenuUnchecked {
  controller: TextController = new TextController();
  options: TextOptions = { controller: this.controller };
  @State start: number = -1; // Unchecked state
  @State end: number = -1;

  build() {
    Column() {
      Column() {
        Text(undefined, this.options) {
          Span('Hello World')
          ImageSpan($r('app.media.app_icon'))
            .width(50)
            .height(50)
            .objectFit(ImageFit.Fill)
            .verticalAlign(ImageSpanAlignment.CENTER)
        }
        .selection(this.start, this.end)
        .copyOption(CopyOptions.InApp)
        // Long press to bring up a custom menu
        .bindSelectionMenu(TextSpanType.TEXT, this.buildCustomSelectionMenu, TextResponseType.LONG_PRESS, {
          onDisappear: () => {
            console.info(`Custom selection menu callback when closed`);
          },
          onAppear: () => {
            console.info(`Callback when custom selection menu pops up`);
          }
        })
        // When the selected area changes, trigger a callback to update the starting and ending subscripts of the selected area
        .onTextSelectionChange((selectionStart: number, selectionEnd: number) => {
          this.start = selectionStart;
          this.end = selectionEnd;
          console.info(`Text selection area change callback, selectionStart: ${selectionStart}, selectionEnd: ${selectionEnd}`);
        })
        .borderWidth(1)
        .borderColor(Color.Red)
        .width(200)
        .height(100)
      }
      .width('100%')
      .backgroundColor(Color.White)
      .alignItems(HorizontalAlign.Start)
      .padding(25)
    }
    .height('100%')
  }

  @Builder
  buildCustomSelectionMenu() {
    Column() {
      Menu() {
        MenuItemGroup() {
          MenuItem({
            startIcon: $r('app.media.app_icon'),
            content: 'Right Click Menu 1',
            labelInfo: ''
          })
            .onClick(() => { //When clicking on the custom menu, reset the starting and ending subscripts of the selected area
              this.start = -1;
              this.end = -1;
              try {
                this.controller.closeSelectionMenu();
              } catch (error) {
                let err = error as BusinessError;
                hilog.error(0x000, 'TextMenuUnchecked', `err code:${err.code},message${err.message}.`);
              }
            })
          MenuItem({ startIcon: $r('app.media.app_icon'), content: 'Select Mixed Menu 2', labelInfo: '' })
          MenuItem({ startIcon: $r('app.media.app_icon'), content: 'Select Mixed Menu 3', labelInfo: '' })
        }
      }
      .radius($r('sys.float.ohos_id_corner_radius_card'))
      .clip(true)
      .backgroundColor('#F0F0F0')
    }
  }
}

// [End uncheck_the_selected_status_of_the_text]