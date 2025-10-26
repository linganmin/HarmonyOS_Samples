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
import { goToSpecifyPage } from '../util/CommonFunction';

@Entry
@Component
export struct GoHouse {
  @State isFoldAble: boolean = false;
  @State foldStatus: number = 2;
  @State routes: number[] = [1, 2, 3, 4, 5];
  @State currentIndex: number = 0;
  @State isEnglish: boolean = false;
  @StorageLink('newWantFlag') @Watch('newWantChange') isNewWant: boolean = false;
  private tabList: ResourceStr[] =
    [$r('app.string.driving'), $r('app.string.taxi'), $r('app.string.bus_and_subway'), $r('app.string.ride'),
      $r('app.string.walking'), $r('app.string.substitute_driver'), $r('app.string.train'), $r('app.string.coach')];
  private tabsController: TabsController = new TabsController();
  controller: TextInputController = new TextInputController();
  controller1: TextInputController = new TextInputController();

  aboutToAppear(): void {
    try {
      this.isFoldAble = display.isFoldable();
      let foldStatus: display.FoldStatus = display.getFoldStatus();
      if (this.isFoldAble) {
        this.foldStatus = foldStatus;
        let callback: Callback<number> = () => {
          let data: display.FoldStatus = display.getFoldStatus();
          this.foldStatus = data;
        }
        display.on('change', callback);
      }
      let systemLanguage = i18n.System.getSystemLanguage();
      if (systemLanguage === 'en-Latn-US') {
        this.isEnglish = true;
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'GoHouse',
        `isFoldable failed. code=${err.code}, message=${err.message}`);
    }
  }

  // [Start onPageShow]
  newWantChange(): void {
    if (this.isNewWant && AppStorage.has('want')) {
      let want: Want| undefined = AppStorage.get('want');
      if(want?.parameters?.shortCutKey){
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
      hilog.error(0x0000, 'GoHouse',
        `showToast failed. code=${err.code}, message=${err.message}`);
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

      Row() {
        Row() {
          Image($r('app.media.directions'))
            .height(46)
            .width(8)
            .margin({ left: 16 })
            .draggable(false)

          Column() {
            TextInput({ text: $r('app.string.my_position'), controller: this.controller })
              .backgroundColor($r('app.color.textInput_background'))
              .fontSize(17)
              .height(40)
              .fontWeight(FontWeight.Medium)
              .enableKeyboardOnFocus(false)
              .onClick(() => {
                this.controller.stopEditing();
              })
            Divider()
              .strokeWidth(1)
              .lineCap(LineCapStyle.Round)
              .margin({ left: 15 })

            TextInput({ text: $r('app.string.my_home'), controller: this.controller1 })
              .backgroundColor($r('app.color.textInput_background'))
              .fontSize(17)
              .height(40)
              .fontWeight(FontWeight.Medium)
              .enableKeyboardOnFocus(false)
              .onClick(() => {
                this.controller1.stopEditing();
              })
          }
          .width(this.isFoldAble && this.foldStatus === 2 ? '56%' :
            this.isFoldAble && this.foldStatus === 1 ? '78%' : '60%')

          Image($r('app.media.plus'))
            .width(17)
            .margin({ left: 30, right: 12 })
            .onClick(() => {
              this.showTips();
            })
            .draggable(false)
          Image($r('app.media.swap'))
            .width(17)
            .margin({ right: 12 })
            .onClick(() => {
              this.showTips();
            })
            .draggable(false)
          Image($r('app.media.mic'))
            .width(17)
            .onClick(() => {
              this.showTips();
            })
            .draggable(false)
        }
        .width('100%')
        .height(91)
        .backgroundColor($r('app.color.textInput_background'))
        .borderRadius(20)
        .layoutWeight(1)
      }
      .alignItems(VerticalAlign.Top)
      .width('100%')
      .height(91)

      Row() {
        this.TabList();
      }
      .height(112)
      .margin({ top: 4 })

      Row() {
        Row() {
          Column() {
            Image($r('app.media.public_right'))
              .draggable(false)
              .height(20)
            Text($r('app.string.collection'))
              .fontSize(12)
              .fontColor(Color.Black)
              .opacity(0.6)
          }
          .onClick(() => {
            this.showTips();
          })

          Column() {
            Image($r('app.media.share'))
              .draggable(false)
              .height(20)
            Text($r('app.string.share'))
              .fontSize(12)
              .fontColor(Color.Black)
              .opacity(0.6)
          }
          .onClick(() => {
            this.showTips();
          })
        }
        .width(120)
        .justifyContent(FlexAlign.SpaceAround)

        Button() {
          Row() {
            Image($r('app.media.path_2'))
              .draggable(false)
              .width(25)
            Text($r('app.string.start_navigating'))
              .fontSize(17)
              .fontColor($r('app.color.button_fontColor'))
              .fontWeight(FontWeight.Medium)
              .margin({ left: 8 })
          }
        }
        .width(190)
        .height(42)
        .linearGradient({
          direction: GradientDirection.Right,
          repeating: false,
          colors: [[$r('app.color.linearGradient_color1'), 0], [$r('app.color.linearGradient_color2'), 1]]
        })
        .onClick(() => {
          this.showTips();
        })

      }
      .height(40)
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Bottom)
      .width('100%')
      .backgroundColor(Color.White)
      .margin({ top: 24 })
    }
    .backgroundColor(Color.White)
    .padding({ left: 16, right: 16 })
    .height(301)
    .width('100%')
    .borderRadius({ topLeft: 32, topRight: 32 })
  }

