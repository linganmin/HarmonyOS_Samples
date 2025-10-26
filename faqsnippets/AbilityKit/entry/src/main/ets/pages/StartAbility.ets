/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:如何实现通过调用其他已安装的应用来打开特定文件
 */

// [Start import_module]
import common from '@ohos.app.ability.common';
import Want from '@ohos.app.ability.Want';
import wantConstant from '@ohos.app.ability.wantConstant';
import { BusinessError } from '@ohos.base';
// [End import_module]

// [Start request_want]
// Construct request data Want, taking opening a Word file as an example
let wantInfo: Want = {
  uri: 'file://.../test.docx', // Indicate the URI path of the file to be opened, usually used in conjunction with type
  type: 'application/msword', // Indicate the type of file to be opened
  flags: wantConstant.Flags.FLAG_AUTH_WRITE_URI_PERMISSION, // Authorization to perform write operations on URI
}
// [End request_want]

@Entry
@Component
struct Index {
  @State message: string = 'Hello World';
  aboutToAppear(): void {
    // [Start start_ability]
    // Call the startAbility interface to open files
    let context = this.getUIContext().getHostContext() as common.UIAbilityContext;
    context.startAbility(wantInfo).then(() => {
      // ...
    }).catch((err: BusinessError) => {
      // ...
    })
    // [End start_ability]
  }

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
}