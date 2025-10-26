/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../constants/Constants';
import { GlobalContext } from '../common/GlobalContext';

const TAG = 'AppLinking_Sample';
const DURATION = 3000;
let context = GlobalContext.getContext();

@Entry
@Component
struct Index {
  @State message: string = 'Deferred Link Sample';

  build() {
    Scroll() {
      Column() {
        Row() {
          Text(this.message)
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .margin({left:16, top:82})
        }
        .height('50%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)
        .width('100%')
        Row() {
          this.newButton('Open Detail Page', async () => {
            let link: string = Constants.APP_LINK_PAGE;
            context.openLink(link, { appLinkingOnly: false })
              .then(() => {
                hilog.info(0x0000, TAG, `Succeeded in opening Detail Page.`);
              })
              .catch((error: BusinessError) => {
                try {
                  this.getUIContext().getPromptAction().showToast({
                    message: `openLink failed, errCode:${error.code}`,
                    duration: DURATION
                  });
                } catch (err) {
                  hilog.error(0x0000, TAG, `Failed to showToast, err: ${err.message}`);
                }
                hilog.error(0x0000, TAG,
                  `Failed to open detail Page, code: ${error.code}, message: ${error.message}`);
              });
          })
        }
        .height('50%')
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Bottom)
        .padding(16)
      }
      .height('100%')
      .width('100%')
      .justifyContent(FlexAlign.Start)
    }
  }

  @Builder
  newButton(title: string, action: () => void) {
    Button(title, { type: ButtonType.Normal })
      .fontWeight(FontWeight.Bold)
      .fontSize($r('sys.float.Body_L'))
      .borderRadius(20)
      .onClick(async () => {
        action();
      })
      .height(40)
      .width('100%')
  }
}


