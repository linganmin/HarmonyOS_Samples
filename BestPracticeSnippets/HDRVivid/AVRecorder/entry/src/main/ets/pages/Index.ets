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

import { abilityAccessCtrl, common, Permissions } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { promptAction } from '@kit.ArkUI';
import { rpc } from '@kit.IPCKit';
import Logger from '../utils/Logger';
import { CommonConstants } from '../common/CommonConstants';
import { RouterParams } from '../utils/RouterParams';

const TAG: string = 'Index';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const context = uiContext?.getHostContext() as common.UIAbilityContext;
const router = uiContext?.getRouter();

@Entry
@Component
struct Index {
  @State path: string = '';
  @State text: string = '';
  private controller: VideoController | undefined;
  private result: boolean = false;
  scroller: Scroller = new Scroller();
  atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
  permissions: Array<Permissions> = [
    'ohos.permission.CAMERA',
    'ohos.permission.MICROPHONE',
    'ohos.permission.MEDIA_LOCATION'
  ];

  onPageShow() {
    try {
      this.path = (router?.getParams() as RouterParams).data;
    } catch (e) {
      return;
    }
  }

  async aboutToAppear() {
    this.reqPermissionsFromUser(this.permissions, context);
  }

  reqPermissionsFromUser(permissions: Array<Permissions>, context: common.UIAbilityContext): void {
    this.atManager.requestPermissionsFromUser(context, permissions).then((data) => {
      let grantStatus: Array<number> = data.authResults;
      let length: number = grantStatus.length;
      for (let i = 0; i < length; i++) {
        if (grantStatus[i] === 0) {
          Logger.info(TAG, 'User authorized.');
        } else {
          Logger.info(TAG, 'User denied authorization.');
          return;
        }
      }
    }).catch((err: BusinessError) => {
      Logger.error(`Failed to request permissions from user. Code is ${err.code}, message is ${err.message}`);
    })
  }

  checkAccessToken(permissions: Array<Permissions>) {
    // Determine the authorization status.
    let callerTokenId: number = rpc.IPCSkeleton.getCallingTokenId();
    let atManager: abilityAccessCtrl.AtManager = abilityAccessCtrl.createAtManager();
    try {
      for (let i = 0; i < permissions.length; i++) {
        let data: abilityAccessCtrl.GrantStatus = atManager.verifyAccessTokenSync(callerTokenId, permissions[i]);
        if (data === -1) {
          this.result = false;
        } else {
          this.result = true;
        }
        if (!this.result) {
          promptAction.openToast({
            message: $r('app.string.show_toast_message'),
            duration: CommonConstants.SHOW_TOAST_DURATION,
            bottom: CommonConstants.SHOW_TOAST_BOTTOM
          })
            .then(() => {
              Logger.info(TAG, 'openToast success');
            })
            .catch((err: BusinessError) => {
              Logger.error(TAG, `openToast failed, code=${err.code}, message=${err.message}`)
            })
          break;
        }
      }
    } catch (err) {
      Logger.error(TAG, `checkAccessToken catch err->${JSON.stringify(err)}`);
    }
  }

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Column() {
        if (this.path) {
          Video({
            src: 'file://' + this.path,
            controller: this.controller
          })
            .height($r('app.float.video_height'))
            .margin({ bottom: $r('app.float.video_margin_bottom') })
        }
        Button($r('app.string.button_text'))
          .width(CommonConstants.NINETY_PERCENT)
          .height($r('app.float.bottom_height'))
          .backgroundColor($r('app.color.bottom_background'))
          .fontSize($r('app.float.bottom_font_size'))
          .fontColor(Color.White)
          .margin({ bottom: $r('app.float.bottom_margin_bottom') })
          .onClick(async () => {
            this.checkAccessToken(this.permissions);
            if (this.result) {
              router?.pushUrl({ url: 'pages/Record' })
                .then(() => {
                  Logger.info(TAG, 'pushUrl success');
                })
                .catch((err: BusinessError) => {
                  Logger.error(TAG, `pushUrl failed, code=${err.code}, message=${err.message}`)
                })
            }
          })
      }
      .width(CommonConstants.FULL_PERCENT)
    }
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
    .backgroundColor(Color.White)
  }
}