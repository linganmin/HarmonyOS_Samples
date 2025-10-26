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

import { display, window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import CommonConstants from '../constants/CommonConstants';
import Logger from '../utils/Logger';
import { WindowPosition } from '../viewmodel/WindowPosition';

@Entry
@Component
struct NavigationRedirectPage {
  @State windowStage: window.WindowStage = AppStorage.get('windowStage') as window.WindowStage;
  @State subWindow: window.Window = window.findWindow('NavigationRedirectPage');
  @State @Watch('moveWindow') windowPosition: WindowPosition = {
    x: CommonConstants.DEFAULT_WINDOW_X,
    y: CommonConstants.DEFAULT_WINDOW_Y
  };
  private panOption: PanGestureOptions = new PanGestureOptions({ direction: PanDirection.All });

  onPageShow(): void {
    setTimeout(() => {
      try {
        let subWindowID: number = window.findWindow('NavigationRedirectPage').getWindowProperties().id;
        let mainWindowID: number = this.windowStage.getMainWindowSync().getWindowProperties().id;
        window.shiftAppWindowFocus(subWindowID, mainWindowID);
      } catch (error) {
        Logger.error('shiftAppWindowFocus failed' + JSON.stringify(error));
      }
    }, CommonConstants.TIME_DELAY)
  }

  /**
   * Move the floating window to the specified position.
   */
  moveWindow() {
    this.subWindow.moveWindowTo(this.windowPosition.x, this.windowPosition.y).catch((error: BusinessError) => {
      Logger.error(`moveWindowTo error, code is ${error.code}, message is ${error.message}`);
    });
  }

  build() {
    Row() {
      Image($r('app.media.ic_public_video'))
        .height($r('app.float.common_image'))
        .width($r('app.float.common_image'))
        .onClick((event: ClickEvent) => {
          let navPath = AppStorage.get('pageInfos') as NavPathStack;
          navPath.pushPath({ name: 'PipWindowComponent' });
        })
    }
    .backgroundColor(Color.Transparent)
    .gesture(
      PanGesture(this.panOption)
        .onActionStart((event: GestureEvent) => {})
        .onActionUpdate((event: GestureEvent) => {
          this.windowPosition.x += event.offsetX;
          this.windowPosition.y += event.offsetY;
          let top = this.getUIContext().vp2px(56);
          let bottom = display.getDefaultDisplaySync().height - this.subWindow.getWindowProperties().windowRect.height
            - top;
          if (this.windowPosition.y < top) {
            this.windowPosition.y = top;
          } else if (this.windowPosition.y > bottom) {
            this.windowPosition.y = bottom;
          }
          this.subWindow.moveWindowTo(this.windowPosition.x, this.windowPosition.y);
        })
        .onActionEnd((event: GestureEvent) => {
          if (this.windowPosition.x >= display.getDefaultDisplaySync().width / 2) {
            this.windowPosition.x = display.getDefaultDisplaySync().width -
            this.subWindow.getWindowProperties().windowRect.width;
          } else if (event.offsetX < display.getDefaultDisplaySync().width / 2) {
            this.windowPosition.x = 0;
          }
          let top = this.getUIContext().vp2px(56);
          let bottom = display.getDefaultDisplaySync().height - this.subWindow.getWindowProperties().windowRect.height
            - top;
          if (this.windowPosition.y < top) {
            this.windowPosition.y = top;
          } else if (this.windowPosition.y > bottom) {
            this.windowPosition.y = bottom;
          }
          this.subWindow.moveWindowTo(this.windowPosition.x, this.windowPosition.y);
        })
    )
  }
}