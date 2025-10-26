/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { localChatModel } from '@kit.DataAugmentationKit'

type MessageType = 'tips' | 'request' | 'response';

interface ChatMessage {
  type: MessageType;
  content: string;
}

@Entry
@Component
struct Index {
  @State title: string = 'LocalChatModel';
  @State isStreamMode: boolean = true;
  @State messages: ChatMessage[] = [];
  @State inputText: string = '';
  @State initFlag: boolean = false;
  @State isProcessing: boolean = false;
  @State responseContent: string = '';
  @State chatCounter: number = 0;

  // Initialize the model when the page loads.
  onPageShow() {
    this.initModel();
  }

  private async initModel(): Promise<void> {
    try {
      this.initFlag = await localChatModel.init();
      this.addMessage('tips', (this.initFlag ? 'Initialization successful !' : 'Initialization failed !'));
    } catch (error) {
      this.initFlag = false;
      this.addMessage('tips', `Initialization error: ${error.message}`);
    }
  }

  private scroller: Scroller = new Scroller();

  private scrollToBottom() {
    setTimeout(() => {
      this.scroller.scrollEdge(Edge.Bottom);
    }, 50);
  }

  private addMessage(type: MessageType, content: string): void {
    const newMessage: ChatMessage = {
      type: type,
      content: content,
    };
    this.messages = [...this.messages, newMessage];
    this.scrollToBottom();
  }

  private async DoChat(questionId: number): Promise<void> {
    if (!this.inputText.trim() || this.isProcessing) {
      return;
    }
    const requestQuestion = this.inputText.trim();
    if (!requestQuestion) {
      return;
    }
    this.inputText = '';
    this.addMessage('request', requestQuestion);
    this.responseContent = 'Thinking...';
    this.isProcessing = true;

    const questionInfo: localChatModel.QuestionInfo = {
      questionId: questionId,
      content: requestQuestion
    };

    const localConfig: localChatModel.Config = {
      isStream: this.isStreamMode
    };

    const localChatCallback = async (err: BusinessError, ans: localChatModel.Answer): Promise<void> => {
      this.scrollToBottom();
      if (err) {
        if (this.responseContent == 'Thinking...') {
          this.responseContent = '';
          this.isProcessing = false;
        }
        // Model Operation Related Error Codes
        this.addMessage('tips', `localChatCallback: error code is ${err.code},  ${err.message}`);
        this.scrollToBottom();
      }
      if (ans.content && ans.content.trim() !== '') {
        if (this.responseContent == 'Thinking...') {
          this.responseContent = '';
        }
        this.responseContent += ans.content;
        this.scrollToBottom();
      }
      this.scrollToBottom();
      if (ans.isFinished) {
        this.addMessage('response', this.responseContent);
        this.isProcessing = false;
      }
    };

    try {
      localChatModel.chat(questionInfo, localConfig, localChatCallback);
    } catch (error) {
      // Input Parameter Related Error Codes
      this.addMessage('tips', `chat: error code is ${error.code},  ${error.message}`);
      this.isProcessing = false;
    }
  }

  private clearChat(): void {
    this.messages = [];
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      Column() {
        Row() {
          Text(this.title)
            .fontSize(20)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1a73e8')
            .margin({ left: 12 })

          Circle()
            .width(10)
            .height(10)
            .margin({ left: 12 })
            .fill(this.initFlag ? '#64BB5C' : '#f00')
            .opacity(0.8)

          Text(this.initFlag ? 'Ready' : 'Not ready')
            .margin({ left: 6 })
            .fontSize(12)
            .fontColor('#666')

          Blank()

          Row() {
            Button(this.isStreamMode ? 'Stream' : 'Non-streaming')
              .height(28)
              .fontSize(16)
              .fontWeight(500)
              .backgroundColor('#0c000000')
              .fontColor('#0A59F7')
              .borderRadius(8)
              .onClick(() => {
                this.isStreamMode = !this.isStreamMode;
                this.addMessage('tips', `Switched to  ${this.isStreamMode ? 'Stream' : 'Non-streaming'} `);
              })
          }
          .margin({ right: 12 })
        }
        .width('100%')
        .height(56)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#1a73e888',
          offsetX: 0,
          offsetY: 2
        })

