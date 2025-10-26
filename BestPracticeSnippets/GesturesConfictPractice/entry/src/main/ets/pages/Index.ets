/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { Router } from '@ohos.arkui.UIContext';

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  private router: Router = this.getUIContext().getRouter();

  jumperPage(url: string) {
    this.router.pushUrl({ url: `pages/${url}` }).catch((error: BusinessError) => {
      console.error(`reset err, code: ${error.code}, mesage: ${error.message}`);
    });
  }

  build() {
    Column({ space: 12 }) {
      Button('GesturesConflictScene1')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene1');
        })

      Button('GesturesConflictScene2')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene2');
        })

      Button('GesturesConflictScene2A')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene2A');
        })

      Button('GesturesConflictScene3')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene3');
        })

      Button('GesturesConflictScene3A')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene3A');
        })

      Button('GesturesConflictScene4')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene4');
        })

      Button('GesturesConflictScene5')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene5');
        })

      Button('GesturesConflictScene6')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene6');
        })

      Button('GesturesConflictScene7')
        .width('100%')
        .onClick(() => {
          this.jumperPage('GesturesConflictScene7');
        })

      Button('WebScrollDemo')
        .width('100%')
        .onClick(() => {
          this.jumperPage('WebScrollDemo');
        })
    }
    .height('100%')
    .width('100%')
    .padding(16)
    .justifyContent(FlexAlign.End)
  }
}