  @Builder
  PlanList() {
    Row() {
      Column() {
        Text($r('app.string.good_road'))
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_fontColor'))
          .opacity(0.9)
          .margin({ bottom: 2 })
        Text($r('app.string.10_minutes'))
          .fontSize(this.isEnglish ? 18 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor($r('app.color.text_fontColor'))
          .opacity(0.9)
          .margin({ bottom: 2 })
        Text($r('app.string.23_km'))
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_fontColor2'))
          .opacity(0.6)
      }
      .padding({ left: 10, top: 6 })
      .width('30%')
      .height(64)
      .alignItems(HorizontalAlign.Start)
      .borderRadius(12)
      .shadow({
        radius: 10,
        color: $r('app.color.shadow_color')
      })
      .onClick(() => {
        this.showTips();
      })

      Column() {
        Text($r('app.string.option_2'))
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .opacity(0.9)
          .margin({ bottom: 2 })
        Text($r('app.string.12_minutes'))
          .fontSize(this.isEnglish ? 18 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .opacity(0.9)
          .margin({ bottom: 2 })
        Text($r('app.string.26_km'))
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .opacity(0.6)
      }
      .padding({ left: 10, top: 6 })
      .width('30%')
      .height(64)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.showTips();
      })

      Column() {
        Text($r('app.string.short_distance'))
          .fontSize(13)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .opacity(0.9)
          .margin({ bottom: 2 })
        Text($r('app.string.8_minutes'))
          .fontSize(this.isEnglish ? 18 : 20)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .opacity(0.9)
          .margin({ bottom: 2 })
        Text($r('app.string.21_km'))
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(Color.Black)
          .opacity(0.6)
      }
      .padding({ left: 8, top: 6 })
      .width('30%')
      .height(64)
      .alignItems(HorizontalAlign.Start)
      .onClick(() => {
        this.showTips();
      })
    }
    .clip(false)
    .width('100%')
    .padding({ left: 2 })
    .justifyContent(FlexAlign.SpaceBetween)
    .height(74)
    .borderRadius(12)
  }

  @Builder
  TabBuilder(type: ResourceStr, targetIndex: number) {
    Row() {
      Image($r('app.media.path_2'))
        .height(16)
        .width(20)
        .margin({ right: 4 })
        .draggable(false)
        .visibility(this.currentIndex === 0 ? Visibility.Visible : Visibility.None)
      Text(type)
        .fontSize(14)
        .fontColor((this.currentIndex === targetIndex) ? $r('app.color.button_fontColor') :
        $r('app.color.text_fontColor7'))
    }
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(this.currentIndex)
    })
    .justifyContent(FlexAlign.Center)
    .backgroundColor((this.currentIndex === targetIndex) ? $r('app.color.backgroundColor') :
    $r('app.color.start_window_background'))
    .borderRadius(14)
    .height(28)
    .width(this.isFoldAble && this.foldStatus === 1 ? 100 : 80)
  }

  @Builder
  TabList() {
    Tabs({ barPosition: BarPosition.Start, controller: this.tabsController }) {
      ForEach(this.tabList, (_: ResourceStr, index: number) => {
        TabContent() {
          if (index === 0) {
            this.PlanList();
          }
        }
        .tabBar(this.TabBuilder(this.tabList[index], index))
      }, (item: ResourceStr) => item.toString())
    }
    .barHeight(45)
    .width('100%')
    .scrollable(true)
    .barMode(BarMode.Scrollable)
  }

  build() {
    NavDestination() {
      Column() {
        Image($r('app.media.routes'))
          .width(140)
          .height(350)
          .position({
            x: this.isFoldAble && this.foldStatus === 2 ? 100 : this.isFoldAble && this.foldStatus === 1 ? 300 : 120,
            y: 30
          })
          .draggable(false)
          .onClick(() => {
            this.showTips();
          })
        Image($r('app.media.detection'))
          .width(90)
          .height(90)
          .position({
            x: this.isFoldAble && this.foldStatus === 2 ? 270 : this.isFoldAble && this.foldStatus === 1 ? 624 : 306,
            y: this.isFoldAble ? 296 : 328
          })
          .onClick(() => {
            this.showTips();
          })
          .draggable(false)
        this.myBuilder();
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .height('100%')
    }
    .backgroundImage(this.isEnglish ? $r('app.media.backgroundMap_en') : $r('app.media.backgroundMap'))
    .backgroundImageSize({ width: '100%', height: '100%' })
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
    .height('100%')
    .width('100%')
  }
}