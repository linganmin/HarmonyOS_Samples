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
import { userAuth } from '@kit.UserAuthenticationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { promptAction } from '@kit.ArkUI';
import SoterModel from '../model/SoterModel'

const keyType = 0;
const keyAlias = 'keyAlias';
const info = 'info';

function show(message: string) {
  promptAction.openToast({
    message: message,
    duration: 2000
  });
}

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Button('生成AppSecureKey')
          .margin(20)
          .width(200)
          .onClick(async () => {
            try {
              await SoterModel.generateAppSecureKey(keyType);
              show('SOTER generateAppSecureKey success');
            } catch (err) {
              show(err.message);
            }
          })

        Button('生成AuthKey')
          .margin(20)
          .width(200)
          .onClick(async () => {
            try {
              await SoterModel.generateAuthKey(keyType, keyAlias);
              show('SOTER generateAuthKey success');
            } catch (err) {
              show(err.message);
            }
          })

        Button('认证')
          .margin(20)
          .width(200)
          .onClick(async () => {
            let soterChallenge: Uint8Array = SoterModel.getChallenge(keyAlias);
            // 拉起生物特征认证（此步骤为SOTER流程所需步骤，非SOTER能力）
            let authParam: userAuth.AuthParam = {
              challenge: soterChallenge,
              authType: [userAuth.UserAuthType.FINGERPRINT],
              authTrustLevel: userAuth.AuthTrustLevel.ATL4
            };
            hilog.info(0x86E5, 'SOTER', 'getUserAuthInstance, authParam: ' + JSON.stringify(authParam))
            let userAuthInstance = userAuth.getUserAuthInstance(authParam, { title: '请认证' });
            userAuthInstance.on('result', {
              async onResult(result: userAuth.UserAuthResult) {
                hilog.info(0x86E5, 'SOTER', 'auth, result: ' + JSON.stringify(result))
                let authToken = result.token;

                if (result.result != 12500000) {
                  show('SOTER auth failed');
                } else {
                  try {
                    // 生物特征认证成功后，调用SOTER认证
                    SoterModel.auth(keyAlias, authToken, info);
                    show('SOTER auth success');
                  } catch (err) {
                    show('SOTER auth failed');
                  }
                }
              }
            });
            userAuthInstance.start();
          })

        Button('关闭')
          .margin(20)
          .width(200)
          .onClick(async () => {
            try {
              await SoterModel.deleteAuthKey(keyAlias);
              show('SOTER deleteAuthKey success');
            } catch (err) {
              show('SOTER deleteAuthKey failed');
            }
          })
      }.width('100%')
    }.height('100%')
  }
}
