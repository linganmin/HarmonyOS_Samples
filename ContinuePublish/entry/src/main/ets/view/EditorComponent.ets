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

import { unifiedDataChannel, uniformTypeDescriptor } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointConstants } from '../constants/BreakpointConstants';
import { CommonConstants } from '../constants/CommonConstants';
import { BreakpointType } from '../utils/BreakpointSystem';

const DOMAIN = 0x0000;
const TAG = 'EditorComponent';
const FORMAT = '%{public}s';

@Component
export struct EditorComponent {
  @StorageLink('currentBreakpoint') currentBreakpoint: string = BreakpointConstants.BREAKPOINT_LG;
  @StorageLink('mainTitle') mainTitle: string = '';
  @StorageLink('textContent') textContent: string = '';
  // Whether to display the teletext title
  @Link isKeyboard: boolean;
  @Link isShowLocalInfo: boolean;

  getDataFromUdmfRetry(event: DragEvent, callback: (data: DragEvent) => void) {
    try {
      let data: UnifiedData = event.getData();
      if (!data) {
        return false;
      }
      let records: Array<unifiedDataChannel.UnifiedRecord> = data.getRecords();
      if (!records || records.length <= 0) {
        return false;
      }
      callback(event);
      return true;
    } catch (e) {
      console.log("getData failed, code = " + (e as BusinessError).code + ", message = " +
      (e as BusinessError).message);
      return false;
    }
  }

  getDataFromUdmf(event: DragEvent, callback: (data: DragEvent) => void) {
    if (this.getDataFromUdmfRetry(event, callback)) {
      return;
    }
    setTimeout(() => {
      this.getDataFromUdmfRetry(event, callback);
    }, 1500);
  }

  // [Start onDrop]
  build() {
    Flex({ direction: FlexDirection.Column }) {
      TextInput({ text: this.mainTitle, placeholder: $r('app.string.text_input_placeholder') })// [StartExclude onDrop]
        .onChange((mainTitle: string) => {
          this.mainTitle = mainTitle;
          AppStorage.set('mainTitle', mainTitle);
        })
        .onFocus(() => {
          this.isKeyboard = true;
        })
        .onBlur(() => {
          this.isKeyboard = false;
        })
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.integer.text_input_height'))
        .fontSize($r('app.integer.text_size_body1'))
        .backgroundColor($r('sys.color.background_primary'))
        .constraintSize({ minHeight: $r('app.integer.text_input_height') })
        .margin({ top: $r('app.integer.text_input_margin') })// [EndExclude onDrop]
        .draggable(true)
        .allowDrop([uniformTypeDescriptor.UniformDataType.PLAIN_TEXT])
        .onDrop((dragEvent?: DragEvent) => {
          // The logic after the text falls in, realizing the writing of text.
          // [StartExclude onDrop]
          this.getDataFromUdmf((dragEvent as DragEvent), (event: DragEvent) => {
            try {
              let records: Array<unifiedDataChannel.UnifiedRecord> = event.getData().getRecords();
              let plainText: unifiedDataChannel.PlainText = records[0] as unifiedDataChannel.PlainText;
              this.mainTitle = plainText.textContent;
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `GetData failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          })
          // [EndExclude onDrop]
        })

      TextArea({ text: this.textContent, placeholder: $r('app.string.richEditor_placeholder') })// [StartExclude onDrop]
        .width(CommonConstants.FULL_PERCENT)
        .height(CommonConstants.FULL_PERCENT)
        .id(CommonConstants.TITLE_ID)
        .fontSize($r('app.integer.text_size_body1'))
        .backgroundColor($r('sys.color.background_primary'))
        .constraintSize({ minHeight: $r('app.integer.text_input_height') })
        .margin({
          top: $r('app.integer.text_input_margin')
        })
        .onFocus(() => {
          this.isKeyboard = true;
          this.isShowLocalInfo = false;
        })
        .onBlur(() => {
          this.isKeyboard = false;
        })
        .onChange((textContent: string) => {
          this.textContent = textContent;
          AppStorage.set('textContent', textContent);
        })// [EndExclude onDrop]
        .draggable(true)
        .allowDrop([uniformTypeDescriptor.UniformDataType.PLAIN_TEXT])
        .onDrop((dragEvent?: DragEvent) => {
          // The logic after the text falls in, realizing the writing of text.
          // [StartExclude onDrop]
          this.getDataFromUdmf((dragEvent as DragEvent), (event: DragEvent) => {
            try {
              let records: Array<unifiedDataChannel.UnifiedRecord> = event.getData().getRecords();
              let plainText: unifiedDataChannel.PlainText = records[0] as unifiedDataChannel.PlainText;
              this.textContent = plainText.textContent;
            } catch (err) {
              hilog.error(DOMAIN, TAG, FORMAT, `GetData failed. Cause code: ${err.code}, message: ${err.message}`);
            }
          })
          // [EndExclude onDrop]
        })
    }
    .backgroundColor($r('sys.color.background_primary'))
    // [StartExclude onDrop]
    .width(CommonConstants.FULL_PERCENT)
    .height($r('app.integer.flex_input_height'))
    .margin({ bottom: $r('app.integer.flex_input_margin') })
    .layoutWeight(CommonConstants.DEFAULT_LAYOUT_WEIGHT)
    .expandSafeArea([SafeAreaType.KEYBOARD])
    .padding({
      left: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.padding_level0'),
        $r('sys.float.padding_level4'), $r('sys.float.padding_level8')).GetValue(this.currentBreakpoint),
      right: new BreakpointType($r('sys.float.padding_level0'), $r('sys.float.padding_level0'),
        $r('sys.float.padding_level4'), $r('sys.float.padding_level8')).GetValue(this.currentBreakpoint)
    })

    // [EndExclude onDrop]
  }

  // [End onDrop]
}