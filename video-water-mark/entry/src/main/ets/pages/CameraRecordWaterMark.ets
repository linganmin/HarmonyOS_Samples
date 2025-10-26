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

import XComponentContext from '../commonutils/XComponentContext';
import { CustomButton } from '../components/CustomButton';
import Logger from '../commonutils/Logger';

const TAG = 'CameraPage'

@Builder
export function CameraRecordWaterMarkBuilder() {
  CameraRecordWaterMarkPage();
}

@Entry
@Component
export struct CameraRecordWaterMarkPage {
  @State recorderButtonName: Resource = $r('app.string.Start_record');
  @State playerButtonName: Resource = $r('app.string.Start_play');
  @State isPlayed: boolean = false;
  @State isRecorded: boolean = false;
  private xComponentContext?: XComponentContext;
  private mXComponentController: XComponentController = new XComponentController();
  private mVideoController: VideoController = new VideoController();
  private videoSrc: string = 'file:///data/storage/el2/base/files/recorder01.mp4';

  onPageShow(): void {
    if (this.xComponentContext) {
      this.xComponentContext.StartCamera();
    }
  }

  onPageHide(): void {
    if (this.xComponentContext) {
      if (this.isPlayed) {
        this.playerButtonName = $r('app.string.Start_play');
        this.isPlayed = false;
      }
      if (this.isRecorded) {
        this.xComponentContext.StopRecorder();
        this.recorderButtonName = $r('app.string.Start_record');
        this.isRecorded = false;
      }
      this.xComponentContext.StopCamera();
    }
  }

  build() {
    NavDestination() {
      Column() {
        Stack({alignContent:Alignment.TopStart}) {
          XComponent({
            id: 'XComponentId',
            type: XComponentType.SURFACE,
            libraryname: 'nativerender',
            controller: this.mXComponentController
          })
            .width('100%')
            .height(550)
            .onLoad((xComponentContext) => {
              Logger.info(TAG, 'onLoad');
              this.xComponentContext = xComponentContext as XComponentContext;
              this.xComponentContext.StartCamera();
            })
            .onDestroy(() => {
              Logger.info(TAG, 'onDestroy');
            })
            .layoutWeight(1)

          if (this.isPlayed) {
            Video({
              src: this.videoSrc,
              controller: this.mVideoController
            })
              .width('100%')
              .height(550)
              .autoPlay(true)
              .controls(false)
              .loop(true)
          }
        }

        CustomButton({
          buttonName: this.recorderButtonName,
          buttonOnClick: () => {
            if (this.isRecorded === false) {
              AppStorage.setOrCreate('recordFileExist', true);
              this.isRecorded = true;
              this.recorderButtonName = $r('app.string.Stop_record');
              if (this.xComponentContext) {
                this.xComponentContext.StartRecorder(true);
              }
            } else {
              this.isRecorded = false;
              this.recorderButtonName = $r('app.string.Start_record');
              if (this.xComponentContext) {
                this.xComponentContext.StopRecorder();
              }
            }
          }
        })
          .enabled(!this.isPlayed)
          .margin({left: 16, right: 16, top: 16, bottom: 12})

        CustomButton({
          buttonName: this.playerButtonName,
          buttonOnClick: () => {
            if (this.isPlayed === false) {
              if (AppStorage.get('recordFileExist') as boolean == false) {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.Camera_reminder_message'),
                  duration: 2000,
                  bottom: 62
                })
                return;
              }
              this.playerButtonName = $r('app.string.Stop_play');
              this.isPlayed = true;
              if (this.xComponentContext) {
                this.xComponentContext.StopCamera();
              }
            } else {
              this.playerButtonName = $r('app.string.Start_play');
              this.isPlayed = false;
              if (this.xComponentContext) {
                this.xComponentContext.StartCamera();
              }
            }
          }
        })
          .enabled(!this.isRecorded)
          .margin({left: 16, right: 16, bottom: 16})
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title($r('app.string.Camera_record_scene'))
  }
}