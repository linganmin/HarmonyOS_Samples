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

import { LvMarkdownIn } from "@luvi/lv-markdown-in"
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { rag } from "@kit.DataAugmentationKit";
import { common } from "@kit.AbilityKit";
import { SessionDB } from "../viewmodel/SessionDB";
import Config from "../viewmodel/Config";
import MyChatLlm from "../viewmodel/MyChatLlm";
import { AlertDialogHistory, CustomDialogEmailInfo } from "../view/CunstomDialog"


enum Sender {
  Robot = 1,
  User
}

class Message {
  sender: Sender = Sender.Robot
  content: string = ""
}


const TAG = 'IndexPage';

@Entry
@Component
struct Index {
  @State inputStr: string = '';
  @State outputStr: string = '';
  @State openRag: boolean = false;
  @State imageShow: boolean = false;
  @State messages: Message[] = []
  @State isFinished: boolean = true;
  @State data: string = ''; // for input string
  @State showRef: boolean = false
  @State clearShow: boolean = false;
  @State outputWindowVisibility: Visibility = Visibility.Hidden
  @State outputWindowHeight: string = '0%'
  @State showWindowHeight: string = '0%'
  @State refTextHeight: string = '0%'
  @State inputWindowHeight: string = '40vp'
  @State blank0HeightUp: string = 'calc( ( 100% - 40vp) / 2 - 26vp)'
  @State blank0HeightDown: string = 'calc( ( 100% - 40vp) / 2 - 32vp)'
  @State toastId: number = 0
  outputWindowScroller: Scroller = new Scroller()
  sessionTable = new SessionDB();
  msgIdx: number = 0;
  fullAnswer: string = "";
  recvCnt: number = 0;
  streamRunStartTime: Date | undefined = undefined;
  cfg = new Config();
  llm: MyChatLlm = new MyChatLlm();
  currentType = -1;
  currentRef = "";
  dialogController: CustomDialogController | null = new CustomDialogController({
    builder: CustomDialogEmailInfo({}),
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: 20,
    width: '800vp',
    borderWidth: 1,
    borderStyle: BorderStyle.Dashed,
    borderColor: Color.Blue,
    backgroundColor: Color.White,
    shadow: (ShadowStyle.OUTER_FLOATING_SM),
  })
  alertDialogController: CustomDialogController | null = new CustomDialogController({
    builder: AlertDialogHistory({
      confirm: () => {
        this.onAccept()
      }
    }),
    autoCancel: true,
    onWillDismiss: (dismissDialogAction: DismissDialogAction) => {
      console.info("reason=" + JSON.stringify(dismissDialogAction.reason))
      console.log("dialog onWillDismiss")
      if (dismissDialogAction.reason === DismissReason.PRESS_BACK) {
        dismissDialogAction.dismiss();
      }
      if (dismissDialogAction.reason === DismissReason.TOUCH_OUTSIDE) {
        dismissDialogAction.dismiss();
      }
    },
    alignment: DialogAlignment.Center,
    offset: { dx: 0, dy: -20 },
    customStyle: false,
    cornerRadius: '16vp',
    width: '400vp',
    height: '128vp',
    borderWidth: 1,
    borderStyle: BorderStyle.Dashed,
    borderColor: Color.Blue,
    backgroundColor: Color.White,
    shadow: (ShadowStyle.OUTER_FLOATING_SM),
  })

  onAccept() {
    this.clearHistory()
  }

  aboutToAppear(): void {
    hilog.info(0, TAG, "aboutToAppear");
    this.init()
  }

  clearHistory(): void {
    this.messages = [];
    this.msgIdx = -1;
    this.sessionTable.clearHistoryMessage()
  }

  async init() {
    hilog.info(0, TAG, "init");
    this.msgIdx = this.messages.length - 1;
    setTimeout(() => {
      this.outputWindowScroller.scrollTo({
        yOffset: this.outputWindowScroller.getItemRect(0).height,
        xOffset: 0
      })
    }, 100)

    await this.createRAGSession();
  }

  async createRAGSession() {
    let config = AppStorage.get<rag.Config>("config") as rag.Config;
    hilog.info(0, TAG, "getRAGConfig ok");
    let context = AppStorage.get<common.UIAbilityContext>("Context") as common.UIAbilityContext;
    rag.createRagSession(context, config).then(() => {
      hilog.info(0, TAG, "createRAGSession ok");
    }).catch((err: BusinessError) => {
      hilog.info(0, TAG, `createRAGSession failed. code is ${err.code}, message is ${err.message}`);
    });
  }

