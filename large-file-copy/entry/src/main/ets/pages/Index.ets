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

import { common } from '@kit.AbilityKit';
import { resourceManager } from '@kit.LocalizationKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BigFileCopyConstants } from '../constants/BigFileCopyConstants';

@Extend(Button)
function customButtonStyle() {
  .width(BigFileCopyConstants.COMPONENT_SIZE)
  .height($r('app.float.button_height'))
  .fontSize($r('sys.float.ohos_id_text_size_body1'))
  .margin({ top: $r('app.float.button_margin') })
}

@Entry
@Component
struct BigFileCopyView {
  UIContext = this.getUIContext()
  @State progress: number = BigFileCopyConstants.PROGRESS_MIN;
  @State isCopyFinished: boolean = false;
  @State isEnableSmooth: boolean = true;
  @State isPreview: boolean = false;
  context: common.UIAbilityContext = this.UIContext.getHostContext() as common.UIAbilityContext;
  fileName: string = BigFileCopyConstants.TEST_FILE_NAME;
  targetFilePath: string = BigFileCopyConstants.STRING_EMPTY;
  private gradientColor: LinearGradient = new LinearGradient([
    { color: Color.Yellow, offset: BigFileCopyConstants.PROGRESS_STEP_ONE },
    { color: Color.Orange, offset: BigFileCopyConstants.PROGRESS_STEP_TWO },
    { color: Color.Red, offset: BigFileCopyConstants.PROGRESS_STEP_THREE },
    { color: Color.Pink, offset: BigFileCopyConstants.PROGRESS_STEP_FOUR }
  ]);

  copyFile2Sandbox() {
    this.isCopyFinished = false;
    try {
      const data: resourceManager.RawFileDescriptor = this.context.resourceManager.getRawFdSync(this.fileName);
      const targetPath: string = this.context.filesDir + BigFileCopyConstants.FILE_PATH_SYMBOL + this.fileName;
      const destFile: fileIo.File = fileIo.openSync(targetPath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      let buffSize: number = BigFileCopyConstants.BUFF_SIZE;
      const buffer: ArrayBuffer = new ArrayBuffer(Math.min(buffSize, data.length));
      // Offset of the record read position (compared with the start offset of the file)
      let off: number = BigFileCopyConstants.NUMBER_ZERO;
      // Actual length of the read content.
      let len: number = fileIo.readSync(data.fd, buffer, { offset: data.offset + off, length: buffSize });
      // Record the length of the read file.
      let readLen: number = BigFileCopyConstants.NUMBER_ZERO;
      while (len > 0) {
        readLen += len;
        fileIo.writeSync(destFile.fd, buffer, { offset: off, length: len });
        this.progress = Math.floor((readLen / data.length) * BigFileCopyConstants.NUMBER_HUNDRED);
        off = off + len;
        if ((data.length - readLen) < buffSize) {
          buffSize = data.length - readLen;
        }
        len = fileIo.readSync(data.fd, buffer, { offset: data.offset + off, length: buffSize });
      }
      this.targetFilePath = targetPath;
      fileIo.closeSync(destFile.fd);
      this.isCopyFinished = true;
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x00, 'BigFileCopyView', `file openSync failed, code = ${err.code}, message = ${err.message}`);
    }

  }

  setIsPreview(status: boolean): void {
    this.UIContext.animateTo({ duration: BigFileCopyConstants.ANIMATION_DURATION, curve: Curve.Friction }, () => {
      this.isPreview = status;
    })
  }

  build() {
    Column() {
      Stack() {
        if (!this.isPreview) {
          Stack() {
            Progress({
              value: this.progress,
              total: BigFileCopyConstants.PROGRESS_MAX,
              type: ProgressType.Ring
            })
              .color(this.gradientColor)
              .size({ width: BigFileCopyConstants.COMPONENT_SIZE, height: BigFileCopyConstants.COMPONENT_SIZE })
              .style({ strokeWidth: $r('app.float.process_width'), enableSmoothEffect: this.isEnableSmooth })
              .zIndex(BigFileCopyConstants.Z_INDEX_ONE)
            Column() {
              Row() {
                Text(this.progress.toString())
                  .font({ size: $r('app.float.process_value_font_size'), weight: BigFileCopyConstants.FONT_WEIGHT_SIX })
                Text(BigFileCopyConstants.PERCENT)
                  .fontSize($r('app.float.process_percent_font_size'))
              }
              .alignItems(VerticalAlign.Bottom)

              Text($r('app.string.current_copy_process'))
                .opacity(BigFileCopyConstants.OPACITY_FORTY_PERCENT)
                .margin({ top: $r('sys.float.ohos_id_elements_margin_vertical_m') })
                .zIndex(BigFileCopyConstants.Z_INDEX_TWO)
            }
          }
          .margin({ top: $r('app.float.picture_margin_top') })

        } else {
          Image(BigFileCopyConstants.SANDBOX_PREFIX + this.targetFilePath)
            .margin({ top: $r('app.float.picture_margin_top') })
            .width(BigFileCopyConstants.COMPONENT_SIZE)
            .height(BigFileCopyConstants.COMPONENT_SIZE)
            .borderRadius($r('sys.float.ohos_id_corner_radius_default_m'))
        }
      }

      Column() {
        Button($r('app.string.largeFileCopy_copy_button_msg'))
          .customButtonStyle()
          .enabled(!this.isCopyFinished)
          .onClick(() => {
            this.copyFile2Sandbox();
          })
        Button($r('app.string.largeFileCopy_reset_button_msg'))
          .customButtonStyle()
          .enabled(this.isCopyFinished)
          .onClick(() => {
            this.progress = BigFileCopyConstants.PROGRESS_MIN;
            this.isCopyFinished = false;
            this.setIsPreview(false);
          })
        Button($r('app.string.largeFileCopy_preview_button_msg'))
          .customButtonStyle()
          .enabled(this.isCopyFinished)
          .margin({ top: $r('app.float.button_margin'), bottom: $r('app.float.picture_margin_bottom') })
          .onClick(() => {
            this.setIsPreview(true);
          })
      }
    }
    .width($r('app.string.largeFileCopy_full_size'))
    .height($r('app.string.largeFileCopy_full_size'))
    .justifyContent(FlexAlign.SpaceBetween)
    .alignItems(HorizontalAlign.Center)
  }
}