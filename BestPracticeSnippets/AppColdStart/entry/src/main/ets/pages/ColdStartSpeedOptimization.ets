/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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

// [Start cold_start_speed_optimization]
const LARGE_NUMBER: number = 100000000;
const DELAYED_TIME: number = 1000;

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  aboutToAppear(): void {
    console.log('aboutToAppear');
    this.computeTaskAsync();
  }

  // [StartExclude cold_start_speed_optimization]
  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
      }
      .width('100%')
    }
    .height('100%')
  }
  // [EndExclude cold_start_speed_optimization]

  computeTask(): void {
    let count: number = 0;
    while (count < LARGE_NUMBER) {
      count++;
    }
  }

  // Asynchronous processing of operation tasks
  private computeTaskAsync(): void {
    setTimeout(() => { // SetTimeout is used here to realize asynchronous delayed operation.
      this.computeTask();
    }, DELAYED_TIME);
  }
}
// [End cold_start_speed_optimization]