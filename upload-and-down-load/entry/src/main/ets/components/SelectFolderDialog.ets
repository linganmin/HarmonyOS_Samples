/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { logger } from '@ohos/uploaddownload';

const TAG: string = 'SelectFolderDialog';

const PADDING_LEFT: Length = 24;
const PADDING_RIGHT: Length = 24;
const PADDING_TOP: Length = 24;
const PADDING_BUTTON: Length = 24;
const BORDER_RADIUS: Length | BorderRadiuses = 20;
const FONT_SIZE = 20;
const FULL_WIDTH: Length = '100%';
const FONT_WEIGHT: string | number | FontWeight = 500;
const COLUMN_OPACITY = 0.9;
const TEXT_FONT_SIZE = 16;
const BUTTON_HEIGHT: Length = 40;
const BUTTON_MARGIN: Length | Padding = 5;
const RADIO_SIZE: Length = 20;
const MARGIN_BUTTON: Length = 12;
const TEXT_HEIGHT: Length = 56;

@CustomDialog
export struct SelectFolderDialog {
  @Consume downloadFolder: Array<string>;
  @State selectedFolder: string = '';
  private controller: CustomDialogController = new CustomDialogController({ builder: null });
  public selectFolder: (folder: string) => void = () => {
  };

  build() {
    Column() {
      Text($r('app.string.download_to'))
        .fontSize(FONT_SIZE)
        .width(FULL_WIDTH)
        .fontWeight(FONT_WEIGHT)
        .fontColor($r('app.color.text_normal'))
        .opacity(COLUMN_OPACITY)
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .margin({ bottom: MARGIN_BUTTON })
      ForEach(this.downloadFolder, (item: string, index?: number) => {
        if (index && index !== 0) {
          Divider()
        }
        Row() {
          Text(item)
            .id('menu' + index)
            .fontSize(TEXT_FONT_SIZE)
          Blank()
          Radio({ group: 'folder', value: item })
            .size({
              width: RADIO_SIZE,
              height: RADIO_SIZE
            })
            .checked(item === this.selectedFolder)
            .radioStyle({ checkedBackgroundColor: $r('app.color.button_blue') })
            .onChange((isCheck: boolean) => {
              if (isCheck) {
                this.selectedFolder = item;
                logger.info(TAG, `this.selectedFolder = ${this.selectedFolder}`);
              }
            })
        }
        .width('100%')
        .height(TEXT_HEIGHT)
        .onClick(() => {
          this.selectedFolder = item;
          logger.info(TAG, `this.selectedFolder = ${this.selectedFolder}`);
        })
      }, (item: string, index: number) => index + item)
      Row() {
        Button() {
          Text($r('app.string.cancel'))
            .fontColor($r('app.color.btn_text_blue'))
            .fontSize(TEXT_FONT_SIZE)
        }
        .height(BUTTON_HEIGHT)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .margin(BUTTON_MARGIN)
        .onClick(() => {
          this.controller.close()
        })

        Divider()
          .vertical(true)
          .width(1)

        Button() {
          Text($r('app.string.ok'))
            .fontColor($r('app.color.btn_text_blue'))
            .fontSize(TEXT_FONT_SIZE)
        }
        .height(BUTTON_HEIGHT)
        .layoutWeight(1)
        .backgroundColor(Color.Transparent)
        .margin(BUTTON_MARGIN)
        .onClick(() => {
          this.controller.close();
          this.selectFolder(this.selectedFolder);
        })
      }
      .width(FULL_WIDTH)
      .height(BUTTON_HEIGHT)
    }
    .width(FULL_WIDTH)
    .alignItems(HorizontalAlign.Start)
    .border({
      color: Color.Gray,
      radius: BORDER_RADIUS
    })
    .padding({
      left: PADDING_LEFT,
      right: PADDING_RIGHT,
      top: PADDING_TOP,
      bottom: PADDING_BUTTON
    })
  }
}