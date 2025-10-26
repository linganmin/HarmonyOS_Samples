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

// FoldableScreen.ets
import { display } from '@kit.ArkUI'
import { WindowUtil } from '../utils/WindowUtil';

@Component
export struct FoldableScreen {
  @State isFoldable: Boolean = false;
  @State foldStatus: display.FoldStatus = 1;
  private windowUtil?: WindowUtil;

  aboutToAppear() {
    this.windowUtil = WindowUtil.getInstance();
    this.windowUtil?.setPhoneAutoRotation();

    // 实时监听设备折叠状态
    try {
      display.on('foldStatusChange', (data: display.FoldStatus) => {
        console.info('Monitor the folding status of the device in real-time: ' + JSON.stringify(data));
        if (data === display.FoldStatus.FOLD_STATUS_HALF_FOLDED) {
          this.windowUtil?.setPhoneLandscape();
        } else if (data === display.FoldStatus.FOLD_STATUS_EXPANDED) {
          this.windowUtil?.setPhoneAutoRotation();
        }
      });
    } catch (err) {
      console.error(`Failed to monitor the folding status of the device. Cause code: ${err.code}, message: ${err.message}`);
    }
  }

  build() {
    Column() {
      Text('demo')
    }
    .margin({ top: 100 })
  }
}
