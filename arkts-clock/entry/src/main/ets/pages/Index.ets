/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { hilog } from '@kit.PerformanceAnalysisKit';
import Logger from '../utils/Logger';
import DrawClock from '../utils/DrawClock';
import CommonConstants from '../common/CommonConstants';

const HEIGHT_ADD: number = CommonConstants.HEIGHT_ADD; // The time needs to be drawn below the dial. The canvas height is the width plus 150
const TAG: string = 'Index';

@Entry
@Component
struct Clock {
  @State canvasWidth: number = CommonConstants.DEFAULT_WATCH_SIZE; // 300 is the size of the dial
  private settings: RenderingContextSettings = new RenderingContextSettings(true);
  private context: CanvasRenderingContext2D = new CanvasRenderingContext2D(this.settings);
  private radius: number = CommonConstants.DEFAULT_WATCH_RADIUS; // Default dial radius
  private intervalId: number = 0;
  private drawClock: DrawClock = new DrawClock();
  updateTime = () => {
    this.context.clearRect(0, 0, this.canvasWidth, this.canvasWidth + HEIGHT_ADD);
    let nowTime = new Date();
    let hour = nowTime.getHours();
    let minute = nowTime.getMinutes();
    let second = nowTime.getSeconds();
    let time = `${this.fillTime(hour)}:${this.fillTime(minute)}:${this.fillTime(second)}`;
    this.drawClock.drawClock(this.context, this.radius, this.canvasWidth, hour, minute, second, time)
    this.context.translate(-this.radius, -this.radius);
  }

  fillTime(time: number) {
    return time < CommonConstants.NUMBER_TEN ? `0${time}` : `${time}`;
  }

  onPageShow(): void {
    this.updateTime();
    this.intervalId = setInterval(this.updateTime, CommonConstants.INTERVAL_TIME)
  }

  onPageHide() {
    clearInterval(this.intervalId);
  }

  aboutToAppear() {
    this.getSize();
  }

  // Get the width and height of the device to calculate the dial size
  async getSize() {
    try {
      let mDisplay = display.getDefaultDisplaySync();
      Logger.info(TAG, `getDefaultDisplay mDisplay = ${JSON.stringify(mDisplay)}`);
      this.canvasWidth = this.getUIContext().px2vp(mDisplay.width > mDisplay.height ? mDisplay.height * CommonConstants.CONVERSION_RATE :
        mDisplay.width * CommonConstants.CONVERSION_RATE);
      this.radius = this.canvasWidth / CommonConstants.NUMBER_TWO;
    } catch (error) {
      hilog.error(0x0000, TAG, `getSize catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Center }) {
      Canvas(this.context)
        .padding({ top: $r('app.float.canvas_padding_top') })
        .width(this.canvasWidth)
        .height(this.canvasWidth + HEIGHT_ADD)
        .onReady(() => {
          this.updateTime();
          this.intervalId = setInterval(this.updateTime, CommonConstants.INTERVAL_TIME);
        })
    }
    .width(CommonConstants.FULL_PERCENTAGE)
    .height(CommonConstants.FULL_PERCENTAGE)
  }
}