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

import { BusinessError } from '@kit.BasicServicesKit';
import { rcp } from '@kit.RemoteCommunicationKit';
import Logger from '../common/Logger';
import { CommonConstants } from '../common/CommonConstants';
import { SegmentButtonOptions } from '@kit.ArkUI';
import { ItemRestriction, SegmentButton, SegmentButtonTextItem } from '@ohos.arkui.advanced.SegmentButton';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Builder
export function MultipartFormBuilder() {
  MultipartForm()
}

@Component
export struct MultipartForm {
  @State name: string = '';
  @State hobbies: Array<string> = [];
  @State multipartFormHeaders: string = '';
  @State tabOptions: SegmentButtonOptions = SegmentButtonOptions.tab({
    buttons: [{ text: $r('app.string.form_one') },
      { text: $r('app.string.form_two') }] as ItemRestriction<SegmentButtonTextItem>,
    backgroundBlurStyle: BlurStyle.BACKGROUND_THICK,
    fontSize: $r('app.float.segmentButton_font_size'),
    selectedFontSize: $r('app.float.selected_font_size'),
    textPadding: $r('app.float.segmentButton_text_padding'),
  })
  @State tabSelectedIndexes: number[] = [0];
  @StorageLink('MultipartFormHeaders') storageLinkMultipartFormHeaders: string = '';

  @Builder
  NavigationTitle() {
    Column() {
      Text($r('app.string.form_title'))
        .fontSize($r('app.float.form_font_size'))
        .fontColor($r('app.color.font_color'))
        .lineHeight($r('app.float.text_lineHeight'))
        .fontWeight(CommonConstants.TEXT_FONT_WEIGHT)
        .textAlign(TextAlign.Start)
        .width(CommonConstants.FULL_PERCENT)
        .margin({ left: $r('app.float.form_margin_left') })
    }
  }

  multipartFormSubmit() {
    // [Start upload_form]
    // Defines the request header type
    let headers: rcp.RequestHeaders = {
      'accept': 'application/json'
    };
    // configure timeout values for HTTP requests
    let configuration: rcp.Configuration = {
      transfer: {
        timeout: {
          connectMs: 60000,
          transferMs: 60000
        }
      }
    };
    // Cookies included in the HTTP request
    let cookies: rcp.RequestCookies = {
      'name1': 'value1',
      'name2': 'value2',
    };
    // Setting the Data Transmission Range
    let transferRange: rcp.TransferRange = {
      from: 100,
      to: 200
    };

    // Set up multipartFrom data
    const multiForm = new rcp.MultipartForm({
      'Form1': this.name, // string
      'Form2': this.hobbies, // string
      'Form3': {
        contentType: 'text/plain',
        remoteFileName: 'RemoteFileName',
        contentOrPath: '/file/to/Path'
      } // object
    });

    const securityConfig: rcp.SecurityConfiguration = {
      tlsOptions: {
        tlsVersion: 'TlsV1.3'
      }
    };
    // Create a communication session object session
    try {
      const session = rcp.createSession({ requestConfiguration: { security: securityConfig } });
      // Define the request object req
      let req =
        new rcp.Request('https://www.example.com', 'POST', headers, multiForm, cookies, transferRange, configuration);
      req.content = multiForm;

      // Initiate a request
      session.fetch(req).then((response) => {
        Logger.info(`Request succeeded, message is ${JSON.stringify(response)}`);
      }).catch((err: BusinessError) => {
        Logger.error(`err: err code is ${err.code}, err message is ${JSON.stringify(err)}`);
      });
      // [End upload_form]
      this.multipartFormHeaders = JSON.stringify(multiForm, null, 2);
      AppStorage.setOrCreate('MultipartFormHeaders', this.multipartFormHeaders);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'MultipartForm', `createSession failed. code=${err.code}, message=${err.message}`);
    }
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          SegmentButton({ options: this.tabOptions, selectedIndexes: $tabSelectedIndexes })
          if (this.tabSelectedIndexes[0] === 0) {
            Column() {
              Text($r('app.string.input_name'))
                .margin({ top: $r('app.float.form_margin_top'), bottom: $r('app.float.form_margin_bottom') })
                .width(CommonConstants.FULL_PERCENT)
                .textAlign(TextAlign.Start)
              TextInput({ text: this.name })
                .onChange((value: string) => {
                  this.name = value;
                })
                .maxLength(CommonConstants.TEXT_INPUT_MAXLENGTH)
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.COLUMN_HEIGHT)
            .justifyContent(FlexAlign.Start)
          } else {
            Column() {
              Text($r('app.string.choose_hobbies'))
                .margin({ top: $r('app.float.form_margin_top'), bottom: $r('app.float.form_margin_bottom') })
                .width(CommonConstants.FULL_PERCENT)
                .textAlign(TextAlign.Start)
              Column({ space: CommonConstants.COLUMN_SPACE }) {
                // Option1
                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                  Checkbox({ name: 'Basketball', group: 'checkboxGroup' })
                    .selectedColor($r('app.color.selected_color'))
                    .shape(CheckBoxShape.CIRCLE)

                  Text($r('app.string.basketball'))
                    .fontSize($r('app.float.form_text_size'))
                    .lineHeight($r('app.float.form_text_lineHeight'))
                    .fontColor($r('app.color.font_color'))
                    .fontWeight(CommonConstants.FORM_TEXT_FONT_WEIGHT)
                }

                // Option2
                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                  Checkbox({ name: 'Football', group: 'checkboxGroup' })
                    .selectedColor($r('app.color.selected_color'))
                    .shape(CheckBoxShape.CIRCLE)

                  Text($r('app.string.football'))
                    .fontSize($r('app.float.form_text_size'))
                    .lineHeight($r('app.float.form_text_lineHeight'))
                    .fontColor($r('app.color.font_color'))
                    .fontWeight(CommonConstants.FORM_TEXT_FONT_WEIGHT)
                }

                // Option3
                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                  Checkbox({ name: 'Badminton', group: 'checkboxGroup' })
                    .selectedColor($r('app.color.selected_color'))
                    .shape(CheckBoxShape.CIRCLE)

                  Text($r('app.string.badminton'))
                    .fontSize($r('app.float.form_text_size'))
                    .lineHeight($r('app.float.form_text_lineHeight'))
                    .fontColor($r('app.color.font_color'))
                    .fontWeight(CommonConstants.FORM_TEXT_FONT_WEIGHT)
                }

