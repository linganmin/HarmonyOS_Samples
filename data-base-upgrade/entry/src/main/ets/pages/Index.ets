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

import { CommonConstants } from '../common/constants/CommonConstants';
import CommonUtils from '../common/utils/CommonUtils';
import dbUtils from '../common/utils/DBUtils';
import { User } from '../viewmodel/UserInfo';
import { ProgressDialog } from '../view/ProgressDialog';

@Entry
@Component
struct Index {
  @State index: number = 0;
  @State content: string = '';
  @State res: User | undefined = undefined;
  @State versionInfo: string[] = [];
  @State versionNumber: number = 0;
  @State flags: number[] = [0, 0, 0, 0];
  // Set the initial value of the progress bar to 0.
  @State @Watch('onUpdated') progressValue: number = 0;
  // Check whether to cancel the update.
  @State isCanceled: boolean = false;
  // Check whether the update is successful.
  @State isSucceed: boolean = false;
  // Check whether the loading dynamic effect is displayed.
  @State isShowLoading: boolean = false;
  @State isUpdate: boolean = false;
  versionUpdateInfo: string[] = [];
  subscript: number = 2;
  dialogController: CustomDialogController = new CustomDialogController({
    builder: ProgressDialog({
      progressValue: this.progressValue,
      isCanceled: this.isCanceled,
      isSucceed: this.isSucceed,
      isShowLoading: this.isShowLoading,
      index: this.index,
      content: this.content,
      res: this.res,
      versionNumber: this.versionNumber,
      flags: this.flags,
      isUpdate: this.isUpdate
    }),
  });

  onUpdated() {
    if (this.isCanceled) {
      this.dialogController.close();
    }
    if (this.progressValue == CommonConstants.PROGRESS_MAX) {
      this.isSucceed = true;
    }
  }

  aboutToAppear() {
    dbUtils.createDB();
  }

