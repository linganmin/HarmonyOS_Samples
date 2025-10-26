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

import { RichEditorSpan, User } from './CommentKeyboard';
import { NavigationDialog } from './NavigationDialog';

@Component
export struct CommentSendDialog {
  @Consume navDialogPageInfos: NavPathStack;

  getComment(): RichEditorSpan[] {
    return this.navDialogPageInfos.getParamByName('CommentSendDialog')[0] as RichEditorSpan[];
  }

  build() {
    NavigationDialog({
      maskBackgroundColor: 'rgba(0, 0, 0, 0.3)',
      alignContent: Alignment.Center
    }) {
      // [Start comment_send_dialog]
      // features/home/src/main/ets/view/CommentSendDialog.ets
      Column() {
        Text($r('app.string.send_title'))
          .margin({ bottom: 20 })
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.getComment(), (richEditorSpan: RichEditorSpan) => {
            if (richEditorSpan.type === 'text') {
              Text(richEditorSpan.value)
            } else if (richEditorSpan.type === 'image') {
              Image(richEditorSpan.resourceValue)
                .width(20)
            } else {
              Text(`${richEditorSpan.value}(`)
                .fontColor(0xFF133667)
              Text(`id：${(richEditorSpan.data as User).id}; avatar：`)
              Image((richEditorSpan.data as User).avatar)
                .width(20)
              Text(')')
            }
          }, (richEditorSpan: RichEditorSpan) => JSON.stringify(richEditorSpan))
        }
      }
      // [End comment_send_dialog]
      .backgroundColor(Color.White)
      .padding(24)
      .width('90%')
      .borderRadius(32)
      .alignItems(HorizontalAlign.Start)
    }
  }
}