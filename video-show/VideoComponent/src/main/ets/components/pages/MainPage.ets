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
import { BusinessError, Callback } from '@kit.BasicServicesKit';
import { SmallVideo } from './SmallVideo';
import { MyDataSource } from '../model/LiveDataModel';
import { VideoPage } from './VideoPage';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct MainPage {
  private arrScroll: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];
  private arrSwiper: number[] = [0, 1, 2, 3];
  @State isHidden: boolean = false;
  @State @Watch('onScrollUpdated') scrollSum: number = 0;
  @State isState: boolean = true;
  @State isCancel: boolean = true;
  @State activeVideo: number = 0;
  @State openFirst: boolean = false;
  @Provide('playTime') playNum: number = 20;
  @State isPhone: boolean = false;
  portraitFunc: Callback<mediaquery.MediaQueryResult> = (mediaQueryResult: mediaquery.MediaQueryResult): void => {
    this.onPortrait(mediaQueryResult);
  };
  listenerIsPhone = this.getUIContext().getMediaQuery().matchMediaSync('(orientation:landscape)');

  onPortrait(mediaQueryResult: mediaquery.MediaQueryResult) {
    this.isPhone = !mediaQueryResult.matches;
  }

  async aboutToAppear() {
    this.listenerIsPhone.on('change', this.portraitFunc);
  }

  // Monitor the scroll sliding distance.
  onScrollUpdated(): void {
    // Check the X in the upper right corner of the video. If the X is clicked, the small window is not displayed.
    if (this.isCancel) {
      this.isDistance(this.scrollSum);
    }
  }

  isDistance(scrollUpdated: number) {
    if (this.activeVideo === 0) { // Check whether the page is the first page of the swiper.
      // Check whether the main video starts to play.
      // If the main video does not start to play, no small window is displayed.
      if (this.openFirst) {
        // Determine the sliding distance.
        if (scrollUpdated > 500) {
          // Controls that the small window is not refreshed repeatedly.
          if (this.isState) {
            this.isHidden = true;
            this.isState = false;
          }
        } else {
          // If the switch is enabled, the trigger can be triggered again when the switch is within 500.
          this.isHidden = false;
          this.isState = true;
        }
      }
    }
  }

  build() {
    Column() {
      Stack({ alignContent: Alignment.End }) {
        Scroll() {
          Column() {
            Swiper() {
              VideoPage({ isStart: $openFirst })
                .id('VideoPage')
              LazyForEach(new MyDataSource(this.arrSwiper), (item: number) => {
                Text(item.toString())
                  .width('100%')
                  .aspectRatio(1.12)
                  .backgroundColor(0xAFEEEE)
                  .textAlign(TextAlign.Center)
                  .fontSize(20)
              })
            }
            .width('100%')
            .aspectRatio(this.isPhone ? 1.12 : 3.5)
            .backgroundColor('#ffffff')
            .height(250)
            .indicator(false)
            .onChange((index: number) => {
              this.activeVideo = index;
            })
            LazyForEach(new MyDataSource(this.arrScroll), (item: number) => {
              Text(item.toString())
                .width('90%')
                .height(150)
                .backgroundColor(0xFFFFFF)
                .borderRadius(15)
                .fontSize(16)
                .textAlign(TextAlign.Center)
                .margin({
                  top: 10
                })
            }, (item: string) => item)
          }
          .width('100%')
          .backgroundColor('#F1F3F5')
        }
        .scrollBar(BarState.Off)
        .scrollable(ScrollDirection.Vertical)
        .scrollBarColor(Color.Gray)
        .scrollBarWidth(30)
        .onWillScroll((_xOffset: number, yOffset: number) => {
          this.scrollSum += yOffset;
        })

        if (this.isHidden) {
          SmallVideo({ isHidden: $isHidden, isCancel: $isCancel })
        }
      }

      Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Image($r('app.media.broadcast'))
          .objectFit(ImageFit.Contain)
          .width('24')
          .height('24')
          .margin({ top: 10 })
        Text($r("app.string.in_live"))
          .fontSize(10)
          .fontColor('#000000')
          .margin({ top: 5 })
      }
      .width(58)
      .height(58)
      .backgroundColor('#FFFFFF')
      .border({ color: 'rgba(0,0,0,0.2)' })
      .borderRadius(16)
      .borderWidth(1.3)
      .id('directVideo')
      .onClick(() => {
        this.getUIContext().getRouter().pushUrl({ url: 'pages/LivePage' }).catch((err: BusinessError) => {
          hilog.error(0x0000, 'MainPage', `Failed to push url. Cause code: ${err.code}, message: ${err.message}`);
        });
      })
      .position({
        x: '86%',
        y: '20%'
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(0xDCDCDC)
  }
}