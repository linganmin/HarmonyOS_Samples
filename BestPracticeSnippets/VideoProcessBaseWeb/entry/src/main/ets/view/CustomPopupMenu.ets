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

import { Position } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { copyLink, openVideoInBrowser, saveVideoToGallery } from '../utils/CustomFunction';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constants';

interface MenuItem {
  id: string,
  text: ResourceStr,
  caller?: Function,
};

const popupWidth: number = 180;
const singlePopupHeight: number = 50;
const menus: MenuItem[] = [
  {
    id: '001',
    text: $r('app.string.copy_video_link'),
    caller: copyLink

  },
  {
    id: '002',
    text: $r('app.string.open_video_in_browser'),
    caller: openVideoInBrowser

  },
  {
    id: '003',
    text: $r('app.string.download_video_to_gallery'),
    caller: saveVideoToGallery
  }
];
const popupHeight: number = menus.length * singlePopupHeight;
// [Start menu]
//src/main/ets/view/CustomPopupMenu.ets

/**
 * A custom popup menu Builder.
 *
 * @param uri - The URI for which the popup menu will be built.
 * @param context - The UI context in which the popup menu will be used. This should be an instance of `common.UIAbilityContext`.
 * @param openDownloadDialog - A function that, when called, will open a download dialog.
 * @param closeDownloadDialog - A function that, when called, will close the download dialog.
 * @param changeIsShow - A function that, when called, will change the visibility of certain UI elements.
 */
@Builder
export function customPopupMenuBuilder(
  uri: string,
  context: common.UIAbilityContext,
  openDownloadDialog: Function,
  closeDownloadDialog: Function,
  changeIsShow: Function
) {
  Column() {
    Menu() {
      ForEach(menus, (menu: MenuItem) => {
        MenuItem({
          content: menu.text
        })
          .height(singlePopupHeight)
          .onClick(() => {
            try {
              menu.caller && menu.caller(uri, context, openDownloadDialog, closeDownloadDialog);
              changeIsShow();
            } catch (e) {
              hilog.error(0x000, Constants.TAG, `some error happened, ${JSON.stringify(e)}`);
            }
          })
      }, (menu: MenuItem) => menu.id)
    }
    .width(popupWidth)
  }
}
// [End menu]


export function getOffset(
  webWidth: number,
  webHeight: number,
  pressPosX: number,
  pressPosY: number): Position {
  const defaultX = (webWidth - popupWidth) / 2;
  const defaultY = (webHeight - popupHeight) / 2;

  let offsetX = pressPosX - defaultX;
  if (pressPosX + popupWidth > webWidth) {
    offsetX = webWidth - popupWidth - defaultX - 10;
  } else if (pressPosX < 0) {
    offsetX = -defaultX;
  }

  let offsetY = pressPosY - defaultY;
  if (pressPosY + popupHeight > webHeight) {
    offsetY = webHeight - popupHeight - defaultY - 20;
  } else if (pressPosY < 0) {
    offsetY = -defaultY;
  }
  return { x: offsetX, y: offsetY };
}