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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { ComponentContent, PromptAction, promptAction } from '@kit.ArkUI';
import { ItemHead } from '../uiComponent/ItemHead';
import { SubItemHead } from '../uiComponent/SubItemHead';
import { PromptActionClass } from '../utils/PromptActionClass';
import { AgreementPage } from './AgreementPage';
import { CommentList } from './CommentList';
import { PrivacyDialog } from './PrivacyDialog';

let timer: number = 0;
let getUIContext: UIContext;
let contentNode: ComponentContent<Object>;
let progressContentNode: ComponentContent<Object>;
let actionTipsContentNode: ComponentContent<Object>;
let imageTipsContentNode: ComponentContent<Object>;
let isProgressRunning: boolean = false;
let value: number = 0;

class Params {
  text: ResourceStr = '';

  constructor(text: ResourceStr) {
    this.text = text;
  }
}

class ProgressParams {
  text: ResourceStr = '';
  value: number = 0;
  isProgressRunning: boolean = false;

  constructor(text: ResourceStr, value: number, isProgressRunning: boolean) {
    this.text = text;
    this.value = value;
    this.isProgressRunning = isProgressRunning;
  }
}

class ActionParams {
  text: ResourceStr = '';
  text2: ResourceStr = '';

  constructor(text: ResourceStr, text2: ResourceStr) {
    this.text = text;
    this.text2 = text2;
  }
}

class ActionListParams {
  text: ResourceStr = '';
  text2?: ResourceStr = '';

  constructor(text: ResourceStr, text2?: ResourceStr) {
    this.text = text;
    this.text2 = text2;
  }
}

// [Start image_text]
// Graphic and text prompt.
@Builder
function buildText(params: Params) {
  // [Start image_text_style]
  Row() {
    Image($r('app.media.checkmark_circle'))
      .width(24)
      .height(24)
      .margin({ right: 16 })
    Text(params.text)
      .fontSize(16)
  }
  // [End image_text_style]
  .justifyContent(FlexAlign.Center)
  .backgroundColor(Color.White)
  .padding({ left: 24, right: 24 })
  .height(50)
  .borderRadius(24)
}

// [End image_text]

// Operation prompt.
@Builder
function buildActionTips(params: ActionParams) {
  Row() {
    Row() {
      Image($r('app.media.checkmark_circle_fill'))
        .width(24)
        .height(24)
        .margin({ right: 8 })
      Text(params.text)
        .fontSize(16)
    }

    Row() {
      Text(params.text2)
        .fontSize(16)
        .margin({ right: 8 })
      Image($r('app.media.chevron_right'))
        .width(12)
        .height(12)
    }
    .onClick(() => {
      getUIContext.getPromptAction().showToast({
        message: $r('app.string.after'),
        duration: 2000,
        showMode: promptAction.ToastShowMode.DEFAULT,
        bottom: 48
      });
    })
  }
  .justifyContent(FlexAlign.SpaceBetween)
  .backgroundColor(Color.White)
  .padding({ left: 16, right: 16 })
  .width(350)
  .height(50)
  .borderRadius(24)
}

// Progress bar
@Builder
function buildProgress(params: ProgressParams) {
  Column() {
    Row() {
      Column() {
        Row() {
          Text(params.text)
            .fontSize(16)
          Text(`${params.value}%`)
            .fontColor(Color.Gray)
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)

        Progress({ value: 0, total: 100, type: ProgressType.Linear })
          .width('100%')
          .height(20)
          .value(params.value)
          .margin({ top: 12 })
      }
      .width('80%')

      Row() {
        Image($r('app.media.mark_circle_fill'))
          .width(30)
          .height(30)
          .onClick(() => {
            PromptActionClass.closeDialog(progressContentNode);
          })
      }
      .margin({ left: 12, top: 30 })
    }

    // [Start Progress]
    Text(isProgressRunning ? $r('app.string.pause') : $r('app.string.start'))
      .fontSize(16)
      .fontColor('#0A59F7')
      .margin({ top: 8 })
      .onClick(() => {
        isProgressRunning = !isProgressRunning;
        if (isProgressRunning) {
          timer = setInterval(() => {
            if (value === 100) {
              value = 0;
            }
            value += 10;
            progressContentNode.update(new ProgressParams($r('app.string.progress'), value, isProgressRunning));
          }, 1000)
        } else {
          clearInterval(timer);
        }
        progressContentNode.update(new ProgressParams($r('app.string.progress'), value, isProgressRunning));
      })
    // [End Progress]
  }
  .alignItems(HorizontalAlign.Center)
  .justifyContent(FlexAlign.SpaceEvenly)
  .backgroundColor('#FFF0F0F0')
  .padding({
    left: 24,
    right: 24,
    top: 16,
    bottom: 16
  })
  .width(320)
  .height(140)
  .borderRadius(24)
}

