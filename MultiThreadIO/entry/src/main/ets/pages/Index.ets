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

import { util } from '@kit.ArkTS';
import { common } from '@kit.AbilityKit';
import { promptAction } from '@kit.ArkUI';
import { DatabaseSendable } from '../common/utils/DatabaseSendable';
import { DatabaseTaskPool } from '../common/utils/DatabaseTaskPool';
import { FileTaskPool } from '../common/utils/FileTaskPool';
import { FileSendable } from '../common/utils/FileSendable';
import { CommonConstants } from '../common/constants/CommonConstants';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Entry
@Component
struct Index {
  @State context: common.UIAbilityContext = this.getUIContext().getHostContext() as common.UIAbilityContext;
  @State disabled: boolean = false;
  @State content: string = '';

  showToast(content: string | Resource) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: content,
        duration: CommonConstants.DURATION_TIME
      });
    } catch (error) {
      hilog.error(0x0000, 'Index', '%{public}s', 'showToast error');
    }
  }

  async aboutToAppear() {
    let textOption: util.TextDecoderOptions = {
      fatal: false,
      ignoreBOM: true
    };
    let decodeToString: util.DecodeToStringOptions = {
      stream: false
    };
    try {
      let value = this.context.resourceManager.getRawFileContentSync(CommonConstants.FILE_NAME);
      let decode = util.TextDecoder.create(CommonConstants.ENCODING, textOption);
      this.content = decode.decodeToString(value, decodeToString);
    } catch (error) {
      hilog.error(0x0000, 'Index', '%{public}s', 'getRawFileContentSync error');
    }
  }

  build() {
    Flex({ direction: FlexDirection.Column, justifyContent: FlexAlign.SpaceBetween }) {
      Text($r('app.string.title'))
        .fontSize(30)
        .textAlign(TextAlign.Start)
        .width('100%')
        .fontWeight(FontWeight.Bold)
        .padding({
          top: 56,
          left: 16,
          right: 16
        })

      Column() {
        Button($r('app.string.button_name_1'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            this.disabled = true;
            let filepath = this.context.filesDir;
            let file = new FileTaskPool(filepath, this.content, 100);
            await file.write();
            this.disabled = false;
            this.showToast($r('app.string.success_remind'));
          })

        Button($r('app.string.button_name_2'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            this.disabled = true;
            let filepath = this.context.filesDir;
            let file = new FileTaskPool(filepath, this.content, 100);
            let len = await file.read();
            this.disabled = false;
            if (len === 0) {
              this.showToast($r('app.string.empty_remind'));
              return;
            }
            this.showToast($r('app.string.success_remind'));
          })


        Button($r('app.string.button_name_3'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            this.disabled = true;
            let filepath = this.context.filesDir;
            let file = new FileSendable(filepath, this.content, 100);
            await file.write();
            this.disabled = false;
            this.showToast($r('app.string.success_remind'));
          })

        Button($r('app.string.button_name_4'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            this.disabled = true;
            let filepath = this.context.filesDir;
            let file = new FileSendable(filepath, this.content, 100);
            let len = await file.read();
            this.disabled = false;
            if (len === 0) {
              this.showToast($r('app.string.empty_remind'));
              return;
            }
            this.showToast($r('app.string.success_remind'));
          })

        Button($r('app.string.button_name_5'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            let rdb = new DatabaseTaskPool();
            await rdb.init();
            rdb.makeData(1000);
            await rdb.insertRDB();
            this.showToast($r('app.string.success_remind'));
          })

        Button($r('app.string.button_name_6'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            let rdb = new DatabaseTaskPool();
            await rdb.init();
            let len = await rdb.readRDB();
            if (len === 0) {
              this.showToast($r('app.string.empty_remind'));
              return;
            }
            this.showToast($r('app.string.success_remind'));
          })

        Button($r('app.string.button_name_7'))
          .width('100%')
          .margin({ top: 12 })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            let rdb = new DatabaseSendable();
            await rdb.init();
            rdb.makeData(1000);
            await rdb.insertRDB();
            this.showToast($r('app.string.success_remind'));
          })

        Button($r('app.string.button_name_8'))
          .width('100%')
          .margin({
            top: 12,
            bottom: 16
          })
          .onClick(async () => {
            if (this.disabled) {
              this.showToast($r('app.string.remind'));
              return;
            }
            let rdb = new DatabaseSendable();
            await rdb.init();
            let len = await rdb.readRDB();
            if (len === 0) {
              this.showToast($r('app.string.empty_remind'));
              return;
            }
            this.showToast($r('app.string.success_remind'));
          })
      }.width('100%')
      .padding({
        left: 16,
        right: 16
      })
      .alignSelf(ItemAlign.End)
    }
    .width('100%')
    .height('100%')
  }
}