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

// [Start enable_nfc]
import { nfcController } from '@kit.ConnectivityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  // [StartExclude enable_nfc]
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    this.canIUseNfc();
  }
  // [EndExclude enable_nfc]

  canIUseNfc(): void {
    // [Start caniuse_nfc_core]
    if (canIUse('SystemCapability.Communication.NFC.Core')) {
      hilog.info(0x0000, 'Index', `该设备支持SystemCapability.Communication.NFC.Core`);
    } else {
      hilog.error(0x0000, 'Index', `该设备不支持SystemCapability.Communication.NFC.Core`);
    }
    // [End caniuse_nfc_core]
    // [EndExclude enable_nfc]
    if (canIUse('SystemCapability.Communication.NFC.Core')){
    try {
      nfcController.enableNfc();
      hilog.info(0x0000, 'Index', `nfcController enableNfc success`);
    } catch (businessError) {
      hilog.error(0x0000, 'Index', `nfcController enableNfc businessError: ${businessError}`);
    }}else {
      hilog.info(0x0000, 'Index', 'NFC not by this device.');
    }
    // [StartExclude enable_nfc]
  }
  // [StartExclude enable_nfc]
  build() {
    RelativeContainer() {
      Text(this.message)
        .id('HelloWorld')
        .fontSize($r('app.float.page_text_font_size'))
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
        .onClick(() => {
          this.message = 'Welcome';
        })
    }
    .height('100%')
    .width('100%')
  }
  // [EndExclude enable_nfc]
}
// [End enable_nfc]