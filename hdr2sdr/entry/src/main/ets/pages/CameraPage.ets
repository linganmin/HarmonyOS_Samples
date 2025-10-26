/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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

import { display } from '@kit.ArkUI';
import { CommonConstants as Const } from '../common/CommonConstants';
import { RecordController } from '../controller/RecordController'
import { AVCodecController } from '../controller/AVCodecController'
import { dateTime } from '../common/utils/DateTimeUtils';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

interface CameraParams {
  mode: number;
}

const TAG = '[CameraPage]';

@Entry
@Component
struct CameraPage {
  @State mode: number = 0; //0 avRecord 1 AVCodec
  @State recording: boolean = false;
  @State isEnable: boolean = true;
  @State videoRecorderTimeText: string = Const.DEFAULT_TIME;
  private recordController: RecordController = new RecordController();
  private aVCodecController: AVCodecController = new AVCodecController()
  private XComponentController: XComponentController = new XComponentController();
  private XComponentSurfaceId: string = Const.DEFAULT_ID;
  private cameraWidth: number = Const.DEFAULT_WIDTH;
  private cameraHeight: number = Const.DEFAULT_HEIGHT;
  private display: display.Display | null = null;
  private heightPx = Const.DEFAULT_ID;
  private widthPx = Const.DEFAULT_ID;
  private timer: number = Const.DEFAULT_VALUE;
  private seconds: number = Const.DEFAULT_VALUE;

  getRecordTime(): void {
    this.timer = setInterval(() => {
      this.seconds += 1;
      this.videoRecorderTimeText = dateTime(this.seconds);
    }, 1000);
  }

  aboutToAppear(): void {
    try {
      this.display = display.getDefaultDisplaySync();
      if (!this.display) {
        throw new Error('Failed to get display instance');
      }
      this.heightPx = (this.display.width * this.cameraWidth / this.cameraHeight) + Const.PX;
      this.widthPx = this.display.width + Const.PX;
    } catch (error) {
      hilog.error(0x0000, TAG,
        `getSupportedCameras call failed. code is =${error.code}, message is = ${error.message}`);
    }
    const params = this.getUIContext().getRouter().getParams() as CameraParams;
    if (params.mode) {
      this.mode = params.mode;
    }
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      XComponent({
        id: 'recorderXComponent',
        type: XComponentType.SURFACE,
        controller: this.XComponentController
      })
        .onLoad(async () => {
          this.XComponentSurfaceId = this.XComponentController.getXComponentSurfaceId();
          if (this.mode === 0) {
            await this.recordController.initCamera(this.getUIContext().getHostContext()!, this.XComponentSurfaceId);
          } else {
            await this.aVCodecController.createRecorder(this.getUIContext().getHostContext()!, this.XComponentSurfaceId)
          }
        })
        .width(this.widthPx)
        .height(this.heightPx)
        .position({ x: '50%', y: '50%' })
        .translate({ x: '-50%', y: '-50%' })


      if (this.videoRecorderTimeText !== Const.DEFAULT_TIME) {
        Row() {
          Circle()
            .width(8)
            .height(8)
            .fill(Color.Red)
            .margin({ right: 10 })
          Text(this.videoRecorderTimeText)
            .fontFamily('HarmonyHeilTi-Light')
            .fontSize(20)
            .fontColor(Color.White)
        }
        .align(Alignment.Top)
        .margin({ top: 20 })
      }
      if (this.videoRecorderTimeText == Const.DEFAULT_TIME) {
        Text(Const.DEFAULT_TIME)
          .fontFamily('HarmonyHeilTi-Light')
          .fontSize(35)
          .fontColor(Color.White)
          .align(Alignment.Top)
          .margin({ top: 80 })
      }
      Image(this.recording ? $r('app.media.camera_pause_video_4x') : $r('app.media.camera_take_video_4x'))
        .width(60)
        .height(60)
        .position({ x: '50%', y: '90%' })
        .translate({ x: '-50%', y: '-100%' })
        .onClick(async () => {
          if (this.recording) {
            this.isEnable = false;
            clearInterval(this.timer);
            await (this.mode === 0 ? this.recordController.stopRecord().catch((error: BusinessError) => {
              hilog.error(0x0000, TAG, `stopRecord failed. code is =${error.code}, message is = ${error.message}`);
            }) : this.aVCodecController.stopRecord());
            this.getUIContext().getRouter().back();
            return;
          }
          this.getRecordTime();
          await (this.mode === 0 ? this.recordController.startRecord() : this.aVCodecController.startRecord());
          this.recording = !this.recording;
        })
        .enabled(this.isEnable)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(Color.Black)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}