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

import { BusinessError } from '@kit.BasicServicesKit';
import { CameraDataModel } from '../model/CameraDateModel';
import { PermissionsFromUser } from '../common/utils/PermissionsUtils';
import { AVPlayerController } from '../controller/AVPlayerController';
import { SaveDialog } from '../view/SaveDialog';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[Recording]';

@Builder
export function RecordingBuilder() {
  Recording();
}

@Component
struct Recording {
  @Consume('navPathStack') PathStack: NavPathStack;
  @State mode: number = 0; //0 avRecord 1 AVCodec
  @State viewState: number = 0; // Display video files
  @StorageLink('path') @Watch('pathChange') path: string = '';
  @State avPlayerController: AVPlayerController = new AVPlayerController();
  private cameraData: CameraDataModel = new CameraDataModel();
  private XComponentSurfaceId: string = '';
  private XComponentController: XComponentController = new XComponentController();

  aboutToAppear() {
    this.mode = this.PathStack.getParamByName('Recording').pop() as number;
    PermissionsFromUser();
  }

  aboutToDisappear(): void {
    this.avPlayerController.videoRelease();
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Text($r('app.string.HDR_video_recording'))
            .fontWeight(700)
            .fontSize(18)
            .margin({
              left: 16,
              bottom: 5
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
        .alignRules({
          'top': { 'anchor': '__container__', 'align': VerticalAlign.Top },
          'left': { 'anchor': '__container__', 'align': HorizontalAlign.Start }
        })

        Stack({ alignContent: Alignment.Center }) {
          Text($r('app.string.video_record_before_are'))
            .fontSize(14)
            .fontColor($r('app.color.video_processing_after_area_hint_font_color'))
            .textAlign(TextAlign.Center)
            .backgroundColor($r('app.color.video_processing_after_area_bg_color'))
            .width('100%')
            .height('100%')
            .visibility(this.viewState === 0 ? Visibility.Visible : Visibility.Hidden)
          XComponent({ id: 'Player', type: XComponentType.SURFACE, controller: this.XComponentController })
            .width('100%')
            .height('100%')
            .onLoad(() => {
              this.XComponentSurfaceId = this.XComponentController.getXComponentSurfaceId();
            })
            .visibility(this.viewState === 1 ? Visibility.Visible : Visibility.Hidden)
          if (!this.avPlayerController.isPlaying && this.viewState === 1) {
            Image($r('app.media.icon_pause'))
              .size({ width: 50, height: 50 })
          }
        }
        .onClick(() => {
          this.avPlayerController.isPlaying === true ? this.avPlayerController.videoPause() :
            this.avPlayerController.videoPlay()
        })
        .width('100%')
        .layoutWeight(1)

        Row() {
          Button($r('app.string.record_video'))
            .layoutWeight(1)
            .backgroundColor($r('app.color.button_bg_color'))
            .fontColor($r('app.color.button_text_color'))
            .fontWeight(500)
            .margin({ right: 6 })
            .onClick(async () => {
              AppStorage.set('cameraData', this.cameraData)
              this.getUIContext()
                .getRouter()
                .pushUrl({ url: 'pages/CameraPage', params: { mode: this.mode } })
                .catch((error: BusinessError) => {
                  hilog.error(0x0000, TAG,
                    `pushUrl fail, error code is =${error.code}, message is = ${error.message}`);
                })
            })
          SaveDialog()
        }
        .justifyContent(FlexAlign.Center)
        .margin({
          left: 16,
          top: 12,
          right: 16,
          bottom: 12
        })
      }
      .height('100%')
      .margin({ top: 10 })

    }
    .onReady((context: NavDestinationContext) => {
      this.PathStack = context.pathStack;
    })
    .hideTitleBar(true)
  }

  pathChange() {
    if (this.path !== '') {
      this.avPlayerController.initAVPlayer(this.XComponentSurfaceId, this.path);
      this.viewState = 1;
    }
  }
}