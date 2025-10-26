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

import Constants from '../common/Constants';

@Extend(Text)
function word() {
  .fontSize($r('app.float.font_size_max'))
  .fontColor($r('app.color.word_color'))
  .fontWeight(FontWeight.Bold)
}

@Extend(Text)
function number() {
  .fontSize($r('app.float.font_size'))
  .fontColor(Color.White)
  .fontWeight(FontWeight.Bold)
  .backgroundColor($r('app.color.theme_color'))
  .width($r('app.float.margin_bottom'))
  .height($r('app.float.margin_bottom'))
  .borderRadius($r('app.float.padding'))
  .textAlign(TextAlign.Center)
}

@Extend(Text)
function toast() {
  .fontSize($r('app.float.font_size'))
  .fontColor(Color.Black)
  .height($r('app.float.toast_height'))
  .backgroundColor(Color.White)
  .padding({
    left: $r('app.float.change'),
    right: $r('app.float.change')
  })
  .margin({ top: $r('app.float.toast_margin_m') })
  .borderRadius($r('app.float.toast_border_radius'))
  .shadow({
    radius: $r('app.float.shadow'),
    type: ShadowType.COLOR,
    color: $r('app.color.shadow')
  })
  .animation({
    duration: Constants.TWO_THOUSAND,
    curve: Curve.Ease
  })
}

@Entry
@Component
struct SelectVerificationCode {
  @State text: string = '';
  @State wordNumber: number = 1;
  @State wordArr: string[] = [];
  @State flag: boolean = true;
  @State opacitySuccess: number = 0;
  @State opacityFail: number = 0;
  @State oneX: number = 0;
  @State oneY: number = 0;
  @State twoX: number = 0;
  @State twoY: number = 0;
  @State threeX: number = 0;
  @State threeY: number = 0;
  @State fourX: number = 0;
  @State fourY: number = 0;
  private timer: number = 0;
  private flagWordOne: boolean = true;
  private flagWordTwo: boolean = true;
  private flagWordThree: boolean = true;
  private flagWordFour: boolean = true;
  private flagWordFive: boolean = true;
  private flagWordSix: boolean = true;
  private flagWordSeven: boolean = true;

  clickContent(flag: boolean, word: string, e: ClickEvent): boolean {
    if (flag && this.wordArr.length < 4) {
      this.wordArr.push(word);
      if (this.wordNumber === 1) {
        this.oneX = e.displayX;
        this.oneY = e.displayY;
        this.wordNumber++;
      } else if (this.wordNumber === 2) {
        this.twoX = e.displayX;
        this.twoY = e.displayY;
        this.wordNumber++;
      } else if (this.wordNumber === 3) {
        this.threeX = e.displayX;
        this.threeY = e.displayY;
        this.wordNumber++;
      } else if (this.wordNumber === 4) {
        this.fourX = e.displayX;
        this.fourY = e.displayY;
        this.wordNumber++;
      }
    }
    return false;
  }

  initWord(): void {
    this.wordArr = [];
    this.wordNumber = Constants.LINE_HEIGHT;
    this.oneX = Constants.ZERO;
    this.oneY = Constants.ZERO;
    this.twoX = Constants.ZERO;
    this.twoY = Constants.ZERO;
    this.threeX = Constants.ZERO;
    this.threeY = Constants.ZERO;
    this.fourX = Constants.ZERO;
    this.fourY = Constants.ZERO;
    this.flagWordOne = true;
    this.flagWordTwo = true;
    this.flagWordThree = true;
    this.flagWordFour = true;
    this.flagWordFive = true;
    this.flagWordSix = true;
    this.flagWordSeven = true;
  }

