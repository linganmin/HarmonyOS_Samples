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
import { i18n } from '@kit.LocalizationKit';
import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { GoHouse } from './GoHouse';
import { GoCompany } from './GoCompany';
import { goToSpecifyPage } from '../util/CommonFunction';

@Entry
@Component
struct Index {
  @State isFoldAble: boolean = false;
  @State foldStatus: number = 2;
  @State voiceIcon: number = 326;
  @State text: string = '';
  @State isEnglish: boolean = false;
  @StorageLink('newWantFlag') @Watch('newWantChange') isNewWant: boolean = false;
  pageInfos: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    try {
      this.isFoldAble = display.isFoldable();
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (this.isFoldAble) {
        this.foldStatus = foldStatus;
        if (this.foldStatus === 1) {
          this.voiceIcon = 650;
        } else if (this.foldStatus === 2) {
          this.voiceIcon = 286;
        }
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
          if (this.foldStatus === 1) {
            this.voiceIcon = 650;
          } else if (this.foldStatus === 2) {
            this.voiceIcon = 286;
          }
        }
        display.on('change', callback);
      } else {
        let deviceWidth = this.getUIContext().px2vp(display.getDefaultDisplaySync().width);
        if (deviceWidth < 380) {
          this.voiceIcon = 312;
        }
      }

