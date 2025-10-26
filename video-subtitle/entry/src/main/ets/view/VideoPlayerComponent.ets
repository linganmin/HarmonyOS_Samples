/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
import { Caption, VideoPreparedEvent, VideoUpdateEvent } from '../model/ViewModel';
import { srtToJson, uint8ArrayToStr } from '../utils/CommonUtil';
import { Logger } from '../utils/Logger';

const LOG_TAG = 'VIDEO_PLAYER';

@Component
export struct VideoPlayer {
  private videoSrc: Resource = $rawfile('sample.mp4');
  private controller: VideoController = new VideoController();
  @Link @Watch('togglePlay') isPlaying: boolean;
  @Link @Watch('sliderChange') sliderTime: number;
  @Link currentTime: number;
  @Link duration: number;
  @Link currentCaption: Caption | null;
  @State captionList: Caption[] = [];

  aboutToAppear(): void {
    const resourceManager = this.getUIContext().getHostContext()?.resourceManager;
    resourceManager?.getRawFileContent('captions.srt').then((value: Uint8Array) => {
      let rawFile = uint8ArrayToStr(value);
      this.captionList = srtToJson(rawFile);
    }).catch((error: BusinessError) => {
      Logger.error(LOG_TAG, 'getRawFileContent promise error is ' + error.message);
    });
  }

  togglePlay() {
    if (this.isPlaying) {
      this.controller.start();
    } else {
      this.controller.pause();
    }
  }

  sliderChange() {
    this.controller.setCurrentTime(this.sliderTime);
  }

  build() {
    Column() {
      Video({
        src: this.videoSrc,
        controller: this.controller
      })
        .size({ width: '100%', height: '100%' })
        .autoPlay(false)
        .controls(false)
        .onPrepared((event: VideoPreparedEvent) => {
          this.controller.start()
          this.duration = event.duration;
        })
        .onUpdate((event: VideoUpdateEvent) => {
          this.currentTime = event.time;
          if (event.time > 0 && !this.isPlaying) {
            this.isPlaying = true;
          }
          const caption: Caption[] = this.captionList.filter(caption => caption.startTime === this.currentTime);
          if (caption?.length) {
            this.currentCaption = caption[0];
          } else if (this.currentCaption?.endTime && this.currentCaption.endTime < this.currentTime) {
            this.currentCaption = null;
          }
        })
        .onFinish(() => {
          this.isPlaying = false;
        })
    }
  }
}