  build() {
    Column() {
      Stack() {
        Text(Constants.LINE_HEIGHT.toString())
          .number()
          .translate({
            x: Constants.ONE_HUNDRED_NINETY_SEVEN + this.oneX,
            y: Constants.ONE_HUNDRED_FOURTEEN + this.oneY
          })
        Text(Constants.TWO.toString())
          .number()
          .translate({
            x: Constants.ONE_HUNDRED_NINETY_SEVEN + this.twoX,
            y: Constants.ONE_HUNDRED_FOURTEEN + this.twoY
          })
        Text(Constants.THREE.toString())
          .number()
          .translate({
            x: Constants.ONE_HUNDRED_NINETY_SEVEN + this.threeX,
            y: Constants.ONE_HUNDRED_FOURTEEN + this.threeY
          })
        Text(Constants.FOUR.toString())
          .number()
          .translate({
            x: Constants.ONE_HUNDRED_NINETY_SEVEN + this.fourX,
            y: Constants.ONE_HUNDRED_FOURTEEN + this.fourY
          })
      }
      .zIndex(Constants.ONE_HUNDRED)

      Row() {
        Text($r('app.string.complete'))
          .fontSize($r('app.float.font_size_l'))
          .fontWeight(FontWeight.Medium)
      }
      .height($r('app.float.list_padding_top'))
      .margin({ bottom: $r('app.float.margin_bottom') })

      Stack() {
        Image($r('app.media.img_1'))
          .width($r('app.float.image_width'))
          .height($r('app.float.image_height'))
        Column() {
          Text($r('app.string.hua'))
            .word()
            .translate({
              x: Constants.NEGATIVE_ONE_HUNDRED_TWENTY,
              y: Constants.THIRTY
            })
            .rotate({ angle: Constants.NEGATIVE_TWENTY })
            .onClick((e) => {
              this.flagWordOne = this.clickContent(this.flagWordOne, Constants.DRAW, e);
            })
          Text($r('app.string.cause'))
            .word()
            .translate({ x: Constants.MINUS_THIRTY })
            .rotate({ angle: Constants.TWENTY })
            .onClick((e) => {
              this.flagWordTwo = this.clickContent(this.flagWordTwo, Constants.THEREFORE, e);
            })
          Text($r('app.string.yan'))
            .word()
            .translate({
              x: Constants.FORTY,
              y: Constants.NEGATIVE_TWENTY_FIVE
            })
            .rotate({ angle: Constants.NEGATIVE_TWENTY })
            .onClick((e) => {
              this.flagWordThree = this.clickContent(this.flagWordThree, Constants.WEIR, e);
            })
          Text($r('app.string.xiang'))
            .word()
            .translate({
              x: Constants.ONE_HUNDRED_FORTY,
              y: Constants.NEGATIVE_ONE_HUNDRED
            })
            .onClick((e) => {
              this.flagWordFour = this.clickContent(this.flagWordFour, Constants.COMMUNES, e);
            })
          Text($r('app.string.china'))
            .word()
            .translate({
              x: Constants.NEGATIVE_ONE_HUNDRED,
              y: Constants.NEGATIVE_THIRTY_FIVE
            })
            .rotate({ angle: Constants.TEN })
            .onClick((e) => {
              this.flagWordFive = this.clickContent(this.flagWordFive, Constants.HUA, e);
            })
          Text($r('app.string.gu'))
            .word()
            .translate({
              x: Constants.NEGATIVE_FIVE,
              y: Constants.NEGATIVE_SEVENTY_FIVE
            })
            .rotate({ angle: Constants.NEGATIVE_SIXTY })
            .onClick((e) => {
              this.flagWordSix = this.clickContent(this.flagWordSix, Constants.ANCIENTS, e);
            })
          Text($r('app.string.hunan'))
            .word()
            .translate({
              x: Constants.NINETY_FIVE,
              y: Constants.NEGATIVE_ONE_HUNDRED_TEN
            })
            .rotate({ angle: Constants.TEN })
            .onClick((e) => {
              this.flagWordSeven = this.clickContent(this.flagWordSeven, Constants.HUNAN, e);
            })
        }
        .width($r('app.float.image_width'))
        .height($r('app.float.image_height'))
      }

      Row() {
        Text($r('app.string.sentence'))
          .fontColor($r('app.color.word_color'))
          .fontSize($r('app.float.font_size'))
          .fontWeight(FontWeight.Medium)
        Text($r('app.string.change_another'))
          .fontSize($r('app.float.font_size_min'))
          .fontWeight(FontWeight.Regular)
          .fontColor($r('app.color.theme_color'))
          .textAlign(TextAlign.Center)
          .margin({ right: $r('app.float.change_margin') })
        Image($r('app.media.img'))
          .width($r('app.float.change'))
          .height($r('app.float.change'))
          .backgroundColor(Color.White)
      }
      .margin({
        top: $r('app.float.word_margin_top'),
        bottom: $r('app.float.word_margin_bottom')
      })
      .width(Constants.EIGHTY_FIVE_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)

      Button($r('app.string.commit'))
        .backgroundColor($r('app.color.theme_color'))
        .fontColor(Color.White)
        .width(Constants.EIGHTY_FIVE_PERCENT)
        .height($r('app.float.bottom_height'))
        .onClick(() => {
          clearTimeout(this.timer);
          if (this.wordArr.join('') === Constants.WORD) {
            this.opacitySuccess = Constants.LINE_HEIGHT;
            this.flag = true;
            this.initWord();
            this.timer = setTimeout(() => {
              this.opacitySuccess = Constants.ZERO;
            }, Constants.THREE_THOUSAND);
          } else {
            this.opacityFail = Constants.LINE_HEIGHT;
            this.flag = false;
            this.initWord();
            this.timer = setTimeout(() => {
              this.opacityFail = Constants.ZERO;
            }, Constants.THREE_THOUSAND);
          }
        })

      if (this.flag) {
        Text($r('app.string.verification_passed'))
          .opacity(this.opacitySuccess)
          .toast()
      } else {
        Text($r('app.string.verification_fail'))
          .opacity(this.opacityFail)
          .toast()
      }
    }
    .width(Constants.ONE_HUNDRED_PERCENT)
    .height(Constants.ONE_HUNDRED_PERCENT)
  }
}

@Builder
export function getVerificationCode(name: string): void {
  if (name === 'VerificationCode') {
    NavDestination() {
      SelectVerificationCode()
    }
  }
}

export const wrappedBuilderVerificationCode: WrappedBuilder<[string, number]> = wrapBuilder(getVerificationCode);