      let systemLanguage = i18n.System.getSystemLanguage();
      if (systemLanguage === 'en-Latn-US') {
        this.isEnglish = true;
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index',
        `isFoldable failed. code=${err.code}, message=${err.message}`);
    }

  }

  // [Start onPageShow]
  newWantChange(): void {
    if (this.isNewWant && AppStorage.has('want')) {
      let want: Want | undefined = AppStorage.get('want');
      if (want?.parameters?.shortCutKey) {
        this.isNewWant = false;
        goToSpecifyPage(this.getUIContext(),want);
      }
    }
  }

  // [End onPageShow]

  showTips() {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: $r('app.string.ui_displayed'),
        duration: 2000
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index',
        `showToast failed. code=${err.code}, message=${err.message}`);
    }
  }

  @Builder
  PagesMap(name: string) {
    if (name === 'GoHouse') {
      GoHouse();
    } else if (name === 'GoCompany') {
      GoCompany();
    }
  }

  @Builder
  myBuilder() {
    Column() {
      Column() {
        Image('')
          .width(90)
          .height(24)
          .draggable(false)
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height(24)

      Scroll() {
        Column() {
          TextInput({ placeholder: $r('app.string.placeholder'), text: this.text })
            .padding({ left: 36 })
            .fontSize(18)
            .height(46)
            .onSubmit(() => {
              this.showTips();
              this.text = '';
            })
            .onChange((value: string) => {
              this.text = value;
            })
          Image($r('app.media.Public_ic_public_input_search'))
            .width(18)
            .height(18)
            .position({
              x: 12,
              y: 15
            })
            .draggable(false)
          Image($r('app.media.mic'))
            .width(18)
            .height(18)
            .position({
              x: this.voiceIcon,
              y: 15
            })
            .draggable(false)
          Row() {
            Column() {
              Image($r('app.media.avatar1'))
                .width(48)
                .draggable(false)
              Text($r('app.string.driving'))
                .fontSize(12)
                .fontColor(Color.Black)
                .opacity(0.6)
                .margin({ top: 6 })
            }
            .width(56)
            .height(64)
            .onClick(() => {
              this.showTips();
            })

            Column({ space: 6 }) {
              Image($r('app.media.avatar2'))
                .width(48)
                .draggable(false)
              Text($r('app.string.bus_and_subway'))
                .fontSize(12)
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(56)
            .height(64)
            .onClick(() => {
              this.showTips();
            })

            Column({ space: 6 }) {
              Image($r('app.media.avatar3'))
                .width(40)
                .draggable(false)
              Text($r('app.string.taxi'))
                .fontSize(12)
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(56)
            .height(64)
            .onClick(() => {
              this.showTips();
            })

            Column({ space: 6 }) {
              Image($r('app.media.avatar4'))
                .width(48)
                .draggable(false)
              Text($r('app.string.real_time_bus'))
                .fontSize(12)
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(56)
            .height(64)
            .onClick(() => {
              this.showTips();
            })

            Column({ space: 6 }) {
              Image($r('app.media.avatar5'))
                .width(40)
                .draggable(false)
              Text($r('app.string.book_a_hotel'))
                .fontSize(12)
                .fontColor(Color.Black)
                .opacity(0.6)
            }
            .width(56)
            .height(64)
            .onClick(() => {
              this.showTips();
            })
          }
          .margin({ top: 24 })
          .width('100%')
          .padding({ left: 16, right: 16 })
          .height(64)
          .justifyContent(FlexAlign.SpaceBetween)

          Column() {
            Row() {
              Row() {
                Image($r('app.media.home'))
                  .width(16)
                  .draggable(false)
                Text($r('app.string.add_home'))
                  .fontSize(15)
                  .margin({ left: 8 })
                  .fontColor($r('app.color.text_fontColor8'))
                  .opacity(0.9)
              }
              .width('50%')
              .onClick(() => {
                this.showTips();
              })

              Row() {
                Image($r('app.media.company'))
                  .width(16)
                  .draggable(false)
                Text($r('app.string.add_company_school'))
                  .fontSize(15)
                  .margin({ left: 8 })
                  .fontColor($r('app.color.text_fontColor8'))
                  .opacity(0.9)
              }
              .width('50%')
              .onClick(() => {
                this.showTips();
              })
            }
            .padding(16)
            .width('100%')
            .height(60)
            .justifyContent(FlexAlign.SpaceBetween)

            Row() {
              Image($r('app.media.company'))
                .width(16)
                .draggable(false)
              Text($r('app.string.add_frequent_address'))
                .fontSize(15)
                .margin({ left: 8 })
                .fontColor($r('app.color.text_fontColor8'))
            }
            .padding({ left: 16 })
            .width(130)
            .onClick(() => {
              this.showTips();
            })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ top: 24, bottom: 16 })
          .width('100%')
          .height(100)
          .borderRadius(16)
          .shadow({
            radius: 20,
            color: $r('app.color.shadow_color')
          })
        }
      }
      .height(265)
      .scrollBar(BarState.Off)

      Row() {
        Column() {
          Image($r('app.media.homePage'))
            .height(28)
            .draggable(false)
          Text($r('app.string.home_page'))
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor('#0A59F7')
        }
        .width(82)
        .height(54)
        .onClick(() => {
          this.showTips();
        })

        Column({ space: 4 }) {
          Image($r('app.media.near'))
            .height(28)
            .draggable(false)
          Text($r('app.string.near'))
            .fontSize(12)
            .fontColor(Color.Black)
            .opacity(0.6)
        }
        .width(82)
        .height(54)
        .onClick(() => {
          this.showTips();
        })

        Column({ space: 4 }) {
          Image($r('app.media.taxi'))
            .height(28)
            .draggable(false)
          Text($r('app.string.taxi'))
            .fontSize(12)
            .fontColor(Color.Black)
            .opacity(0.6)
        }
        .width(82)
        .height(54)
        .onClick(() => {
          this.showTips();
        })

        Column({ space: 4 }) {
          Image($r('app.media.mine'))
            .height(28)
            .draggable(false)
          Text($r('app.string.mine'))
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.Black)
            .opacity(0.6)
        }
        .width(82)
        .height(54)
        .onClick(() => {
          this.showTips();
        })
      }
      .width('100%')
      .height(54)
      .padding({ top: 12 })
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .backgroundColor(Color.White)
    .padding({
      left: 16,
      right: 16,
      bottom: 88
    })
    .width('100%')
    .height(301)
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Image($r('app.media.positioning'))
          .width(32)
          .position({
            x: this.isFoldAble && this.foldStatus === 2 ? 160 : this.isFoldAble && this.foldStatus === 1 ? 360 : 200,
            y: 200
          })
          .draggable(false)
        Image($r('app.media.detection'))
          .width(90)
          .height(90)
          .position({
            x: this.isFoldAble && this.foldStatus === 2 ? 270 : this.isFoldAble && this.foldStatus === 1 ? 624 : 306,
            y: this.isFoldAble ? 288 : 324
          })
          .draggable(false)
          .onClick(() => {
            this.showTips();
          })
        Image($r('app.media.routes3'))
          .width(90)
          .height(90)
          .position({
            x: this.isFoldAble && this.foldStatus === 2 ? 270 : this.isFoldAble && this.foldStatus === 1 ? 624 : 306,
            y: this.isFoldAble ? 348 : 384
          })
          .draggable(false)
          .onClick(() => {
            this.showTips();
          })
          .visibility(this.isEnglish ? Visibility.None : Visibility.Visible)
        this.myBuilder();
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
    }
    .backgroundImage(this.isEnglish ? $r('app.media.backgroundMap_en') : $r('app.media.backgroundMap'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .mode(NavigationMode.Stack)
    .height('100%')
    .width('100%')
    .hideToolBar(true)
    .navDestination(this.PagesMap)
  }
}