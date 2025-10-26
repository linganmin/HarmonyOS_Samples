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

import { cryptoFramework } from '@kit.CryptoArchitectureKit';
import { buffer } from '@kit.ArkTS';
import CommonConstants from '../constants/CommonConstants';
import { SummaryItem } from '../viewmodel/SummaryItem';
import { getResourceString } from '../utils/ResourceString';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function SummaryDetailBuilder() {
  SummaryDetail();
}

const TAG: string = 'SummaryDetail';

@Component
export struct SummaryDetail {
  @Consume('pageInfos') pageInfos: NavPathStack;
  @State SummaryItem: SummaryItem = new SummaryItem($r('app.string.empty'), '');
  @State message: string = '';
  @State MessageResult: string = '';

  aboutToAppear(): void {
    this.SummaryItem = this.pageInfos.getParamByName('SummaryDetail')[0] as SummaryItem;
  }

  async doSummary(message: string, type: string) {
    try {
      if (type === 'SHA256Segments') {
        let mdAlgName = 'SHA256'; // Digest algorithm name.
        let md = cryptoFramework.createMd(mdAlgName);
        let messageData = new Uint8Array(buffer.from(message, 'utf-8').buffer);
        // Assume that the segment update is performed in the unit of 20 bytes. in practice,there is no requirement.
        let updateLength = 20;
        for (let i = 0; i < messageData.length; i += updateLength) {
          let updateMessage = messageData.subarray(i, i + updateLength);
          let updateMessageBlob: cryptoFramework.DataBlob = { data: updateMessage };
          await md.update(updateMessageBlob);
        }
        let mdOutput = await md.digest();
        this.MessageResult = `${mdOutput.data}`;
      } else {
        let mdAlgName = type; // Digest algorithm name.
        let md = cryptoFramework.createMd(mdAlgName);
        await md.update({ data: new Uint8Array(buffer.from(message, 'utf-8').buffer) });
        let mdResult = await md.digest();
        this.MessageResult = `${mdResult.data}`;
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `doSummary failed, error code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          TextInput({ text: this.message, placeholder: $r('app.string.text_summary') })
            .margin({ top: $r('app.float.margin_top_sixteen') })
            .backgroundColor(Color.White)
            .onChange((value) => {
              this.message = value;
            })

          Column() {
            Text($r('app.string.summary_result'))
              .margin({ left: $r('app.float.margin_left_five') })

            TextArea({ text: this.MessageResult })
              .height($r('app.float.textarea_height'))
              .margin({ top: $r('app.float.margin_top_sixteen') })
              .backgroundColor(Color.White)
              .enabled(false)
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ top: $r('app.float.margin_top_sixteen') })
        }

        Button() {
          Text(this.SummaryItem.name)
            .fontSize($r('app.float.common_font'))
            .fontColor(Color.White)
        }
        .onClick(() => {
          this.doSummary(this.message, this.SummaryItem.type);
        })
        .enabled(this.message ? true : false)
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.button_height'))
        .margin({ top: $r('app.float.margin_top_sixteen') })
      }
      .padding({
        left: $r('app.float.medium_padding'),
        right: $r('app.float.medium_padding'),
        bottom: $r('app.float.medium_padding')
      })
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title(getResourceString(this.SummaryItem.name, this.getUIContext()))
    .backgroundColor($r('app.color.background_page'))
  }
}