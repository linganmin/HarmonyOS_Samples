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

import { display } from '@kit.ArkUI';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AVPlayerItem } from '../view/AVPlayerItem';
import { CONSTANT } from '../constant/Constant';

// XComponent width
const X_COMPONENT_WIDTH: string = '100%';
// XComponent height
const X_COMPONENT_HEIGHT: string = '50%';
// Delay time
const DELAY = 500;
// Animation duration
const DURATION = 29024;
// Surface size
const SURFACE_SIZE = 1500;
const TAG = 'SampleUnitAVPlayView';


@Component
export default struct SampleUnitAVPlayView {
  @Link avPlayer: AVPlayerItem;
  @State xComponentWidth: string = X_COMPONENT_WIDTH;
  @State sliderWidth: string | number = X_COMPONENT_WIDTH;
  @State xComponentHeight: string = X_COMPONENT_HEIGHT;
  @State curTime: number = 0;
  private xComponentController: XComponentController = new XComponentController();
  setTimeInstance: number = 1
  currentSurfaceID: string = ''

  aboutToAppear(): void {
    try {
      if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_EXPANDED) {
        this.sliderWidth = this.getUIContext().px2vp(SURFACE_SIZE);
      }
      display.on('foldStatusChange', () => {
        if (display.getFoldStatus() === display.FoldStatus.FOLD_STATUS_FOLDED) {
          this.sliderWidth = X_COMPONENT_WIDTH;
        } else {
          this.sliderWidth = this.getUIContext().px2vp(SURFACE_SIZE);
        }
      });
    } catch (error) {
      hilog.error(0x0000, TAG, `aboutToAppear catch error, code: ${error.code}, message: ${error.message}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      XComponent({
        id: '',
        type: XComponentType.SURFACE,
        controller: this.xComponentController
      })
        .backgroundImage($r('app.media.video_pic'))
        .backgroundImageSize({ width: CONSTANT.FULL_SIZE, height: CONSTANT.FULL_SIZE })
        .onLoad(() => {
          this.xComponentController.setXComponentSurfaceRect({
            surfaceWidth: SURFACE_SIZE, surfaceHeight: SURFACE_SIZE
          })
          this.avPlayer.surfaceID = this.xComponentController.getXComponentSurfaceId();
        })
        .onVisibleAreaChange([0.0, 1.0], (isVisible: boolean, currentRatio: number) => {
          if (isVisible && currentRatio === 1) {
            if (this.setTimeInstance) {
              clearTimeout(this.setTimeInstance)
            }
            this.setTimeInstance = setTimeout(() => {
              if (this.avPlayer && this.avPlayer.surfaceID !== '') {
                if (this.currentSurfaceID) {
                  if (this.avPlayer.surfaceID !== this.currentSurfaceID) {
                  }
                } else {
                  this.currentSurfaceID = this.avPlayer.surfaceID
                }
              }
            }, DELAY)
          }
          if (!isVisible && currentRatio <= 0.0) {
            this.avPlayer.avPlayer?.stop();
            this.currentSurfaceID = ''
          }
        })
        .height(this.xComponentHeight)
        .width(this.xComponentWidth)
      // [Start onVisibleAreaChange_start]
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
      // [End onVisibleAreaChange_start]
    }
  }
}