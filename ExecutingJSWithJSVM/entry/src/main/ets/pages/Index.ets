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

import testNapi from 'libentry.so';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State result: string = '';
  private callback1 = (a: string, b: string): string => {
    this.result += `callback1 function receive first param is ${a}\n`;
    this.result += `callback1 function receive second param is ${b}\n`;
    return 'callback1 pass';
  }
  private callback2 = (a: string, b: string): string => {
    this.result += `callback2 function receive first param is ${a}\n`;
    this.result += `callback2 function receive second param is ${b}\n`;
    return 'callback2 pass';
  }
  private clickCallback = () => {
    const jsCodeStr1 = `
      const a = 'hello World';
      consoleInfo(a);
      const mPromise = createPromise();
      mPromise.then((result) => {
        assertEqual(result, 0);
        onJSResultCallback(result, 'abc', 'v');
      });
      a;
      };`;

    let jsCodeStr2 = `{
      const a = 'second hello';
      consoleInfo(a);
      createPromise().then((result) => {
        assertEqual(result, 1);
        consoleInfo(onJSResultCallback(result, '888','999'));
      });
      a;
      };`;

    // Create the first runtime environment and bind the TS callback.
    const coreId1 = testNapi.createJsCore(this.callback1);
    this.result = `Create first runtime, coreId =${coreId1}. \n`;
    hilog.info(0x0000, 'Sample', 'TEST coreId: ' + coreId1);
    // Execute JS code in the first runtime environment.
    hilog.info(0x0000, 'Sample', 'TEST evaluateJS :   ' + testNapi.evaluateJS(coreId1, jsCodeStr1));

    // Create the second runtime environment and bind the TS callback.
    const coreId2 = testNapi.createJsCore(this.callback2);
    this.result += `Create second runtime, coreId = ${coreId2}. \n`;
    hilog.info(0x0000, 'Sample', 'TEST coreId: ' + coreId2);
    // Execute JS code in the second runtime environment.
    hilog.info(0x0000, 'Sample', 'TEST evaluateJS :   ' + testNapi.evaluateJS(coreId2, jsCodeStr2));

    // Release the runtime environment.
    testNapi.releaseJsCore(coreId2);
    this.result += `release runtime ${coreId1}.\n`;
    testNapi.releaseJsCore(coreId1);
    this.result += `release runtime ${coreId2}.\n`;
  }

  build() {
    Column() {
      Text($r('app.string.application_title'))
        .fontColor('#E6000000')
        .fontSize(30)
        .fontWeight(700)
        .lineHeight(40)
        .margin({ top: 64, bottom: 32 })
      TextArea({ text: this.result })
        .height(250)
        .textAlign(TextAlign.Start)
        .fontColor('#E6000000')
        .fontSize(16)
        .fontWeight(400)
        .lineHeight(21)
        .focusable(false)
      Blank()
      Button($r('app.string.click_execute'))
        .width('100%')
        .fontSize(16)
        .fontWeight(500)
        .height(40)
        .backgroundColor('#0A59F7')
        .onClick(this.clickCallback)
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .height('100%')
    .justifyContent(FlexAlign.Start)
    .backgroundColor('#F1F3F5')
    .expandSafeArea([SafeAreaType.SYSTEM])
  }
}
