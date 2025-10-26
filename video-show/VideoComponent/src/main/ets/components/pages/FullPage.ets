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

import { mediaquery } from '@kit.ArkUI';
import { Callback } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct FullPage {
  @State fullParams: RouterParams | undefined = undefined;
  @State fullSrc: Resource = $rawfile('video1.mp4');
  @State isHidden: boolean = false;
  @State maxValue: number = 0; // Total duration of the bottom time bar.
  @State nowValue: number = 0; // Current seconds of the bottom time bar.
  @State playTime: number = 0; // Playback time transferred from the previous page.
  @State isPhone: boolean = false;
  portraitFunc: Callback<mediaquery.MediaQueryResult> = (mediaQueryResult: mediaquery.MediaQueryResult): void => {
    this.onPortrait(mediaQueryResult);
  };
  listenerIsPhone = this.getUIContext().getMediaQuery().matchMediaSync('(orientation:landscape)');
  fullVideoController: VideoController = new VideoController();

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    this.isPhone = !mediaQueryResult.matches;
  }

  aboutToAppear() {
    this.fullParams = this.getUIContext().getRouter().getParams() as RouterParams;
    this.fullSrc = this.fullParams.videoSrc;
    this.playTime = this.fullParams.videoTime;
    this.listenerIsPhone.on('change', this.portraitFunc);
  }

  changTime(times: number): string {
    if (times <= 0) {
      return '00:00';
    } else {
      let mm = Math.floor(times / 60);
      let ss = Math.floor(times % 60);
      return (mm < 10 ? '0' + mm : mm) + ':' + (ss < 10 ? '0' + ss : ss);
    }
  }

  build() {
    Scroll() {
      Column() {
        Stack() {
          Video({
            src: this.fullSrc,
            controller: this.fullVideoController
          })
            .width('100%')
            .height('100%')
            .autoPlay(true)
            .loop(true)
            .controls(false)
            .objectFit(ImageFit.Contain)
            .id('fullVideo')
            .onPause(() => {
              this.isHidden = true;
            })
            .onFullscreenChange((e) => {
              this.isHidden = false;
            })
            .onStart(() => {
              this.isHidden = false;
            })
            .onPrepared((e) => {
              this.fullVideoController.setCurrentTime(this.playTime);
              this.maxValue = e.duration;
            })
            .onUpdate((e) => {
              this.nowValue = e.time;
            })
            .onClick(() => {
              this.fullVideoController.pause();
            })

          if(this.isHidden){
            Column() {
              Image($r('app.media.play'))
                .id('fullPlayBtn')
                .width(78)
                .height(78)
                .onClick(() => {
                  this.fullVideoController.start();
                  this.isHidden = !this.isHidden;
                })
            }
            .position({
              x: this.isPhone ? '42%' : '47%',
              y: '45%'
            })
          }
        }
        .width('100%')
        .height('100%')

        Column() {
          Image($r('app.media.back'))
            .id('backBtn')
            .width(42)
            .height(42)
            .onClick(() => {
              this.getUIContext().getRouter().back();
            })
        }
        .position({ x: '5%', y: '5%' })

        Column() {
          Image($r('app.media.share'))
            .width(42)
            .height(42)
        }
        .position({
          x: this.isPhone ? '86%' : '95%',
          y: '5%'
        })

        // Bottom Time Bar.
        Row() {
          Text(this.changTime(Number.parseInt(this.nowValue.toFixed(0)))).fontSize(18).fontColor(Color.White)
          Slider({
            value: this.nowValue,
            min: 0,
            max: this.maxValue,
            style: SliderStyle.OutSet
          })
            .width('75%')
            .blockColor(Color.White)
            .trackColor('#cccccc')
            .selectedColor('#E92F4F')
            .showSteps(false)
            .onChange((value: number, mode: SliderChangeMode) => {
              this.nowValue = value;
              this.fullVideoController.setCurrentTime(value);
              hilog.info(0x0000, 'FullPage', 'value:' + value + 'mode:' + mode.toString());
            })
          Text(this.changTime(Number.parseInt(this.maxValue.toFixed(0))))
            .fontSize(18)
            .fontColor(Color.White)
        }
        .padding({ top: 50 })
        .width('100%')
        .position({
          x: this.isPhone ? 0 : '10%',
          y: '88%'
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#000000')
    }
  }
}

interface RouterParams {
  videoSrc: Resource;
  videoTime: number;
}