                // Select All
                Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
                  CheckboxGroup({ group: 'checkboxGroup' })
                    .checkboxShape(CheckBoxShape.CIRCLE)
                    .selectedColor($r('app.color.selected_color'))
                    .onChange((itemName: CheckboxGroupResult) => {
                      this.hobbies = [];
                      if (itemName.name.length) {
                        this.hobbies = itemName.name;
                      }
                    })

                  Text($r('app.string.choose_all'))
                    .fontSize($r('app.float.form_text_size'))
                    .lineHeight($r('app.float.form_text_lineHeight'))
                    .fontColor($r('app.color.font_color'))
                }
              }
              .backgroundColor($r('app.color.start_window_background'))
              .borderRadius($r('app.float.form_borderRadius'))
              .padding($r('app.float.padding'))
            }
            .width(CommonConstants.FULL_PERCENT)
            .height(CommonConstants.FORM_COLUMN_HEIGHT)
            .justifyContent(FlexAlign.Start)
          }
          TextArea({ text: String(this.multipartFormHeaders) })
            .height(CommonConstants.FORM_TEXTAREA_HEIGHT)
            .margin({ top: $r('app.float.textArea_margin_top'), bottom: $r('app.float.textArea_margin_bottom') })
            .focusable(false)
        }

        Button($r('app.string.submit'))
          .onClick(() => {
            if (!this.storageLinkMultipartFormHeaders) {
              this.multipartFormSubmit();
            } else {
              let res: rcp.MultipartForm = JSON.parse(this.storageLinkMultipartFormHeaders);
              res.fields.Form1 = this.name || '';
              res.fields.Form2 = this.hobbies || [];
              this.multipartFormHeaders = JSON.stringify(res, null, 2);
            }
          })
          .width(CommonConstants.FULL_PERCENT)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .padding($r('app.float.padding'))
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .title(this.NavigationTitle())
    .backgroundColor($r('app.color.gray_background'))
  }
}