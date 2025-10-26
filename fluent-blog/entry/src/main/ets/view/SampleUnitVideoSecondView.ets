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

import { CONSTANT } from '../constant/Constant';

// Video height
const VIDEO_HEIGHT = 193;
// Video name
const VIDEO_NAME = 'videoTest.mp4';
// Set time delay
const DELAY = 1000;
// XComponent width
const X_COMPONENT_WIDTH: string = '70%';
// XComponent height
const X_COMPONENT_HEIGHT: string = '50%';
// Animation duration
const DURATION = 29024;

@Component
export default struct SampleUnitVideoSecondView {
  @State currentTime: number = 0;
  @State xComponentWidth: string = X_COMPONENT_WIDTH;
  @State xComponentHeight: string = X_COMPONENT_HEIGHT;
  @State curTime: number = 0;
  controller: VideoController = new VideoController();
  durationTime: number = 0;
  durationStringTime: string = '00:00';
  currentStringTime: string = '00:00';
  flag: boolean = false;
  isLoading: boolean = false;

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Video({
        src: $rawfile(VIDEO_NAME),
        previewUri: $r('app.media.j'),
        controller: this.controller
      })
        .width(CONSTANT.FULL_SIZE)
        .height(VIDEO_HEIGHT)
        .controls(false)
        .autoPlay(false)
        .objectFit(ImageFit.Contain)
        .loop(false)
        .onUpdate((event) => {
          if (event) {
            this.currentTime = event.time;
            this.currentStringTime = this.changeSliderTime(this.currentTime);
          }
        })
        .onPrepared((event) => {
          this.prepared(event?.duration);
        })
        .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
          if (isVisible) {
            setTimeout(() => {
              this.controller.start();
            }, DELAY)
          }
          if (!isVisible) {
            this.controller.stop();
          }
        })
        .onFinish(() => {
            this.controller.start();
        })
      Slider({ value: this.curTime, min: 0, max: 100 })
        .enabled(false)
        .height(4)
        .width(320)
        .trackThickness(3)
        .blockColor(Color.Red)
        .blockSize({ width: 4, height: 4 })
        .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
          if (isVisible) {
            this.getUIContext().animateTo({
              duration: DURATION,
              iterations: -1,
              expectedFrameRateRange: {
                expected: 30,
                min: 0,
                max: 120,
              },
            }, () => {
              if (this.curTime >= 100) {
                this.curTime = 0;
              }
              for (let i = 0; i < 101; i++) {
                this.curTime += 1;
              }
            })
          }
        })
    }
  }

  prepared(duration: number) {
    this.durationTime = duration;
    let second: number = duration % 60;
    let min: number = Number.parseInt((duration / 60).toString());
    let head = min < 10 ? `'0'${min}` : min;
    let end = second < 10 ? `'0'${second}` : second;
    this.durationStringTime = `${head}':'${end}`;
    this.flag = true;
  }

  changeSliderTime(value: number): string {
    let second: number = value % 60;
    let min: number = Number.parseInt((value / 60).toString());
    let head = min < 10 ? `'0'${min}` : min;
    let end = second < 10 ? `'0'${second}` : second;
    let nowTime = `${head}':'${end}`;
    return nowTime;
  }
}