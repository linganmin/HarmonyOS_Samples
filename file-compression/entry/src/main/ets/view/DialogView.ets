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

import { FileConstants } from '../constant/FileConstants';
import { CompressUtil } from '../utils/CompressUtil';

@CustomDialog
export struct PreviewDialog {
  private dialogController?: CustomDialogController;
  private fileContent: string = '';

  build() {
    Column() {
      Text(FileConstants.TITLE[1])
        .fontSize($r('app.float.preview_title_font'))
        .lineHeight($r('app.float.preview_title_font_line'))
        .fontWeight(FileConstants.FONT_WEIGHT_500)
        .margin({
          top: $r('app.float.preview_title_margin'),
          bottom: $r('app.float.preview_title_margin')
        })

      Scroll() {
        Column() {
          Text(this.fileContent)
            .fontSize($r('app.float.preview_content_font'))
            .lineHeight($r('app.float.preview_content_font_line'))
            .fontWeight(FileConstants.FONT_WEIGHT_500)
        }
        .width(FileConstants.FULL_PERCENT)
        .padding({
          left: $r('app.float.preview_content_padding'),
          right: $r('app.float.preview_content_padding')
        })
      }
      .layoutWeight(1)
      .width(FileConstants.FULL_PERCENT)

      Row() {
        Text(FileConstants.BUTTON_TEXTS[0])
          .fontSize($r('app.float.preview_button_font'))
          .lineHeight($r('app.float.preview_button_font_line'))
          .fontWeight(FileConstants.FONT_WEIGHT_500)
          .fontColor($r('app.color.operation_font'))
      }
      .justifyContent(FlexAlign.Center)
      .width(FileConstants.FULL_PERCENT)
      .height($r('app.float.preview_operation_row_height'))
      .margin({
        top: $r('app.float.preview_operation_margin_top'),
        bottom: $r('app.float.preview_operation_margin_bottom')
      })
      .onClick(() => {
        this.dialogController?.close();
      })
    }
    .width(FileConstants.NINETY_PERCENT)
    .height($r('app.float.preview_dialog_height'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.preview_dialog_radius'))
    .padding({
      left: $r('app.float.preview_dialog_padding'),
      right: $r('app.float.preview_dialog_padding')
    })
  }
}

@CustomDialog
export struct CompressDialog {
  private dialogController?: CustomDialogController;
  private fileName: string = '';
  private compressType: ResourceStr = '';
  private compressUtil: CompressUtil = new CompressUtil();

  build() {
    Column() {
      Text(FileConstants.TITLE[2])
        .fontSize($r('app.float.preview_title_font'))
        .lineHeight($r('app.float.preview_title_font_line'))
        .fontWeight(FileConstants.FONT_WEIGHT_500)
        .margin({
          top: $r('app.float.preview_title_margin'),
          bottom: $r('app.float.preview_title_margin')
        })

      List() {
        ForEach(FileConstants.COMPRESS_TYPES, (item: string, index: number) => {
          ListItem() {
            Row() {
              Text(item)
                .fontSize($r('app.float.compress_list_font'))
                .lineHeight($r('app.float.compress_list_font_line'))
                .fontWeight(FileConstants.FONT_WEIGHT_500)
              Blank()
              Radio({ value: item, group: FileConstants.COMPRESS_GROUP })
                .onChange((isChecked: boolean) => {
                  if (isChecked) {
                    this.compressType = item;
                  }
                })
            }
            .height($r('app.float.compress_row_height'))
            .width(FileConstants.FULL_PERCENT)
          }
        }, (item: string, index: number) => item + index)
      }
      .padding({
        left: $r('app.float.preview_content_padding'),
        right: $r('app.float.preview_content_padding')
      })
      .layoutWeight(1)
      .width(FileConstants.FULL_PERCENT)

      Row() {
        Text(FileConstants.BUTTON_TEXTS[0])
          .fontSize($r('app.float.preview_button_font'))
          .lineHeight($r('app.float.preview_button_font_line'))
          .fontWeight(FileConstants.FONT_WEIGHT_500)
          .fontColor($r('app.color.operation_font'))
      }
      .justifyContent(FlexAlign.Center)
      .width(FileConstants.FULL_PERCENT)
      .height($r('app.float.preview_operation_row_height'))
      .margin({
        top: $r('app.float.preview_operation_margin_top'),
        bottom: $r('app.float.preview_operation_margin_bottom')
      })
      .onClick(() => {
        if (this.compressType === '') {
          this.dialogController?.close();
          return;
        }
        switch (this.compressType) {
          case FileConstants.COMPRESS_TYPES[0]:
            this.compressUtil.compressIntoGzip(this.fileName);
            break;
          case FileConstants.COMPRESS_TYPES[1]:
            this.compressUtil.compressIntoZip(this.fileName);
            break;
          case FileConstants.COMPRESS_TYPES[2]:
            this.compressUtil.compressInto7z(this.fileName);
            break;
          case FileConstants.COMPRESS_TYPES[3]:
            this.compressUtil.compressIntoTar(this.fileName);
            break;
          default:
            break;
        }
        this.dialogController?.close();
      })
    }
    .width(FileConstants.NINETY_PERCENT)
    .height($r('app.float.compress_dialog_height'))
    .backgroundColor(Color.White)
    .borderRadius($r('app.float.preview_dialog_radius'))
    .padding({
      left: $r('app.float.preview_dialog_padding'),
      right: $r('app.float.preview_dialog_padding')
    })
  }
}