  build() {
    Column() {
      Column() {
        Text($r('app.string.Sequence_diagram'))
          .width($r('app.float.default_312'))
          .height($r('app.float.default_32'))
          .fontSize($r('app.float.default_font_24'))
          .fontWeight(CommonConstants.NUMBER_500)
          .margin({
            top: $r('app.float.default_12'),
            bottom: $r('app.float.default_12'),
            left: $r('app.float.default_12'),
            right: $r('app.float.default_24')
          })
      }
      .width($r('app.float.default_360'))
      .height($r('app.float.default_56'))

      Row() {
        Text($r('app.string.input_field'))
          .width('190vp')
          .fontWeight(CommonConstants.NUMBER_500)
          .fontSize($r('app.float.default_font_16'))
        Select([
          { value: $r('app.string.username') },
          { value: $r('app.string.account') },
          { value: $r('app.string.nickname') },
          { value: $r('app.string.age') }
        ])
          .backgroundColor($r('app.color.start_window_background'))
          .selected(0)
          .font({ weight: CommonConstants.NUMBER_500, size: $r('app.float.default_font_16') })
          .value($r('app.string.username'))
          .onSelect((index: number) => {
            this.index = index;
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .width($r('app.float.default_312'))
      .height($r('app.float.default_48'))

      Column() {
        Column() {
          Text($r('app.string.field_value'))
            .textAlign(TextAlign.Center)
            .fontSize($r('app.float.default_font_16'))
            .fontWeight(CommonConstants.NUMBER_500)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .width($r('app.float.default_312'))
        .height($r('app.float.default_48'))

        TextInput({ placeholder: CommonConstants.INIT_NAME })
          .enableKeyboardOnFocus(false)
          .backgroundColor($r('app.color.input_background'))
          .borderRadius(0)
          .width($r('app.float.default_312'))
          .height($r('app.float.default_48'))
          .onChange((value: string) => {
            this.content = value;
          })
        Row() {
          Button($r('app.string.version_update'))
            .margin({ right: $r('app.float.default_12') })
            .fontSize($r('app.float.default_font_16'))
            .fontWeight(CommonConstants.NUMBER_500)
            .width($r('app.float.default_150'))
            .height($r('app.float.default_40'))
            .onClick(() => {
              this.isCanceled = false;
              this.dialogController.open();
            })
          Button($r('app.string.version_rollback'))
            .backgroundColor($r('app.color.rollback_background'))
            .opacity(!this.isUpdate ? 0.5 : 1)
            .fontColor($r('app.color.font_color'))
            .fontSize($r('app.float.default_font_16'))
            .fontWeight(CommonConstants.NUMBER_500)
            .width($r('app.float.default_150'))
            .height($r('app.float.default_40'))
            .onClick(async () => {
              if (!this.isUpdate) {
                CommonUtils.showToast($r('app.string.rollback_failed'));
              } else {
                dbUtils.restore(() => {
                  dbUtils.queryData(this.flags).then((value: User) => {
                    this.res = value;
                    CommonUtils.showToast($r('app.string.rollback_success'));
                  })
                });
                this.isUpdate = false;
                this.flags[this.index]--;
              }
            })
        }
        .width($r('app.float.default_312'))
        .height($r('app.float.default_40'))
        .justifyContent(FlexAlign.Start)
        .margin({ top: $r('app.float.default_24') })
      }
      .borderRadius($r('app.float.default_16'))
      .backgroundColor($r('app.color.input_background'))
      .width($r('app.float.default_336'))
      .height($r('app.float.default_176'))

      Column() {
        Column() {
          Text($r('app.string.user_info'))
            .width($r('app.float.default_288'))
            .height($r('app.float.default_56'))
            .fontWeight(CommonConstants.NUMBER_500)
            .fontSize($r('app.float.default_font_20'))
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Start)
        .width($r('app.float.default_312'))
        .height($r('app.float.default_56'))

        Row() {
          if (this.flags[0] > 0) {
            Text($r('app.string.username'))
              .fontSize($r('app.float.default_font_16'))
              .fontWeight(CommonConstants.NUMBER_500)
              .textAlign(TextAlign.Center)
            Text(this.res?.name)
              .textAlign(TextAlign.Center)
              .fontSize($r('app.float.default_font_14'))
              .fontWeight(CommonConstants.NUMBER_400)
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width($r('app.float.default_312'))
        .height(this.flags[0] > 0 ? $r('app.float.default_48') : $r('app.float.default_0'))

        Row() {
          if (this.flags[1] > 0) {
            Text($r('app.string.account'))
              .fontSize($r('app.float.default_font_16'))
              .fontWeight(CommonConstants.NUMBER_500)
              .textAlign(TextAlign.Center)
            Text(this.res?.account)
              .textAlign(TextAlign.Center)
              .fontSize($r('app.float.default_font_14'))
              .fontWeight(CommonConstants.NUMBER_400)
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width($r('app.float.default_312'))
        .height(this.flags[1] > 0 ? $r('app.float.default_48') : $r('app.float.default_0'))

        Row() {
          if (this.flags[2] > 0) {
            Text($r('app.string.nickname'))
              .fontSize($r('app.float.default_font_16'))
              .fontWeight(CommonConstants.NUMBER_500)
              .textAlign(TextAlign.Center)
            Text(this.res?.nickname)
              .textAlign(TextAlign.Center)
              .fontSize($r('app.float.default_font_14'))
              .fontWeight(CommonConstants.NUMBER_400)
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width($r('app.float.default_312'))
        .height(this.flags[2] > 0 ? $r('app.float.default_48') : $r('app.float.default_0'))

        Row() {
          if (this.flags[3] > 0) {
            Text($r('app.string.age'))
              .fontSize($r('app.float.default_font_16'))
              .fontWeight(CommonConstants.NUMBER_500)
              .textAlign(TextAlign.Center)
            Text(this.res?.age)
              .textAlign(TextAlign.Center)
              .fontSize($r('app.float.default_14'))
              .fontWeight(CommonConstants.NUMBER_400)
          }
        }
        .justifyContent(FlexAlign.SpaceBetween)
        .width($r('app.float.default_312'))
        .height(this.flags[3] > 0 ? $r('app.float.default_48') : $r('app.float.default_0'))
      }
      .borderRadius($r('app.float.default_16'))
      .margin({ top: $r('app.float.default_12') })
      .backgroundColor($r('app.color.input_background'))
      .width($r('app.float.default_336'))
      .height($r('app.float.default_256'))
    }
    .width(CommonConstants.PERCENT_WIDTH)
    .height(CommonConstants.PERCENT_WIDTH)
    .backgroundColor($r('app.color.start_window_background'))
  }
}
