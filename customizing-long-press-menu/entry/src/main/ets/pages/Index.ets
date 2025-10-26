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

import { webview } from '@kit.ArkWeb';
import { pasteboard } from '@kit.BasicServicesKit';
import { common, Want } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { logger } from '../common/Utils';
import { CommonConstants } from '../common/CommonConstants';

@Entry
@Component
struct WebCustomPressMenu {
  @State linkUrl: string | undefined = undefined;
  @State showMenu: boolean = false;
  @State isExistImage: boolean = false;
  private result: WebContextMenuResult | undefined = undefined;
  private param: WebContextMenuParam | undefined = undefined;
  private inputType: ContextMenuInputFieldType = ContextMenuInputFieldType.None;
  private pressPosX: number = 0;
  private pressPosY: number = 0;
  private webWidth: number = 0;
  private webHeight: number = 0;
  private context: common.UIAbilityContext = {} as common.UIAbilityContext;

  aboutToAppear() {
    webview.WebviewController.initializeWebEngine();
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    this.context = context;
  }

  @Builder
  menuBuilder() {
    Menu() {
      if (this.isExistImage) {
        MenuItem({
          content: $r('app.string.web_press_copy_image')
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL1)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            this.result?.copyImage();
            this.showMenu = false;
          })
      }
      if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_CUT) {
        MenuItem({
          content: $r('app.string.web_press_cut')
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL1)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            this.result?.cut();
            this.showMenu = false;
          })
      }
      if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_PASTE) {
        MenuItem({
          content: $r('app.string.web_press_copy')
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL1)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            this.result?.copy();
            this.showMenu = false;
          })
      }
      if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_PASTE) {
        MenuItem({
          content: $r('app.string.web_press_paste')
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL1)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            this.result?.paste();
            this.showMenu = false;
          })
      }
      if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_PASTE) {
        MenuItem({
          content: $r('app.string.web_press_select_all')
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL1)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            this.result?.selectAll();
            this.showMenu = false;
          })
      }
      if (this.linkUrl) {
        MenuItem({
          content: $r('app.string.web_press_open_link')
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL2)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            const wantInfo: Want = {
              action: 'ohos.want.action.viewData',
              entities: ['entity.system.browsable'],
              uri: this.linkUrl
            };
            this.context.startAbility(wantInfo).then(() => {
              logger.info(CommonConstants.TAG, 'startAbility succeed');
            }).catch((err: BusinessError) => {
              logger.error(CommonConstants.TAG, `startAbility failed, message is ${err.message}`);
              return;
            });
            this.showMenu = false;
          })
        MenuItem({
          content: $r('app.string.web_press_copy_link'),
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL1)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            const pasteData = pasteboard.createData('text/plain', this.linkUrl);
            pasteboard.getSystemPasteboard().setData(pasteData, (error) => {
              if (error) {
                logger.error(CommonConstants.TAG, 'Failed to set PasteData. Cause: ' + error.message);
                return;
              }
              logger.info(CommonConstants.TAG, 'Succeeded in setting PasteData.');
            });
            this.showMenu = false;
          })
      }
      if (this.inputType !== ContextMenuInputFieldType.None) {
        MenuItem({
          content: $r('app.string.web_press_input_field')
        })
          .width(CommonConstants.MENU_ITEM_WIDTH_LEVEL1)
          .height(CommonConstants.MENU_ITEM_HEIGHT)
          .onClick(() => {
            this.showMenu = false;
          })
      }
    }
  }

  build() {
    Column() {
      Web({ src: $rawfile('index.html'), controller: new webview.WebviewController() })
        .width(CommonConstants.ONE_HUNDRED_PERCENT)
        .height(CommonConstants.ONE_HUNDRED_PERCENT)
        .onAreaChange((oldArea, newArea) => {
          logger.info(CommonConstants.TAG, `${oldArea}`);
          this.webWidth = newArea.width as number;
          this.webHeight = newArea.height as number;
        })
        .onContextMenuShow((event) => {
          if (event) {
            this.result = event.result;
            this.param = event.param;
            this.pressPosX = this.getUIContext().px2vp(event.param.x());
            this.pressPosY = this.getUIContext().px2vp(event.param.y());
            logger.debug(CommonConstants.TAG, `x coord = ${this.pressPosX}, y coord = ${this.pressPosY}`);
            logger.info(CommonConstants.TAG, 'link url = ' + event.param.getLinkUrl());
            this.linkUrl = event.param.getLinkUrl();
            this.inputType = event.param.getInputFieldType();
            this.isExistImage = event.param.existsImageContents();
          }
          this.showMenu = true;
          return true;
        })
        .bindPopup(this.showMenu,
          {
            builder: this.menuBuilder(),
            enableArrow: false,
            placement: Placement.TopLeft,
            mask: false,
            offset: this.getPopupPosition(),
            onStateChange: (e) => {
              if (!e.isVisible) {
                this.showMenu = false;
                this.result!.closeContextMenu();
              }
            }
          })
    }
    .backgroundColor($r('app.color.background_color'))
    .expandSafeArea([SafeAreaType.SYSTEM],[SafeAreaEdge.BOTTOM, SafeAreaEdge.TOP])
    .width($r('app.string.web_press_full_size'))
    .height($r('app.string.web_press_full_size'))
  }

  getPopupPosition(): Position {
    let popupWidth: number = CommonConstants.MENU_ITEM_WIDTH_LEVEL1;
    let popupHeight: number = 0;
    if (this.param?.existsImageContents()) {
      popupHeight += CommonConstants.MENU_ITEM_HEIGHT;
    }
    if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_CUT) {
      popupHeight += CommonConstants.MENU_ITEM_HEIGHT;
    }
    if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_PASTE) {
      popupHeight += CommonConstants.MENU_ITEM_HEIGHT;
    }
    if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_PASTE) {
      popupHeight += CommonConstants.MENU_ITEM_HEIGHT;
    }
    if (this.param?.getEditStateFlags() === ContextMenuEditStateFlags.CAN_PASTE) {
      popupHeight += CommonConstants.MENU_ITEM_HEIGHT;
    }
    if (this.linkUrl) {
      popupWidth =
        CommonConstants.MENU_ITEM_WIDTH_LEVEL2 > popupWidth ? CommonConstants.MENU_ITEM_WIDTH_LEVEL2 : popupWidth;
      popupHeight += CommonConstants.MENU_ITEM_HEIGHT * 2;
    }
    if (this.inputType !== ContextMenuInputFieldType.None) {
      popupHeight += CommonConstants.MENU_ITEM_HEIGHT;
    }
    logger.debug(CommonConstants.TAG, `popup width: ${popupWidth}, height: ${popupHeight}`);

    let offset: Position = { x: 0, y: 0 };
    if (this.pressPosX <= this.webWidth / 2) {
      offset.x = -(this.webWidth / 2 - this.pressPosX) + popupWidth / 2 + CommonConstants.FINGER_OFFSET_X;
    } else {
      offset.x = -(this.webWidth / 2 - this.pressPosX) - popupWidth / 2 - CommonConstants.FINGER_OFFSET_X;
    }
    if (this.pressPosY <= this.webHeight / 2) {
      offset.y = -(this.webHeight / 2 - this.pressPosY) + popupHeight / 2 + CommonConstants.FINGER_OFFSET_Y;
    } else {
      offset.y = (this.pressPosY - this.webHeight / 2) - popupHeight / 2 - CommonConstants.FINGER_OFFSET_Y;
    }
    logger.debug(CommonConstants.TAG, `popup offset: ${offset.x}, ${offset.y}`);
    return offset;
  }
}