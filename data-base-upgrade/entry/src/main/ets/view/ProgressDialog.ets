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

@CustomDialog
export struct ProgressDialog {
  @Link index: number;
  @Link content: string;
  @Link progressValue: number;
  @Link isCanceled: boolean;
  @Link versionNumber: number;
  @Link res: User;
  @Link isSucceed: boolean;
  @Link isShowLoading: boolean;
  @Link flags: number[];
  @Link isUpdate: boolean;
  controller: CustomDialogController;
  private intervalId: number = 0;

  aboutToAppear() {
    this.isShowLoading = true;
    if (!this.flags[this.index]) {
      dbUtils.backup(() => {
        dbUtils.updateTable(this.index, this.content);
      });
    } else {
      dbUtils.backup(() => {
        dbUtils.updateData(this.index, this.content);
      });
    }
    this.intervalId = setInterval(() => {
      if (this.progressValue < CommonConstants.PROGRESS_MAX) {
        this.progressValue += CommonConstants.PROGRESS_STEP;
      } else {
        this.isSucceed = true;
        this.controller.close();
      }
    }, CommonConstants.NUMBER_500)
  }

  async aboutToDisappear() {
    if (this.isCanceled) {
      CommonUtils.showToast($r('app.string.update_failed'));
      dbUtils.rollback();
    } else if (this.isSucceed) {
      CommonUtils.showToast($r('app.string.update_success'));
      this.isUpdate = true;
      this.versionNumber++;
      dbUtils.commit();
      setTimeout(() => {
        dbUtils.queryData(this.flags).then((value: User) => {
          this.flags[this.index]++;
          this.res = value;
        });
      }, CommonConstants.NUMBER_100)
    }
    this.isShowLoading = false;
    this.progressValue = 0;
    clearInterval(this.intervalId);
  }

  build() {
    Column() {
      Column() {
        Row() {
          Text($r('app.string.updating'))
            .fontSize($r('app.float.default_font_14'))
            .fontWeight(CommonConstants.NUMBER_400)
          Text(this.progressValue + '%')
            .fontSize($r('app.float.default_font_14'))
            .fontWeight(CommonConstants.NUMBER_400)
        }
        .margin({ top: $r('app.float.default_29') })
        .width(CommonConstants.PERCENT_NINETY_WIDTH)
        .justifyContent(FlexAlign.SpaceBetween)

        Row() {
          Progress({ value: 0, total: CommonConstants.PROGRESS_MAX, type: ProgressType.Linear })
            .value(this.progressValue)
            .width($r('app.float.default_268'))
            .height($r('app.float.default_24'))
            .margin({ right: $r('app.float.default_12') })
          Image($r('app.media.ic_public_close_filled'))
            .width($r('app.float.default_24'))
            .height($r('app.float.default_24'))
            .onClick(() => {
              this.isCanceled = true;
              clearInterval(this.intervalId);
              this.controller.close();
            })
        }
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width($r('app.float.default_304'))
      .height($r('app.float.default_56'))
    }
    .width($r('app.float.default_336'))
    .height($r('app.float.default_88'))
  }
}