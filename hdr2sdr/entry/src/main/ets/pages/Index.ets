/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

AppStorage.setOrCreate('cameraData', null);
AppStorage.setOrCreate('path', '');

@Entry
@Component
struct Index {
  @Provide navPathStack: NavPathStack = new NavPathStack();
  @State isShow: boolean = false;
  @State selectedMethod: number = 0; //0 avRecord 1 AVCodec

  @Builder
  encapsulationMethod() {
    Column() {
      Row() {
        Text($r('app.string.recorder_video_encoding_encapsulation'))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .padding(10)
          .fontColor(Color.Black)
        Blank()
        Image(this.selectedMethod == 0 ? $r('app.media.ic_radio_selected') :
          $r('app.media.ic_radio'))
          .width(25)
          .height(25)
          .objectFit(ImageFit.Contain)
      }
      .width('95%')
      .margin(5)
      .borderRadius(20)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.selectedMethod = 0;
        this.navPathStack.pushPathByName('Recording', this.selectedMethod);
        this.isShow = false;
      })

      Row() {
        Text($r('app.string.AVCodec_encoding_encapsulation'))
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .padding(10)
          .fontColor(Color.Black)
        Blank()
        Image(this.selectedMethod == 1 ? $r('app.media.ic_radio_selected') :
          $r('app.media.ic_radio'))
          .width(25)
          .height(25)
          .objectFit(ImageFit.Contain)
      }
      .width('95%')
      .margin(5)
      .borderRadius(20)
      .justifyContent(FlexAlign.SpaceBetween)
      .onClick(() => {
        this.selectedMethod = 1;
        this.navPathStack.pushPathByName('Recording', this.selectedMethod);
        this.isShow = false;
      })
    }
  }

  build() {
    Navigation(this.navPathStack) {
      Column({ space: 16 }) {
        Button($r('app.string.HDR_video_recording'))
          .width('100%')
          .height('40vp')
          .bindSheet($$this.isShow, this.encapsulationMethod(), {
            backgroundColor: Color.White,
            blurStyle: BlurStyle.NONE,
            showClose: true,
            height: '180vp',
            title: { title: $r('app.string.video_encapsulation_list') }
          })
          .onClick(() => {
            this.isShow = true;
          })
        Button($r('app.string.HDR_video_transcode'))
          .width('100%')
          .height('40vp')
          .onClick(() => {
            this.navPathStack.pushPathByName('Transcode', null);
          })
      }
      .height('100%')
      .width('100%')
      .padding(16)
      .margin({ bottom: '40vp' })
      .justifyContent(FlexAlign.End)
    }
    .hideToolBar(true)
  }
}