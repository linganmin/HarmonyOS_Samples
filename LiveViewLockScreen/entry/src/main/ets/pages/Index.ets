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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../constant/Constant';
import PreferenceModel from '../model/PreferenceModel';
import { BreakpointType } from '../utils/BreakpointUtil';
import { LiveView } from '../utils/LiveView';
import { TrafficView } from '../view/TrafficView';

const TAG = '[LiveViewLockScreenPage]';

@CustomDialog
struct TipDialog {
  public controller?: CustomDialogController;
  public onConfirm: () => void = () => {
  };

  build() {
    Column() {
      Row() {
        Text($r('app.string.tip'))
          .fontSize(20)
          .fontWeight(FontWeight.Bold)
          .lineHeight(27)
          .fontColor($r('app.color.tip'))
      }
      .height(56)
      .width('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)

      Blank()

      Text($r('app.string.tip_text'))
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .lineHeight(21)
        .fontColor($r('app.color.tip'))
        .margin({ left: 16, right: 16 })

      Blank()

      Row() {
        Text($r('app.string.tip_get'))
          .width('100%')
          .height(40)
          .fontColor($r('app.color.tip_text'))
          .textAlign(TextAlign.Center)
          .onClick(() => {
            hilog.info(0x0000, TAG, 'Button-clicking callback');
            this.onConfirm();
          })
      }
      .height(56)
      .width('100%')
      .margin({ top: 8 })
      .padding({ left: 16, right: 16 })
      .alignItems(VerticalAlign.Top)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .borderRadius(32)
    .backgroundColor($r('app.color.tip_background'))
  }
}

@Entry
struct LiveViewLockScreenPage {
  @StorageLink('lightTime') lightTime: number = 90;
  @StorageLink('horizontalBreakpoint') horizontalBreakpoint: string = Constants.BREAK_POINT_SM;
  @StorageLink('verticalBreakpoint') verticalBreakpoint: string = Constants.BREAK_POINT_SM;
  private updateInterval: number | undefined;
  private customDialogController: CustomDialogController = new CustomDialogController({
    builder: TipDialog({
      onConfirm: () => {
        this.customDialogController?.close();
      }
    }),
    cancel: () => {
    },
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      dismissDialogAction.dismiss()
    },
    alignment: DialogAlignment.Center,
    autoCancel: true,
    cornerRadius: 32,
    width: 338,
    height: 175,
  });

  aboutToAppear(): void {
    LiveView.getInstance(this.getUIContext().getHostContext() as Context).createLiveView();
    this.customDialogController?.open();
    this.updateInterval = setInterval(() => {
      if (this.lightTime <= 0) {
        this.lightTime = 90;
      } else {
        this.lightTime--;
      }
      let context = this.getUIContext().getHostContext();
      if (context) {
        PreferenceModel.putPreference(context, 'lightTime', this.lightTime);
      }
    }, 1000)
  }

  aboutToDisappear(): void {
    if (this.updateInterval !== undefined) {
      clearInterval(this.updateInterval);
      this.updateInterval = undefined;
    }
  }

  build() {
    Stack() {
      Image(new BreakpointType($r('app.media.ic_map'), $r('app.media.ic_map_md'), $r('app.media.ic_map_lg'))
        .getValue(this.horizontalBreakpoint))
        .width('100%')
        .height('100%')

      TrafficView()
    }
    .width('100%')
    .height('100%')
  }
}