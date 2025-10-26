/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import CommonConstants from '../common/CommonConstants';
import PreferencesUtils from '../utils/PreferencesUtils';
import TitleBar from '../view/TitleBar';

@Entry
@Component
struct Index {
  private defaultPassword: string = '';
  private patternLockController: PatternLockController = new PatternLockController();
  @State message: Resource = $r('app.string.message_input');
  @State isReset: boolean = false;
  @State password: Array<number> = [];
  @State isHasPass: boolean = true;
  @State isShowSetting: boolean = false;

  async aboutToAppear() {
    this.password = [];
    this.defaultPassword = await PreferencesUtils.getPassword(this.getUIContext().getHostContext()!) as string;
    if (this.defaultPassword === 'null') {
      this.isHasPass = false;
    } else {
      this.isHasPass = true;
    }
  }

  async setPassword() {
    this.defaultPassword = this.password.toString();
    await PreferencesUtils.setPassword(this.defaultPassword, this.getUIContext().getHostContext()!);
    this.message = $r('app.string.message_set_success');
    this.isShowSetting = false;
    this.isHasPass = true;
    this.password = [];
    this.patternLockController.reset();
    this.isReset = false;
  }

  build() {
    Column() {
      TitleBar()
      Column() {
        if (this.isHasPass && !this.isReset) {
          Text($r('app.string.reset_password'))
            .fontSize($r('app.float.reset_font_size'))
            .fontWeight(FontWeight.Bold)
            .padding($r('app.float.text_padding'))
            .width(CommonConstants.FULL_PERCENT)
            .fontColor(Color.Blue)
            .onClick(() => {
              this.isReset = true;
              this.message = $r('app.string.message_input_old');
              this.password = [];
              this.patternLockController.reset();
            })
        }
        Text(this.message)
          .textAlign(TextAlign.Center)
          .fontSize($r('app.float.input_font_size'))
          .width(CommonConstants.NINETY_PERCENT)
          .padding($r('app.float.input_font_padding'))
        PatternLock(this.patternLockController)
          .sideLength($r('app.float.patternLock_side_length'))
          .circleRadius($r('app.float.patternLock_circle_radius'))
          .pathStrokeWidth(CommonConstants.PATH_STROKE_WIDTH)
          .autoReset(true)
          .margin({ top: $r('app.float.patternLock_margin_top'), bottom: $r('app.float.patternLock_margin_bottom') })
          .onPatternComplete((input: Array<number>) => {
            if (input === null || input === undefined || input.length < CommonConstants.INPUT_LENGTH) {
              this.message = $r('app.string.message_password_length_insufficient');
              return;
            }
            if (this.isHasPass) {
              if (this.defaultPassword === input.toString()) {
                if (this.isReset) {
                  this.message = $r('app.string.message_input_new');
                  this.defaultPassword = 'null';
                  this.patternLockController.reset();
                  this.password = [];
                  this.isHasPass = false;
                  return;
                }
                this.getUIContext().getRouter().replaceUrl({
                  url: 'pages/Home'
                });
              } else {
                this.message = $r('app.string.message_incorrect');
                this.password = [];
                return;
              }
            }
            if (this.password.length > 0) {
              if (this.password.toString() === input.toString()) {
                ;
                this.password = input;
                this.message = $r('app.string.message_correct');
                this.isShowSetting = true;
              } else {
                this.message = $r('app.string.message_not_match');
                this.patternLockController.reset();
              }
            } else {
              this.password = input;
              this.message = $r('app.string.message_input_again');
              this.patternLockController.reset();
            }
          })
        if (this.isShowSetting) {
          Button($r('app.string.message_set_password'))
            .key('setPassword')
            .margin($r('app.float.button_margin'))
            .width(CommonConstants.SIXTY_PERCENT)
            .onClick(() => {
              this.setPassword();
            })
        }
      }
      .layoutWeight(1)
      .justifyContent(FlexAlign.End)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundImage($r('app.media.bg'))
    .backgroundImageSize(ImageSize.Cover)
    .opacity($r('app.float.opacity'))
  }
}