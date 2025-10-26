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
/**
 * FAQ: 如何在Native侧调用ArkTS侧异步方法，并获取异步计算结果到Native侧
 */

import { hilog } from '@kit.PerformanceAnalysisKit';

// [Start native_call_ark_ts_async_ets]
// ...
import testNapi from 'libentry.so';

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Text('testPromise')
          // ...
          .onClick(() => {
            hilog.info(0x0000, 'testTag-ArkTS', 'Before calling the native interface.');
            // Call the Native interface and return the call information
            testNapi.testPromise(() => {
              // Callback is used to create ArkTS side Promise objects
              return new Promise((resolve: Function, reject: Function) => {
                // Simulate ArkTS side asynchronous method through setTimeout interface
                // Scenario: After 2 seconds, trigger the setTimeout timer callback to generate a random number randomNumber. By judging the size of the random number, it is used to trigger different states of the promise object, and then perform different callback processing
                setTimeout(()=>{
                  const randomNumber: number = 100 * Math.random();
                  if (randomNumber > 50) {
                    // If randomNumber is greater than 50, call the resolve method to transition the state of the Promise object to the fulfilled state, and pass the random number to the Native side as a callback parameter for the then method
                    resolve(randomNumber);
                  } else {
                    // If randomNumber is less than/equal to 50, call the reject method to transfer the state of the Promise object to the rejected state, and pass the exception information to the Native side as the callback parameter of the catch method
                    reject('The random number is less than 50, so the promise object is rejected.')
                  }
                }, 2000);
              })
            }
            )
            hilog.info(0x0000, 'testTag-ArkTS', 'After the native interface is called.');
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
// [End native_call_ark_ts_async_ets]