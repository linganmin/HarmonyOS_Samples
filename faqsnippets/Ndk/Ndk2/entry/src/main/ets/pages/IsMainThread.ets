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
 * FAQ: 如何判断当前线程是否为主线程
 */
// DocsCode 1
import testNapi from 'libentry.so';
import { process } from '@kit.ArkTS';

function isMainThread(): boolean {
  return process.pid == process.tid
}
// DocsCode 1
@Entry
@Component
struct Index {
  @State message: string = 'Hello World';

  build() {
    Row() {
      Column() {
        Text(this.message)
          .fontSize(50)
          .fontWeight(FontWeight.Bold)
          .onClick(() => {
            console.info(`Pure C++ isMainThread ${testNapi.MainThread(2, 3)}`);
            console.info(`Pure ArkTs isMainThread ${isMainThread()}`);
          })
      }
      .width('100%')
    }
    .height('100%')
  }
}