        // Chat Area
        Scroll(this.scroller) {
          Column() {
            ForEach(this.messages, (msg: ChatMessage, index: number) => {
              if (msg.type === 'tips') {
                Row() {
                  Text(msg.content)
                    .fontSize(14)
                    .fontColor('#666')
                    .textAlign(TextAlign.Center)
                    .padding(8)
                }
                .width('100%')
                .justifyContent(FlexAlign.Center)
                .margin({ top: index === 0 ? 0 : 12 })
              } else if (msg.type === 'request') {
                Row() {
                  Blank()
                  Text(msg.content)
                    .fontSize(16)
                    .fontColor(Color.White)
                    .padding(10)
                    .backgroundColor('#1a73e8')
                    .borderRadius(8)
                }
                .width('100%')
                .margin({ top: 12 })
                .justifyContent(FlexAlign.End)
              } else if (msg.type === 'response') {
                Row() {
                  Column() {
                    Text(msg.content)
                      .fontSize(16)
                      .fontColor('#333')
                      .lineHeight(20)
                      .padding(10)
                      .backgroundColor(Color.White)
                      .borderRadius(8)
                  }
                  .borderRadius(8)
                  .margin({ left: 8 })

                  Blank()
                }
                .width('100%')
                .margin({ top: 12 })
                .justifyContent(FlexAlign.Start)
              }
            }, (msg: ChatMessage) => msg.toString())

            // Loading Indicator
            if (this.isProcessing) {
              Row() {
                Column() {
                  Text(this.responseContent)
                    .fontSize(16)
                    .fontColor('#333')
                    .lineHeight(20)
                    .padding(10)
                    .backgroundColor(Color.White)
                    .borderRadius(8)
                }
                .borderRadius(8)
                .margin({ left: 8 })

                Blank()
              }
              .width('100%')
              .margin({ top: 12 })
            }
          }
          .padding(12)
          .width('100%')
        }
        .width('100%')
        .layoutWeight(1)
        .margin({ bottom: 12 })

        // Input Area
        Column() {
          Row() {
            TextInput({ text: this.inputText, placeholder: 'Please enter your question...' })
              .flexGrow(1)
              .height(42)
              .fontSize(16)
              .padding(8)
              .backgroundColor(Color.White)
              .borderRadius(8)
              .width('85%')
              .onChange((value: string) => {
                this.inputText = value;
              })
              .onSubmit(() => {
                if (!this.isProcessing && this.inputText.trim() !== '') {
                  const chatId = this.chatCounter++;
                  this.DoChat(chatId);
                }
              })

            Button('Send')
              .height(40)
              .fontSize(16)
              .fontWeight(500)
              .margin({ right: 12 })
              .backgroundColor('#0A59F7')
              .fontColor(Color.White)
              .borderRadius(8)
              .onClick(() => {
                if (!this.isProcessing && this.inputText.trim() !== '') {
                  const chatId = this.chatCounter++;
                  this.DoChat(chatId);
                }
              })
              .opacity(this.isProcessing || this.inputText.trim() === '' ? 0.4 : 1)

            Button('Clear')
              .height(40)
              .fontSize(16)
              .fontWeight(500)
              .fontColor('#fff')
              .backgroundColor('#ea4335')
              .borderRadius(8)
              .onClick(() => {
                this.clearChat();
              })
          }
          .width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
          .alignItems(VerticalAlign.Center)
        }
        .width('100%')
        .padding(8)
        .backgroundColor(Color.White)
        .borderRadius(8)
        .shadow({
          radius: 4,
          color: '#1a73e888',
          offsetX: 0,
          offsetY: 2
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor('#f0f5ff')
      .padding(20)
    }
    .width('100%')
    .height('100%')
  }
}