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

import { taskpool } from '@kit.ArkTS';
import { DownLoadVideoInfo } from './model/DownLoadVideoInfo';
import { DownLoadCommandEnum } from './model/CommEnum';
import { DownLoadData } from './model/DownLoadData';
import { Constants } from '../constants/Constants';
import { DownLoadVideo } from './DownLoadVideo';
import Logger from '../utils/Logger';

@Component
export struct DownLoadComponent {
  @Require DownLoadData: DownLoadData = new DownLoadData('', '');
  @State buttonValue: ResourceStr = $r('app.string.start');
  @State showDetail: boolean = false;
  private dvi: DownLoadVideoInfo = new DownLoadVideoInfo('');
  private downLoadTask?: taskpool.Task;
  private start: boolean = false;
  private task: Promise<Object> | undefined = undefined;

  aboutToAppear(): void {
    this.dvi = new DownLoadVideoInfo(this.DownLoadData.downLoadUrl);
    this.downLoadTask = new taskpool.Task(DownLoadVideo, this.dvi);
    this.downLoadTask.onReceiveData((msg: string) => {
      switch (msg) {
        case 'UPDATE_DOWNLOAD_PROGRESS':
          this.DownLoadData.downLoadProgress = this.dvi.getDownLoadProgress();
          break;
        default:
          Logger.error('switch default');
          break;
      }
    })
  }

  build() {
    Column() {
      Row() {
        Image($r('app.media.startIcon'))
          .width($r('app.integer.comm_image_size48'))
          .height($r('app.integer.comm_image_size48'))

        // Content on the right.
        Column() {
          Row() {
            Text(this.DownLoadData.videoName)
              .width(Constants.FIFTY_PERCENT)
            Button(
              this.buttonValue,
              {
                type: ButtonType.Normal,
                stateEffect: true,
                buttonStyle: ButtonStyleMode.TEXTUAL
              })
              .onClick(() => {
                if (this.dvi.downLoadProgress === Constants.PROGRESS_TOTAL) {
                  return;
                } else {
                  this.start = !this.start;
                  this.buttonValue = this.start ? $r('app.string.pause') : $r('app.string.continue');
                  if (this.start) {
                    try {
                      this.dvi.command = DownLoadCommandEnum.CONTINUE_DOWNLOADING;
                      this.task = taskpool.execute(this.downLoadTask);
                      this.task.then(() => {
                        if (this.dvi.downLoadProgress === Constants.PROGRESS_TOTAL) {
                          this.buttonValue = $r('app.string.complete');
                          this.DownLoadData.long = this.dvi.videoInfo.long;
                          this.showDetail = true;
                        }
                      });
                    } catch (err) {
                      Logger.error(`Execute failed. Cause code: ${err.code}, message: ${err.message}`);
                    }
                  } else {
                    this.dvi.command = DownLoadCommandEnum.STOP_DOWNLOADING;
                  }
                }
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .width(Constants.FULL_PERCENT)
          .height(Constants.FIFTY_PERCENT)
          .borderRadius($r('app.integer.comm_border_radius4'))

          Row() {
            Progress({
              value: this.DownLoadData.downLoadProgress,
              total: Constants.PROGRESS_TOTAL,
              type: ProgressType.Capsule
            })
              .width(Constants.FULL_PERCENT)
              .height(Constants.FULL_PERCENT)
          }
          .width(Constants.FULL_PERCENT)
          .height(Constants.FIFTY_PERCENT)
        }
        .width(Constants.EIGHTY_PERCENT)
        .alignItems(HorizontalAlign.Start)
        .padding({
          left: $r('app.integer.comm_padding_margin16')
        })
      }
      .padding($r('app.integer.comm_padding_margin12'))
      .justifyContent(FlexAlign.Start)
      .width(Constants.FULL_PERCENT)

      Row() {
        Divider()
          .color($r('app.color.divider_color'))
          .width(Constants.SEVENTY_SIX_PERCENT)
      }
      .width(Constants.FULL_PERCENT)
      .justifyContent(FlexAlign.End)
      .padding({
        right: $r('app.integer.comm_padding_margin32')
      })
    }
    .height($r('app.integer.comm_image_size78'))
    .width(Constants.FULL_PERCENT)
    .justifyContent(FlexAlign.Start)
  }
}