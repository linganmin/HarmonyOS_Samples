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

import fileNapi from 'libentry.so';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State message: string = '';
  @State content: string = '';
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private path = this.context.filesDir + '/text.txt';

  build() {
    Column() {
      Text($r('app.string.title'))
        .width('100%')
        .fontColor('#E6000000')
        .fontSize(30)
        .fontWeight(700)
        .lineHeight(40)
        .textAlign(TextAlign.Start)
        .margin({ top: 64 })

      Text($r('app.string.write_data'))
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(500)
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ top: 32 })

      TextArea({ text: this.message , placeholder: $r('app.string.placeholder')})
        .width('100%')
        .height('20%')
        .margin({ top: 12 })
        .lineHeight(24)
        .onChange((value: string) => {
          this.message = value;
        })

      Button($r('app.string.write'))
        .width('100%')
        .margin({ top: 12 })
        .onClick(() => {
          fileNapi.write(this.path, this.message);
          this.getUIContext()
            .getPromptAction()
            .showToast({
              message: $r('app.string.written_successfully'),
              showMode: promptAction.ToastShowMode.DEFAULT
            });
        })

      Text($r('app.string.read_data'))
        .fontSize(16)
        .fontColor($r('sys.color.font_secondary'))
        .fontWeight(500)
        .textAlign(TextAlign.Start)
        .width('100%')
        .margin({ top: 24 })

      TextArea({ text: this.content, placeholder: $r('app.string.placeholder_read') })
        .focusable(false)
        .lineHeight(24)
        .width('100%')
        .height('20%')
        .margin({ top: 12 })

      Button($r('app.string.read'))
        .width('100%')
        .margin({ top: 12 })
        .onClick(() => {
          this.content = fileNapi.read(this.path);
          this.getUIContext()
            .getPromptAction().showToast({ message: $r('app.string.read_successfully') });
        })
    }
    .padding({
      left: 16,
      right: 16,
      bottom: 16
    })
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Start)
  }
}
