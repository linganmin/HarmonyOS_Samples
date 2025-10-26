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
 * FAQ: Native侧如何访问ArkTS侧系统定义的异步方法
 */
// [Start call_system_async_work_ets]
import testNapi from 'libcallsystemasyncwork.so';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  build() {
    Row() {
      Column() {
        Text('c++ asynchronous call to ts')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            testNapi.getDisplayWidthAsync().then((res: number) =>{
              console.info(`display width = ${res.toString()}`);
              this.getUIContext().getPromptAction().showToast({
                message: "screen width：" + res.toString()
              })
            });
          })
          .margin('30')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .height('100%')
  }
}
// [End call_system_async_work_ets]