/*
 * Copyright (c) 2022-2023 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct VideoPage {
  @State videoSrc: Resource = $rawfile('video1.mp4');
  @State controls: boolean = false;
  @State isFull: boolean = false;
  @State isPause: boolean = true;
  @State isPlayClick: boolean = true;
  @State firstClick: boolean = true;
  @State isHidden: boolean = true;
  @Link isStart: boolean;
  @Consume('playTime') updateTime: number;
  detailVideoController: VideoController = new VideoController();

  build() {
    Column() {
      Stack() {
        Video({
          src: this.videoSrc,
          controller: this.detailVideoController
        })
          .width('100%')
          .backgroundColor(this.isHidden ? '#ffffff' : '#000000')
          .aspectRatio(1.12)
          .controls(this.controls)
          .objectFit(ImageFit.Contain)
          .onUpdate((e) => {
            this.updateTime = e.time;
          })
          .onPrepared((e) => {
            hilog.info(0x0000, 'VideoPage', 'VideoPage_onPrepared:' + e.duration);
          })
          .onClick(() => {
            // Check whether the play button has been used. If not, go to this layer.
            if (this.isPlayClick) {
              // Click the video for the first time to start playing.
              // Click the video again to enter the full screen.
              if (this.firstClick) {
                this.detailVideoController.start();
                this.isHidden = !this.isHidden;
                this.isStart = true;
                this.firstClick = !this.firstClick;
              } else {
                this.getUIContext().getRouter().pushUrl({
                  url: 'pages/FullPage',
                  params: {
                    videoSrc: this.videoSrc,
                    videoTime: this.updateTime
                  }
                })
                  .catch((err: BusinessError) => {
                    hilog.error(0x0000, 'VideoPage', `Failed to push url. Cause code: ${err.code}, message: ${err.message}`);
                });
              }
            } else {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/FullPage',
                params: {
                  videoSrc: this.videoSrc,
                  videoTime: this.updateTime
                }
              })
                .catch((err: BusinessError) => {
                  hilog.error(0x0000, 'VideoPage', `Failed to push url. Cause code: ${err.code}, message: ${err.message}`);
              });
            }
          })
          .onFinish(() => {
            this.isHidden = true;
            this.isStart = false;
          })

        // Blank layer preview.
        if(this.isHidden){
          Column() {
            Image($r('app.media.previewImg'))
              .id('previewImg')
              .objectFit(ImageFit.Contain)
          }
          .width('100%')
          .aspectRatio(1.12)
          .backgroundColor('#ffffff')
        }

        if(this.isHidden){
          Column() {
            Image($r('app.media.play'))
              .id('playBtn')
              .width(76)
              .height(76)
              .onClick(() => {
                this.detailVideoController.start();
                this.isHidden = !this.isHidden;
                this.isStart = true;
                this.isPlayClick = false;
              })
          }
        }
      }
      .width('100%')
      .height('100%')
    }
  }
}