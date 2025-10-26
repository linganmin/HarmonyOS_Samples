/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { image } from '@kit.ImageKit';

@Component
export struct ChoseFile {
  onChooseFile: (() => void) | undefined = undefined;

  aboutToAppear(): void {

  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.upload_content'))
          .fontSize($r('app.float.size_14fp'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.font_black_gray'))
          .height($r('app.float.size_20vp'))
          .textAlign(TextAlign.Start)
          .width('100%')
          .margin({
            bottom: $r('app.float.size_8vp'),
            left: $r('app.float.size_8vp')
          })
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height($r('app.float.title_bar_default_height'))

      Stack() {
        UploadFile();
      }
      .borderRadius($r('app.float.size_16vp'))
      .borderStyle(BorderStyle.Dashed)
      .borderWidth(1)
      .borderColor($r('sys.color.background_emphasize'))
      .width('100%')
      .height($r('app.float.size_72vp'))
      .backgroundColor($r('app.color.upload_content'))
      .onClick(() => {
        this.onChooseFile?.();
      })

      Text($r('app.string.upload_tips'))
        .fontSize($r('app.float.size_14fp'))
        .height($r('app.float.size_19vp'))
        .fontColor($r('app.color.font_black_gray2'))
        .fontWeight(FontWeight.Normal)
        .textAlign(TextAlign.Start)
        .margin({
          top: $r('app.float.size_12vp'),
          left: $r('app.float.size_8vp')
        })
        .width('100%')
    }.width('100%')
  }
}

@Builder
function UploadFile() {
  Row() {
    Image($r('app.media.upload'))
      .width($r('app.float.size_24vp'))
      .height($r('app.float.size_24vp'))

    Text($r('app.string.upload_file'))
      .fontSize($r('app.float.size_16fp'))
      .fontWeight(FontWeight.Medium)
      .textAlign(TextAlign.Start)
      .fontColor($r('app.color.file_blue'))
      .margin({
        left: $r('app.float.size_8vp')
      })
  }
}

/**
 * Upload status
 * */
export enum UPLOAD_STATUS {
  NORMAL, // initial status
  UPLOADING, // uploading status
  SUCCESS, // upload success
  FAIL, // upload fail
}

@Component
export struct UploadComponent {
  @Prop uploadStatus: UPLOAD_STATUS = UPLOAD_STATUS.NORMAL;
  @Prop fileSize: string = '';
  @Prop submitResult: string = '';
  @Prop takesTime: string = '0.0s';
  @Prop uploadProgress: number = 0;
  @Consume imageInfo: image.PixelMap | string = '';
  onDeleteFile: (() => void) | undefined = undefined;
  onCancelUpload: (() => void) | undefined = undefined;

  aboutToAppear(): void {

  }

  build() {
    Row() {
      Image(this.imageInfo)
        .width($r('app.float.size_48vp'))
        .height($r('app.float.size_48vp'))
        .borderRadius(5)
      Row() {
        if (this.uploadStatus === UPLOAD_STATUS.NORMAL) {
          Text(this.fileSize)
            .fontSize($r('app.float.size_16fp'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .fontColor(Color.Black)

          Blank()

          Image($r('app.media.delete'))
            .height($r('app.float.size_22vp'))
            .onClick(() => {
              this.onDeleteFile?.();
            })
        } else if (this.uploadStatus === UPLOAD_STATUS.UPLOADING) {
          Column() {
            Row() {
              Text($r('app.string.submitting'))
                .fontSize($r('app.float.size_14fp'))
                .fontWeight(FontWeight.Normal)
                .textAlign(TextAlign.Start)
                .fontColor($r('sys.color.font_primary'))
              Blank()
              Text(this.takesTime)
                .fontSize($r('app.float.size_14fp'))
                .fontWeight(FontWeight.Normal)
                .textAlign(TextAlign.Start)
                .fontColor($r('sys.color.font_primary'))
              Blank().width($r('app.float.size_38vp'))
            }
            .width('100%')
            .height($r('app.float.size_19vp'))

            Row() {
              Progress({ value: 0, total: 1, type: ProgressType.Linear })
                .layoutWeight(1)
                .value(this.uploadProgress)
              Blank().width($r('app.float.size_16vp'))
              Image($r('app.media.cancel'))
                .width($r('app.float.size_22vp'))
                .height($r('app.float.size_22vp'))
                .onClick(() => {
                  this.onCancelUpload?.();
                })
            }
            .height($r('app.float.size_24vp'))
            .width('100%')
            .margin({
              top: $r('app.float.size_5vp')
            })
          }
          .width('100%')

        } else if (this.uploadStatus === UPLOAD_STATUS.SUCCESS) {
          Text(this.fileSize)
            .fontSize($r('app.float.size_16fp'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .fontColor(Color.Black)

          Blank()
          Text(this.submitResult)
            .fontSize($r('app.float.size_16fp'))
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.confirm'))
        } else if (this.uploadStatus === UPLOAD_STATUS.FAIL) {
          Text(this.fileSize)
            .fontSize($r('app.float.size_16fp'))
            .fontWeight(FontWeight.Medium)
            .textAlign(TextAlign.Start)
            .fontColor(Color.Black)

          Blank()
          Text(this.submitResult)
            .fontSize($r('app.float.size_16fp'))
            .fontWeight(FontWeight.Normal)
            .textAlign(TextAlign.Start)
            .fontColor($r('sys.color.multi_color_08'))
            .margin({
              left: $r('app.float.size_8vp')
            })
        }
      }
      .padding({
        left: $r('app.float.size_16vp')
      })
      .height('100%')
      .width('calc(100% - 48vp)')
    }
    .padding({
      left: $r('app.float.size_12vp'),
      right: $r('app.float.size_12vp'),
      top: $r('app.float.size_3vp'),
      bottom: $r('app.float.size_3vp')
    })
    .borderRadius($r('app.float.size_16vp'))
    .backgroundColor(Color.White)
    .width('100%')
    .height($r('app.float.size_72vp'))
  }
}
