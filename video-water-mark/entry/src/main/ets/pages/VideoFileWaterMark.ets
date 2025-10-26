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

import nativeRender from 'libnativerender.so';
import { fileIo } from '@kit.CoreFileKit';
import { LoadingDialog } from '@kit.ArkUI';
import { CustomButton } from '../components/CustomButton';
import Logger from '../commonutils/Logger';

const TAG = 'VideoFileWaterMark'

@Builder
export function VideoFileWaterMarkBuilder() {
  VideoFileWaterMarkPage();
}

@Entry
@Component
export struct VideoFileWaterMarkPage {
  private mVideoController: VideoController = new VideoController();
  @State path: Resource | string = $rawfile('video_sample.mp4');

  dialogController: CustomDialogController = new CustomDialogController({
    builder: LoadingDialog({
      content: $r('app.string.Video_reminder_message')
    }),
    autoCancel: false,
    onWillDismiss: (() => {
      Logger.info(TAG, 'onWillDismiss');
    })
  });

  onPageShow(): void {
    this.path = $rawfile('video_sample.mp4');
    this.mVideoController.start();
  }

  build() {
    NavDestination() {
      Column() {
        Video({
          src: this.path,
          controller: this.mVideoController,
        })
          .objectFit(ImageFit.Auto)
          .width('100%')
          .height(218)
          .autoPlay(true)
          .controls(false)
          .loop(true)

        CustomButton({
          buttonName: $r('app.string.Add_watermark_button'),
          buttonOnClick: () => {
            this.path = $rawfile('video_sample.mp4');
            this.mVideoController.start();
            this.dialogController.open();
            this.getUIContext().getHostContext()?.resourceManager.getRawFd('video_sample.mp4').then((inputDesc) => {
              let outputFile = fileIo.openSync(this.getUIContext().getHostContext()?.cacheDir + '/transform.mp4',
                fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
              nativeRender.startTransform(inputDesc.fd, inputDesc.offset, inputDesc.length, outputFile.fd,
                () => {
                  this.mVideoController.reset();
                  this.path = 'file://' + this.getUIContext().getHostContext()?.cacheDir + '/transform.mp4';
                  this.mVideoController.start();
                  this.dialogController.close();
                })
            });
          }
        })
          .margin({ left: 16, right: 16, bottom: 16 })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title($r('app.string.Video_file_scene'))
  }
}