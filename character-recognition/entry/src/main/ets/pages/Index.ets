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
import { CommonConstants } from '../common/CommonConstants';
import { TextDetailData, MessageBase } from '../viewmodel/MessageModel';

@Entry
@Component
struct WordRecognition {
  @State keyboardHeight: number = 0;
  @State msgLength: number = 0;
  @State keyboardStr: string = '';
  private scroller: Scroller = new Scroller();
  private textDetailData = new TextDetailData();
  textAreaController: TextAreaController = new TextAreaController();

  aboutToAppear(): void {
    this.textDetailData.pushData(new MessageBase($r('app.string.recognition_text_content_one')));
    this.textDetailData.pushData(new MessageBase($r('app.string.recognition_text_content_two')));
  }

  build() {
    Stack({ alignContent: Alignment.BottomEnd }) {
      Column() {
        Text($r('app.string.word_recognition_title_content'))
          .fontSize($r('app.float.recognition_title_font_size'))
          .fontColor($r('app.color.recognition_title_font_color'))
          .fontWeight(FontWeight.Bold)
          .width($r('app.string.recognition_layout_100'))
          .height($r('app.float.recognition_title_height'))
          .lineHeight($r('app.float.recognition_title_line_height'))
          .textAlign(TextAlign.Start)
          .margin({
            left: $r('app.float.recognition_title_margin')
          })
        List({
          scroller: this.scroller,
          initialIndex: this.msgLength - 1
        }) {
          LazyForEach(this.textDetailData, (msg: MessageBase, index: number) => {
            ListItem() {
              if (index > 1) {
                MessageItemView({ msg: msg })
              } else {
                MessageItemView({ msg: msg, bool: true })
              }
            }
          }, (msg: MessageBase) => JSON.stringify(msg))
        }
        .onAreaChange(() => {
          this.scroller.scrollEdge(Edge.Bottom);
        })
        .listDirection(Axis.Vertical)
        .divider({
          strokeWidth: CommonConstants.STROKE_WIDTH,
          color: $r('app.color.recognition_detail_divider')
        })
        .padding({
          left: $r('app.float.recognition_list_padding_left'),
          right: $r('app.float.recognition_list_padding_right'),
          bottom: $r('app.float.recognition_list_padding_bottom')
        })
        .width($r('app.string.recognition_layout_100'))
        .height($r('app.string.recognition_layout_100'))
        .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
      }
      // .padding({ bottom: this.keyboardHeight })
      .backgroundColor($r('app.color.recognition_message_body_background'))
      .height($r('app.string.recognition_layout_100'))
      .expandSafeArea([SafeAreaType.KEYBOARD], [SafeAreaEdge.BOTTOM])

      Row() {
        Image($r('app.media.recognition_chatting_mode_voice'))
          .height($r('app.float.recognition_voice_image_height'))
          .margin({
            left: $r('app.float.recognition_search_font_size'),
            right: $r('app.float.recognition_search_font_size')
          })
        TextInput({ placeholder: '', text: this.keyboardStr })
          .height($r('app.float.recognition_input_height'))
          .layoutWeight(CommonConstants.LAYOUT_WEIGHT)
          .borderRadius($r('app.float.recognition_input_border_radius'))
          .backgroundColor($r('app.string.recognition_input_background'))
          .enterKeyType(EnterKeyType.Send)
          .onChange((value: string) => {
            this.keyboardStr = value;
          })
          .onSubmit(() => {
            if (this.keyboardStr) {
              let msgBody = new MessageBase(this.keyboardStr);
              this.textDetailData.pushData(msgBody);
              this.msgLength = this.textDetailData.totalCount();
              this.keyboardStr = '';
              this.textAreaController.stopEditing();
            }
          })
          .onEditChange((isEditing: boolean) => {
            if (isEditing) {
              this.keyboardHeight = 3000;
            } else {
              this.keyboardHeight = 0;
            }
          })
        Button($r('app.string.recognition_input_button'))
          .height($r('app.float.recognition_input_height'))
          .borderRadius($r('app.float.recognition_input_border_radius'))
          .width($r('app.float.recognition_input_button_width'))
          .margin({
            left: $r('app.float.margin_button'),
            right: $r('app.float.margin_button')
          })
          .fontColor(Color.White)
          .backgroundColor($r('app.color.blue'))
          .onClick(() => {
            if (this.keyboardStr) {
              let msgBody = new MessageBase(this.keyboardStr);
              this.textDetailData.pushData(msgBody);
              this.msgLength = this.textDetailData.totalCount();
              this.scroller.scrollEdge(Edge.Bottom);
              this.keyboardStr = '';
              this.textAreaController.stopEditing();
            }
          })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .alignItems(VerticalAlign.Center)
      .borderRadius({
        topLeft: $r('app.float.recognition_search_border_radius'),
        topRight: $r('app.float.recognition_search_border_radius')
      })
      .backgroundColor(Color.White)
      .width($r('app.string.recognition_layout_100'))
      .height($r('app.float.recognition_outline_height'))
    }
    .width($r('app.string.recognition_layout_100'))
    .height($r('app.string.recognition_layout_100'))
  }
}

@Component
struct MessageItemView {
  @State msg: MessageBase = new MessageBase('');
  @State bool: boolean = false;

  aboutToReuse(params: Record<string, MessageBase>) {
    this.msg = params.msg;
  }

  build() {
    Row() {
      Text(this.msg.msgBody)
        .lineHeight($r('app.float.recognition_message_text_height'))
        .constraintSize({
          minHeight: $r('app.float.recognition_message_inline_height')
        })
        .fontSize($r('app.float.recognition_search_font_size'))
        .fontColor($r('app.color.recognition_top_bar_font_color'))
        .backgroundColor(Color.White)
        .padding({
          top: $r('app.float.recognition_message_item_padding_top'),
          left: $r('app.float.recognition_message_item_padding_left'),
          bottom: $r('app.float.recognition_message_item_padding_bottom'),
          right: $r('app.float.recognition_message_item_padding_right')
        })
        .borderRadius({
          topLeft: this.bool ? 0 : $r('app.float.recognition_message_item_border'),
          topRight: this.bool ? $r('app.float.recognition_message_item_border') : 0,
          bottomLeft: $r('app.float.recognition_message_item_border'),
          bottomRight: $r('app.float.recognition_message_item_border')
        })
        .enableDataDetector(true)
        .dataDetectorConfig({
          types: CommonConstants.TYPES
        })
        .copyOption(CopyOptions.InApp)
    }
    .direction(Direction.Rtl)
    .width($r('app.string.recognition_layout_100'))
    .alignItems(VerticalAlign.Top)
    .margin({
      top: $r('app.float.recognition_message_item_margin_top')
    })
    .padding({
      left: $r('app.float.recognition_message_item_padding'),
      right: $r('app.float.recognition_message_item_padding')
    })
  }
}