  setInitialWindow() {
    this.outputWindowVisibility = Visibility.Visible
    this.outputWindowHeight = 'calc( 100% - 133vp)'
    this.showWindowHeight = '0%'
    this.refTextHeight = '35vp'
    this.inputWindowHeight = '40vp'
    this.blank0HeightUp = '0%'
    this.blank0HeightDown = '0%'
    this.imageShow = true;
  }

  startStreamRun = () => {
    if (this.isFinished && this.data.length > 0) {
      this.changeWindowsSizeWithShow(this.showRef);
      this.outputWindowPush(Sender.User, this.data, true, true);
      this.run(this.data).then(() => {
        hilog.info(0, TAG, "run success");
        this.data = ''
      }).catch((err: BusinessError) => {
        hilog.error(0, TAG, `run failed. code is ${err.code}, message is ${err.message}`);
        this.data = ''
      });
    }
  }

  changeWindowsSizeWithShow(showRef: boolean) {
    if (showRef) {
      this.outputWindowVisibility = Visibility.Visible
      this.outputWindowHeight = 'calc( 75% - 133vp)'
      this.showWindowHeight = '25%'
      this.refTextHeight = '35vp'
      this.inputWindowHeight = '40vp'
      this.blank0HeightUp = '0%'
      this.blank0HeightDown = '0%'
      this.imageShow = true;
    } else {
      this.outputWindowVisibility = Visibility.Visible
      this.outputWindowHeight = 'calc( 100% - 133vp )'
      this.showWindowHeight = '0%'
      this.refTextHeight = '35vp'
      this.inputWindowHeight = '40vp'
      this.blank0HeightUp = '0%'
      this.blank0HeightDown = '0%'
      this.imageShow = true;
    }
  }