let actionList: Array<object> = [
  new ActionListParams($r('app.string.not_interested'), $r('app.string.reduce')),
  new ActionListParams($r('app.string.shield'), $r('app.string.share'))
]

// Operation list
@Builder
function buildActionList() {
  Column() {
    List() {
      ListItemGroup() {
        ForEach(actionList, (item: ActionListParams) => {
          ListItem() {
            Row() {
              Text(item.text).fontSize(16)
              Text(item.text2).fontSize(14)
                .fontColor(Color.Gray)
            }
            .width('100%')
            .height(50)
            .justifyContent(FlexAlign.SpaceBetween)
          }

        }, (item: ActionListParams) => JSON.stringify(item))
      }
      .divider({ strokeWidth: 1, color: '#F8F8FF' })
    }
    .backgroundColor(Color.White)
    .width('100%')
    .height('auto')
    .padding({
      left: 16,
      right: 16,
      top: 8,
      bottom: 8
    })
    .borderRadius(16)
  }
  .padding(16)
  .width('100%')
}

// Confirm the pop-up window
@Builder
function customDialogComponent() {
  Column() {
    Column() {
      Text($r('app.string.cancel')).fontSize(20)
        .fontWeight(FontWeight.Bold)
      Text($r('app.string.cancel_user'))
        .fontSize(16)
        .fontColor(Color.Gray)
    }
    .justifyContent(FlexAlign.SpaceEvenly)
    .height(120)

    Row() {
      Text($r('app.string.think_again'))
        .fontColor('#0A59F7')
        .onClick(() => {
          PromptActionClass.closeDialog(contentNode);
        })
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)

      Text($r('app.string.confirm'))
        .fontColor('#0A59F7')
        .onClick(() => {
          PromptActionClass.closeDialog(contentNode);
        })
        .width('50%')
        .height('100%')
        .textAlign(TextAlign.Center)
    }
    .height(50)
  }
  .width(350)
  .padding({ bottom: 8 })
  .borderRadius(32)
  .backgroundColor(Color.White)
}

class objectParams {
  img: ResourceStr = ''
  text: ResourceStr = ''
}

@Entry
@Component
struct Index {
  @State message: ResourceStr = $r('app.string.tips');
  promptAction: PromptAction = this.getUIContext().getPromptAction();
  @Provide('NavPathStack') pathStack: NavPathStack = new NavPathStack();
  @State customPopup: boolean = false;
  @State listCustomPopup: boolean = false;
  @State simpleList: objectParams[] = [
    {
      img: $r('app.media.line_viewfinder'),
      text: $r('app.string.scan')
    },
    {
      img: $r('app.media.star'),
      text: $r('app.string.collect')
    },
    {
      img: $r('app.media.setting'),
      text: $r('app.string.setting')
    }
  ];

  aboutToAppear(): void {
    AppStorage.setOrCreate('NavPathStack', this.pathStack);
    getUIContext = this.getUIContext();
    contentNode = new ComponentContent(getUIContext, wrapBuilder(customDialogComponent));
    imageTipsContentNode = new ComponentContent(getUIContext, wrapBuilder(buildText), new Params(this.message));
    actionTipsContentNode = new ComponentContent(getUIContext, wrapBuilder(buildActionTips),
      new ActionParams($r('app.string.collection_successful'), $r('app.string.join_the_album')))
    progressContentNode = new ComponentContent(getUIContext, wrapBuilder(buildProgress),
      new ProgressParams($r('app.string.progress'), value, false));
  }

