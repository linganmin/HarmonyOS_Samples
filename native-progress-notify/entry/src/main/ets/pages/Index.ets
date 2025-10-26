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
import testNapi from 'libentry.so';
import CommonConstants from '../constants/CommonContants';

@Entry
@Component
struct Index {
  @State progress: number = 0;
  @State buttonEnabled: boolean = true;
  @State buttonText: string = CommonConstants.START_DOWNLOAD;

  build() {
    Column(){
      Column(){
        Stack() {
          // Detailed information is displayed using the Progress component.
          Progress({ value: this.progress, total: CommonConstants.PROGRESS_LENGTH, type: ProgressType.Ring })
            .width(CommonConstants.PROGRESS_SIZE)
            .height(CommonConstants.PROGRESS_SIZE)
            .animation({ duration: CommonConstants.PROGRESS_ANIMATION_DURATION, curve: Curve.Ease })
            .style({ strokeWidth: $r('app.integer.stroke_width') })
          Column() {
            Row() {
              Text(`${this.progress}`)
                .fontSize($r('app.integer.progress_font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT)
              Text(`%`)
                .fontSize($r('app.integer.font_size'))
                .fontWeight(CommonConstants.FONT_WEIGHT)
                .height($r('app.integer.font_height'))
            }
            .alignItems(VerticalAlign.Bottom)
            Text($r('app.string.Download_progress'))
              .fontSize($r('app.integer.font_size'))
              .fontWeight(CommonConstants.FONT_WEIGHT)
          }
        }
      }
      .width(CommonConstants.FULL_PARENT)
      .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
      .justifyContent(FlexAlign.Center)
      Column(){
        Button(this.buttonText)
          .width(CommonConstants.NINETY_PARENT)
          .onClick(() => {
            /*
             * Call the native download method and pass in the callback function. In the callback function, receive the
             * progress information passed from the native side.
             */
            testNapi.startDownload((data: number) => {
              if (data === CommonConstants.PROGRESS_START || data === CommonConstants.PROGRESS_LENGTH) {
                this.buttonEnabled = true;
                this.buttonText = CommonConstants.START_DOWNLOAD;
              } else {
                if (this.buttonEnabled) {
                  this.buttonEnabled = false;
                }
                if (this.buttonText === CommonConstants.START_DOWNLOAD) {
                  this.buttonText = CommonConstants.DOWNING;
                }
              }
              this.progress = data;
            })
          })
          .enabled(this.buttonEnabled)
      }
      .width(CommonConstants.FULL_PARENT)
      .margin({bottom : $r('app.integer.margin_bottom')})
    }
    .width(CommonConstants.FULL_PARENT)
    .height(CommonConstants.FULL_PARENT)
  }
}