  async outputWindowPush(sender: Sender, text: string, isNewMsg: boolean, isInsert: boolean) {
    hilog.debug(0, TAG,
      "[TTT] outputWindowPush, isNewMsg: " + isNewMsg + ", text: " + text + ", isInsert: " + isInsert);
    if (isNewMsg) {
      this.messages.push({ sender: sender, content: text })
      this.msgIdx++;
    } else {
      this.messages[this.msgIdx] = { sender: sender, content: text };
    }
    if (isInsert) {
      await this.sessionTable.insertMessage(sender, text)
    }
    try {
      this.outputWindowScroller.scrollTo({
        yOffset: this.outputWindowScroller.getItemRect(0).height,
        xOffset: 0
      })
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getItemRect failed, error code=${err.code}, message=${err.message}`);
    }
  }

  recordStreamRunTime(type: string) {
    if (this.streamRunStartTime) {
      const currentTime = new Date();
      const cost = currentTime.getTime() - this.streamRunStartTime?.getTime();
      hilog.info(0, TAG,
        `StreamRun received token, [${type}] index: ${this.recvCnt}, time: ${currentTime.getTime()}, cost: ${cost}ms`);
    }
  }

  formatItemInfo(stream: rag.Stream) {
    if (!stream || !stream.answer || !stream.answer.data || stream.answer.data.length === 0) {
      return "";
    }
    hilog.warn(0, TAG, `Reference num: ${stream.answer.data.length}`);
    let reference = '\n---\n#### 数据源';
    const itemSet = new Set<string>();
    let actNum = 0;
    for (let item of stream.answer.data) {
      hilog.debug(0, TAG, `ItemInfo: ${JSON.stringify(item)}`);
      const subject = '- ' + item.columns['subject'];
      if (itemSet.has(subject)) {
        continue;
      }
      itemSet.add(subject);
      reference += '\n';
      reference += subject;
      actNum++;
    }
    hilog.warn(0, TAG, `Reference final num: ${actNum}`);
    return reference;
  }

  async run(text: string) {
    hilog.info(0, TAG, "run enter");
    this.isFinished = false;
    this.recvCnt = 0;
    this.fullAnswer = "";
    hilog.info(0, TAG, "before streamRun");
    try {
      // [Start streamRun]
      const answerTypes: Array<rag.StreamType> =
        [rag.StreamType.THOUGHT, rag.StreamType.REFERENCE, rag.StreamType.ANSWER];
      let option: rag.RunConfig = { answerTypes }
      this.streamRunStartTime = new Date();
      hilog.info(0, TAG, `Before streamRun, time: ${this.streamRunStartTime.getTime()}`);
      let ragSession: rag.RagSession = AppStorage.get<rag.RagSession>("RagSessionObject") as rag.RagSession;
      await ragSession.streamRun(text, option, this.onReceived);
      hilog.info(0, TAG, "after streamRun, before responseInStream");
      // [End streamRun]
    } catch (err) {
      this.isFinished = true;
      hilog.error(0, TAG, `run failed. code is ${err.code}, message is ${err.message}`);
      let isNew: boolean = (this.msgIdx % 2 === 0);
      this.isFinished = true;
      this.outputWindowPush(Sender.Robot, `error code: ${err.code}, error message: ${err.message}`, isNew, true);
    }
  }

  onReceived = (err: BusinessError, stream: rag.Stream) => {
    if (err) {
      hilog.error(0, TAG, 'errCode: ' + err.code + ', errMessage: ' + err.message);
      this.fullAnswer = 'errCode: ' + err.code + ', errMessage: ' + err.message;
      this.isFinished = true;
      this.recvCnt++;
      this.llm.cancel();
    } else {
      if (stream.type === rag.StreamType.THOUGHT) {
        if (this.currentType != stream.type) {
          this.recordStreamRunTime('THOUGHT');
          this.fullAnswer = stream.answer.chunk;
        } else {
          this.fullAnswer += stream.answer.chunk;
        }
      } else if (stream.type === rag.StreamType.REFERENCE) {
        if (this.currentType != stream.type) {
          this.recordStreamRunTime('REFERENCE');
          this.currentRef = '';
        }
        this.currentRef += this.formatItemInfo(stream);
      } else if (stream.type === rag.StreamType.ANSWER) {
        if (this.currentType != stream.type) {
          this.recordStreamRunTime('ANSWER');
          this.fullAnswer = stream.answer.chunk;
        } else {
          this.fullAnswer += stream.answer.chunk;
        }
      }
      this.currentType = stream.type;
      this.isFinished = stream.isFinished;
      this.recvCnt++;
      hilog.debug(0, TAG,
        "[TTT] onRecv, " + this.recvCnt + ", isFinished:" + stream.isFinished + ", answer: " + stream.answer.chunk);
    }
    if (this.isFinished) {
      this.fullAnswer += this.currentRef;
      hilog.info(0, TAG, "[TTT] onRecv, total recvCon: " + this.recvCnt + ", full answer: " + this.fullAnswer);
    }
    this.outputWindowPush(Sender.Robot, this.fullAnswer, this.recvCnt === 1, this.isFinished);
  }

  // set dialogController to null when customDialog destroy
  aboutToDisappear() {
    this.dialogController = null; // set dialogController to null
    this.alertDialogController = null;
    this.clearHistory();
  }

  build() {
    Column() {
      // chat history
      Column() {
        Blank()
        Scroll(this.outputWindowScroller) {
          Column() {
            ForEach(this.messages, (item: Message) => {
              if (item.sender === Sender.Robot) {
                Row() {
                  Column() {
                    LvMarkdownIn({ text: item.content })
                      .margin({
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: 12
                      })
                  }
                  .width("90%")
                  .backgroundColor(Color.White)
                  .clipShape(new Rect({ width: '100%', height: '100%', radius: 12 }))
                }
                .width('calc( 100% - 24vp )')
                .margin({ top: 12, bottom: 12, left: '24vp' })
              } else {
                Row() {
                  Blank().width('10%')
                  Blank()
                  Text(item.content)
                    .fontSize(15)
                    .fontColor(Color.Black)
                    .padding(12)
                    .backgroundColor('#1a0a59f7')
                    .clipShape(new Rect({ width: '100%', height: '100%', radius: 12 }))
                    .alignSelf(ItemAlign.End)
                    .copyOption(CopyOptions.LocalDevice)
                }
                .width('80%')
                .margin({ right: '24vp' })
                .alignSelf(ItemAlign.End)
              }
            })
          }
          .width('100%')
          .justifyContent(FlexAlign.Start)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        }
        .scrollable(ScrollDirection.Vertical)
        .scrollBar(BarState.Auto)
        .scrollBarColor(Color.Gray)
        .scrollBarWidth(5)
        .align(Alignment.Bottom)
        .width('100%')
        .height('100%')

      }
      .backgroundColor($r('sys.color.container_modal_background'))
      .height(this.outputWindowHeight)
      .visibility(this.outputWindowVisibility)
      .width('100%')
      .borderRadius(20)
      .clip(true)

      Column() {
        // email source
        Row() {
          // clear history
          Row() {
            if (this.imageShow) {
              Image($r('app.media.ic_ict_soft_delete'))
                .height('16vp')
                .width('16vp')
                .align(Alignment.Start)
                .margin({
                  left: 12
                })
            }
            Text($r('app.string.clear_history'))
              .fontSize('13vp')
              .fontColor(Color.Black)
              .padding('10vp')
              .textAlign(TextAlign.Start)
          }.onClick(() => {
            if (this.alertDialogController != null) {
              this.alertDialogController.open();
            }
          })
          .backgroundColor(Color.White)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .margin({
            left: '24vp'
          })

          Row() {
            if (this.imageShow) {
              Image($r('app.media.email_icon'))
                .height('16vp')
                .width('16vp')
                .align(Alignment.Start)
                .margin({
                  left: '15vp'
                })
            }
            Text($r('app.string.add_email'))
              .fontSize('13vp')
              .fontColor(Color.Black)
              .padding('10vp')
          }.onClick(() => {
            if (this.dialogController != null) {
              this.dialogController.open();
            }
          })
          .backgroundColor(Color.White)
          .borderRadius($r('sys.float.corner_radius_level10'))
          .margin({
            left: '12vp'
          })
        }
        .backgroundColor($r('sys.color.container_modal_background'))
        .width('100%')
        .height(this.refTextHeight)
        .margin({
          top: '18vp',
          bottom: '8vp'
        })

        Blank().height(this.blank0HeightUp)
        Blank()
        // text input row
        Column() {
          Row() {
            // text input
            TextArea({ placeholder: $r('app.string.enter_word'), text: this.data })
              .width('calc( 100% - 90vp)')
              .height('100%')
              .backgroundColor($r('sys.color.container_modal_background'))
              .onKeyEvent((event) => {
                if (event.type === KeyType.Up && event.keyText === 'KEYCODE_ENTER') {
                  this.startStreamRun();
                }
              })
              .onChange((data) => {
                this.data = data.trimEnd();
                if (this.data != '') {
                  this.clearShow = true;
                } else {
                  this.clearShow = false;
                }
              })
              .letterSpacing(1)
              .lineBreakStrategy(LineBreakStrategy.GREEDY)
              .align(Alignment.Center)

            // control the appearance of cancel icon
            if (this.clearShow) {
              Image($r('app.media.cancel'))
                .backgroundColor($r('sys.color.container_modal_background'))
                .width(25)
                .height(25)
                .margin({ right: 5 })
                .onClick(() => {
                  this.data = '';
                })
            } else {
              Blank().width(30)
            }

            // send button
            Button() {
              if (this.isFinished) {
                Image($r("app.media.send"))
                  .width('95%')
                  .height('95%')
              } else {
                LoadingProgress().width(20).height(20).color(Color.Black)
              }
            }
            .type(ButtonType.Capsule)
            .width('35')
            .height('35')
            .backgroundColor($r('sys.color.container_modal_background'))
            .onClick(() => {
              this.startStreamRun();
            })
          }
          .width('calc( 100% - 48vp )')
          .margin({ left: '24vp', right: '24vp' })
          .backgroundColor($r('sys.color.container_modal_background'))
          .border({
            // use boarder to circle the whole row
            width: 2,
            color: Color.Blue,
            radius: {
              topLeft: $r('sys.float.corner_radius_level10'),
              bottomLeft: $r('sys.float.corner_radius_level10'),
              topRight: $r('sys.float.corner_radius_level10'),
              bottomRight: $r('sys.float.corner_radius_level10')
            }
          })
        }
        .width('100%')
        .height(this.inputWindowHeight)
        .margin({ bottom: '32vp' })

        Blank().height(this.blank0HeightDown)
      }
      .backgroundColor($r('sys.color.container_modal_background'))
    }
    .position({ y: 0 })
    .backgroundColor($r('sys.color.container_modal_background'))
  }
}