  @Builder
  PagesMap(name: string) {
    if (name === 'AgreementPage') {
      AgreementPage();
    } else if (name === 'PrivacyDialog') {
      PrivacyDialog();
    } else if (name === 'CommentList') {
      CommentList();
    }
  }

  build() {
    Navigation(this.pathStack) {
      Column() {
        // Not modal dialog.
        ItemHead($r('app.string.non_modal_dialog'))
        SubItemHead($r('app.string.tips_title'))
        List() {
          ListItemGroup() {
            ListItem() {
              Text($r('app.string.text_tips'))
                .onClick(() => {
                  // Show toast
                  this.getUIContext().getPromptAction().showToast({
                    message: $r('app.string.message'),
                    duration: 2000,
                    showMode: promptAction.ToastShowMode.DEFAULT,
                    bottom: 48
                  });
                })
                .width('100%')
            }
            .height(40)

            ListItem() {
              Text($r('app.string.img_tips'))
                .onClick(() => {
                  // [Start image_text_tips]
                  // Open the graphic and text prompts
                  let uiContext = this.getUIContext();
                  PromptActionClass.setContext(uiContext);
                  PromptActionClass.setContentNode(imageTipsContentNode);
                  // [Start focusable]
                  PromptActionClass.setOptions({
                    isModal: false,
                    alignment: DialogAlignment.Bottom,
                    offset: { dx: 0, dy: -80 },
                    focusable: false
                  });
                  // [End focusable]
                  PromptActionClass.openDialog();
                  setTimeout(() => {
                    PromptActionClass.closeDialog(imageTipsContentNode);
                  }, 3000)
                  // [End image_text_tips]
                })
                .width('100%')
            }
            .height(40)

            ListItem() {
              Text($r('app.string.operate_tips'))
                .onClick(() => {
                  // Open the operation prompt
                  let uiContext = this.getUIContext();
                  PromptActionClass.setContext(uiContext);
                  PromptActionClass.setContentNode(actionTipsContentNode);
                  PromptActionClass.setOptions({
                    isModal: false,
                    alignment: DialogAlignment.Bottom,
                    offset: { dx: 0, dy: -80 }
                  });
                  PromptActionClass.openDialog();
                  setTimeout(() => {
                    PromptActionClass.closeDialog(actionTipsContentNode);
                  }, 3000)
                })
                .width('100%')
            }
            .height(40)
          }
          .divider({ strokeWidth: 1, color: '#F3F3F3' })
        }
        .backgroundColor(Color.White)
        .width('100%')
        .height('auto')
        .padding({
          left: 16,
          right: 16,
          top: 4,
          bottom: 4
        })
        .borderRadius(16)

        // Modal dialog.
        ItemHead($r('app.string.modal_dialog'))
        SubItemHead($r('app.string.dialog'))
        List() {
          ListItemGroup() {
            ListItem() {
              Text($r('app.string.confirm_dialog'))
                .onClick(() => {
                  // Open the confirmation pop-up window
                  let uiContext = this.getUIContext();
                  PromptActionClass.setContext(uiContext);
                  PromptActionClass.setContentNode(contentNode);
                  PromptActionClass.setOptions({ autoCancel: false });
                  PromptActionClass.openDialog();
                })
                .width('100%')
            }
            .height(40)

            ListItem() {
              Row() {
                Text($r('app.string.privacy_dialog'))
                Image($r('app.media.chevron_right_gray'))
                  .width(14)
                  .height(14)
              }
              .onClick(() => {
                this.pathStack.pushPathByName('PrivacyDialog', '');
              })
              .width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
            .height(40)

            ListItem() {
              Text($r('app.string.progress_dialog'))
                .onClick(() => {
                  // [Start progress_bar]
                  // Open the progress bar pop-up window
                  let uiContext = this.getUIContext();
                  PromptActionClass.setContext(uiContext);
                  PromptActionClass.setContentNode(progressContentNode);
                  PromptActionClass.setOptions({
                    autoCancel: true,
                    // [Start animation]
                    transition: TransitionEffect.asymmetric(
                      TransitionEffect.OPACITY.animation({ duration: 1000 }),
                      TransitionEffect.OPACITY.animation({ delay: 500, duration: 1000 })
                    )
                    // [End animation]
                  })
                  PromptActionClass.openDialog();
                  // [End progress_bar]
                })
                .width('100%')
            }
            .height(40)
          }
          .divider({ strokeWidth: 1, color: '#F3F3F3' })
        }
        .backgroundColor(Color.White)
        .width('100%')
        .height('auto')
        .padding({
          left: 16,
          right: 16,
          top: 4,
          bottom: 4
        })
        .borderRadius(16)
        .margin({ bottom: 4 })

        SubItemHead($r('app.string.operation'))
        List() {
          ListItemGroup() {
            ListItem() {
              // [Start operation_list]
              Text($r('app.string.operation_list'))
                .onClick(() => {
                  // Open the operation list pop-up window
                  let contentNode =
                    new ComponentContent(this.getUIContext(), wrapBuilder(buildActionList));
                  let uiContext = this.getUIContext();
                  let uniqueId = this.getUniqueId();
                  let frameNode: FrameNode | null = uiContext.getFrameNodeByUniqueId(uniqueId);
                  let targetId = frameNode?.getFirstChild()?.getUniqueId();
                  uiContext.openBindSheet(contentNode, {
                    title: { title: $r('app.string.more') },
                    height: SheetSize.MEDIUM,
                    backgroundColor: '#F1F3F5',
                    preferType: SheetType.BOTTOM
                  }, targetId)
                    .then(() => {
                      hilog.info(0xFF00, 'TAG', 'openBindSheet success');
                    })
                    .catch((err: BusinessError) => {
                      hilog.info(0xFF00, 'TAG', 'openBindSheet error: ' + err.code + ' ' + err.message);
                    })
                })
                .width('100%')
              // [End operation_list]
            }
            .height(40)

            ListItem() {
              Text($r('app.string.list'))
                .onClick(() => {
                  // Open the pop-up window of the variable height operation list
                  let contentNode =
                    new ComponentContent(this.getUIContext(), wrapBuilder(buildActionList));
                  let uiContext = this.getUIContext();
                  let uniqueId = this.getUniqueId();
                  let frameNode: FrameNode | null = uiContext.getFrameNodeByUniqueId(uniqueId);
                  let targetId = frameNode?.getFirstChild()?.getUniqueId();
                  // [Start operation_list_variable]
                  uiContext.openBindSheet(contentNode, {
                    title: { title: $r('app.string.more') },
                    height: SheetSize.MEDIUM,
                    backgroundColor: '#F1F3F5',
                    preferType: SheetType.BOTTOM,
                    detents: [SheetSize.MEDIUM, SheetSize.LARGE, 200]
                  }, targetId)
                    .then(() => {
                      hilog.info(0xFF00, 'TAG', 'openBindSheet success');
                    })
                    .catch((err: BusinessError) => {
                      hilog.info(0xFF00, 'TAG', 'openBindSheet error: ' + err.code + ' ' + err.message);
                    })
                  // [End operation_list_variable]
                })
                .width('100%')
            }
            .height(40)

            ListItem() {
              Text($r('app.string.comment_reply_dialog'))
                .onClick(() => {
                  this.pathStack.pushPathByName('CommentList', '');
                })
                .width('100%')
            }
            .height(40)
          }
          .divider({ strokeWidth: 1, color: '#F3F3F3' })
        }
        .backgroundColor(Color.White)
        .width('100%')
        .height('auto')
        .borderRadius(16)
        .padding({
          left: 16,
          right: 16,
          top: 4,
          bottom: 4
        })
      }
      .height('100%')
      .padding({
        top: 32,
        bottom: 36,
        left: 16,
        right: 16
      })
    }
    .backgroundColor('#F1F3F5')
    .navDestination(this.PagesMap)
    .width('100%')
    .height('100%')
    .hideToolBar(true)
  }
}