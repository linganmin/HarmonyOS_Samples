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

import { router } from '@kit.ArkUI';
import { CONSTANT } from '../constant/Constant';

// Video height
const VIDEO_HEIGHT = 193;
// Video name
const VIDEO_NAME = 'videoTest.mp4';
// Set time delay
const DELAY = 1000;
// Router url
const ROUTER_URL = 'pages/NewPlayPage';

@Component
export default struct SampleUnitVideoView {
  @State currentTime: number = 0;
  controller: VideoController = new VideoController();
  durationTime: number = 0;
  durationStringTime: string = '00:00';
  currentStringTime: string = '00:00';
  flag: boolean = false;
  isLoading: boolean = false;

  build() {
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
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: ROUTER_URL });
      })
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