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

import { window } from "@kit.ArkUI";
import { BusinessError } from '@kit.BasicServicesKit';
import { NavigationDialog } from "./NavigationDialog";
import { Logger, selectImagesFromAlbum } from 'commons'

const TAG = 'CommentKeyboard';

interface OperateButton {
  icon: Resource
  onClick?: (event: ClickEvent) => void
}

export interface User {
  id: string,
  avatar: ResourceStr
  nickname: string
}

interface ImageInfo {
  id: string
  title: string
  resource: ResourceStr
}

// [Start rich_editor_span]
// features/home/src/main/ets/view/CommentKeyboard.ets
export interface RichEditorSpan {
  value?: string
  resourceValue?: ResourceStr
  type: 'text' | 'image' | 'builder'
  data?: User | ImageInfo
}

// [End rich_editor_span]

@Component
export struct CommentKeyboard {
  private richEditorController = new RichEditorController();
  private frequentEmojiListHeight = 60;
  private friends: User[] = [
    { id: '0', avatar: $r('app.media.friend_1'), nickname: this.getResourceString($r('app.string.friend_nickname_1')) },
    { id: '1', avatar: $r('app.media.friend_2'), nickname: this.getResourceString($r('app.string.friend_nickname_2')) },
  ];
  // [StartExclude comment_keyboard]
  // [Start private]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  private builderSpans: RichEditorSpan[] = [];
  @State keyboardHeight: number = 0;
  @State isEmojiKeyboardVisible: boolean = false;
  @State isAtFriendListVisible: boolean = false;
  @Consume navDialogPageInfos: NavPathStack;
  // When the photo picker is pulled up, the soft keyboard will also be dismissed, but no need to exit the comment page
  @State isPhotoPickerVisible: boolean = false;

  // [Start comment_keyboard1]
  aboutToAppear(): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then(win => {
      this.addKeyboardHeightListener(win);
    }).catch((err: BusinessError) => {
      Logger.error(TAG,
        `getLastWindow Failed. Code:${err.code}, message:${err.message}`);
    });
  }

  aboutToDisappear(): void {
    window.getLastWindow(this.getUIContext().getHostContext()).then(win => {
      this.removeKeyboardHeightListener(win);
    }).catch((err: BusinessError) => {
      Logger.error(TAG,
        `getLastWindow Failed. Code:${err.code}, message:${err.message}`);
    });
  }

  getResourceString(resource: Resource): string {
    try {
      return this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (exception) {
      Logger.error(TAG,
        `getLastWindow Failed. Code:${exception.code}, message:${exception.message}`);
      return '';
    }
  }

  addKeyboardHeightListener(win: window.Window) {
    win.on('keyboardHeightChange', height => {
      Logger.info(TAG, 'keyboard height has changed', this.getUIContext().px2vp(height));
      if (height !== 0) {
        this.keyboardHeight = this.getUIContext().px2vp(height);
        return;
      }
      // [StartExclude comment_keyboard1]
      // if close keyboard, don't set keyboardHeight, avoid EmojiKeyboard height is 0
      if (!this.isEmojiKeyboardVisible) {
        // When the photo picker is pulled up, the soft keyboard will also be dismissed, but no need to exit the comment page
        if (this.isPhotoPickerVisible) {
          return;
        }
        // handle system keyboard close button click
        Logger.info(TAG, 'click soft keyboard close button');
        this.navDialogPageInfos.pop();
      }
      // [EndExclude comment_keyboard1]
    });
  }

  removeKeyboardHeightListener(win: window.Window) {
    win.off('keyboardHeightChange');
  }

  // [End comment_keyboard1]

  getOperateButtons(): OperateButton[] {
    return [
      { icon: $r('app.media.at'), onClick: this.onAtButtonClick },
      {
        icon: this.isEmojiKeyboardVisible ? $r('app.media.keyboard_circle') : $r('app.media.face'),
        onClick: this.onEmojiButtonClick
      },
      { icon: $r('app.media.picture'), onClick: this.onPictureButtonClick },
      { icon: $r('app.media.paper_plane'), onClick: this.onSendComment }
    ];
  }

  onPictureButtonClick: () => void = () => {
    this.isPhotoPickerVisible = true;
    selectImagesFromAlbum(1).then(uris => {
      Logger.info(TAG, JSON.stringify(uris));
    }).finally(() => {
      this.isPhotoPickerVisible = false;
    });
  }
  // [Start comment_keyboard2]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  onAtButtonClick: (event?: ClickEvent) => void = event => {
    const controller = this.richEditorController;
    this.isAtFriendListVisible = true;
    controller.addTextSpan('@', { offset: controller.getCaretOffset() });
  }
  // [End comment_keyboard2]

  onEmojiButtonClick: (event: ClickEvent) => void = event => {
    this.isEmojiKeyboardVisible = !this.isEmojiKeyboardVisible;
  }
  onRichEditorClick: (event: ClickEvent) => void = event => {
    this.isEmojiKeyboardVisible = false;
  }
  // [Start comment_keyboard3]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  onEmojiClick: (icon: Resource) => void = icon => {
    this.richEditorController.addImageSpan(icon, {
      offset: this.richEditorController.getCaretOffset(),
      imageStyle: { size: [20, 20] }
    });
    // [StartExclude comment_keyboard3]
    this.isAtFriendListVisible = false;
    // [EndExclude comment_keyboard3]
  }
  // [End comment_keyboard3]

  // [Start comment_keyboard4]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  onSendComment: () => void = () => {
    let builderSpanIndex = 0;
    let richEditorSpan: RichEditorSpan;
    const richEditorSpans: RichEditorSpan[] = [];
    this.richEditorController.getSpans().forEach((span, index) => {
      const textSpan = span as RichEditorTextSpanResult;
      const imageSpan = span as RichEditorImageSpanResult;
      if (textSpan.value) {
        richEditorSpan = { value: textSpan.value, type: 'text' };
      } else if (this.isBuilderSpan(span)) {
        richEditorSpan = this.builderSpans[builderSpanIndex];
        builderSpanIndex += 1;
      } else {
        richEditorSpan = { resourceValue: imageSpan.valueResourceStr, type: 'image' };
      }
      richEditorSpans.push(richEditorSpan);
    });
    // [StartExclude comment_keyboard4]
    Logger.info(TAG, 'richEditorContent', JSON.stringify(richEditorSpans));
    this.navDialogPageInfos.pop();
    this.navDialogPageInfos.pushPathByName('CommentSendDialog', richEditorSpans);
    // [EndExclude comment_keyboard4]
  }
  // [End comment_keyboard4]

  // [Start comment_keyboard5]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  // [Start comment_keyboard6]
  // [Start onatfriend_click]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  onAtFriendClick: (friend: User) => void = friend => {
    // [StartExclude onatfriend_click]
    const controller = this.richEditorController;
    const offset = controller.getCaretOffset();
    const range: RichEditorRange = { start: offset - 1, end: offset };
    const span = controller.getSpans(range);
    if (offset !== 0 && (span[0] as RichEditorTextSpanResult).value === '@') {
      controller.deleteSpans(range);
    }
    controller.addBuilderSpan(() => this.AtSpan(friend.nickname), {
      offset: controller.getCaretOffset()
    });
    // [EndExclude onatfriend_click]
    this.setBuilderSpans(controller, friend);
  }

  // [End onatfriend_click]

  @Builder
  AtSpan(nickname: string) {
    Text(`@${nickname}`)
      .fontColor(0xFF133667)
      .maxLines(1)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
  }

  // [End comment_keyboard6]

  // [End comment_keyboard5]
  // [EndExclude comment_keyboard]

  // [Start comment_keyboard7]
  setBuilderSpans(controller: RichEditorController, friend: User) {
    const builderSpan: RichEditorSpan = {
      value: `@${friend.nickname}`,
      data: friend,
      type: 'builder'
    };
    const range: RichEditorRange = { end: controller.getCaretOffset() };
    const index = this.getBuilderSpanCount(controller, range) - 1;
    this.builderSpans.splice(index, 0, builderSpan);
  }

  getBuilderSpanCount(controller: RichEditorController, range: RichEditorRange) {
    return controller.getSpans(range).reduce((count: number, span) => {
      return this.isBuilderSpan(span) ? count + 1 : count;
    }, 0);
  }

  // [End private]
  // [End comment_keyboard7]

  // [Start comment_keyboard8]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  aboutToDelete: (value: RichEditorDeleteValue) => boolean = value => {
    const controller = this.richEditorController;
    const span = value.richEditorDeleteSpans[0];
    if (span && this.isBuilderSpan(span)) {
      if (this.hasSelection(controller)) {
        this.deleteBuilderSpan();
        return true;
      }
      controller.setSelection(value.offset, value.offset + 1);
      return false;
    }
    return true;
  }

  // [End comment_keyboard8]

  deleteBuilderSpan() {
    const controller = this.richEditorController;
    const range: RichEditorRange = { end: controller.getCaretOffset() };
    const index = this.getBuilderSpanCount(controller, range) - 1;
    this.builderSpans.splice(index, 1);
  }

  isBuilderSpan(span: RichEditorImageSpanResult | RichEditorTextSpanResult): boolean {
    return !(span as RichEditorTextSpanResult).value &&
      !(span as RichEditorImageSpanResult).valueResourceStr?.toString().replaceAll(' ', '');
  }

  hasSelection(controller: RichEditorController) {
    const selection = controller.getSelection().selection;
    return selection[0] !== selection[1];
  }

  onIMEInputComplete: (result: RichEditorTextSpanResult) => void = result => {
    if (result.value) {
      this.isAtFriendListVisible = false;
    }
  }
  aboutToIMEInput: (value: RichEditorInsertValue) => boolean = value => {
    if (value.insertValue === '@') {
      this.onAtButtonClick();
      return false;
    }
    return true;
  }
  onDeleteComplete: () => void = () => {
    const controller = this.richEditorController;
    const offset = controller.getCaretOffset();
    const span = controller.getSpans({ start: offset - 1, end: offset });
    if (span[0] && (span[0] as RichEditorTextSpanResult).value === '@') {
      this.isAtFriendListVisible = true;
    } else {
      this.isAtFriendListVisible = false;
    }
  }

  getEmojiIcons(): Resource[] {
    const getRandomNum = () => Math.floor(Math.random() * 2) + 1;
    return Array(40).fill(1).map(() => $r(`app.media.emoji_${getRandomNum()}`));
  }

  getFrequentEmojiIcons(): Resource[] {
    const getRandomNum = () => Math.floor(Math.random() * 2) + 3;
    return Array(10).fill(1).map(() => $r(`app.media.emoji_${getRandomNum()}`));
  }

  @Builder
  ToolBar() {
    Column() {
      // [Start comment_keyboard9]
      // features/home/src/main/ets/view/CommentKeyboard.ets
      RichEditor({ controller: this.richEditorController })
        .customKeyboard(this.isEmojiKeyboardVisible ? this.EmojiKeyboard() : undefined)
        // [StartExclude comment_keyboard9]
        .constraintSize({ maxHeight: 120 })
        .placeholder($r('app.string.comment_button_text'))
        .defaultFocus(true)
        .onClick(this.onRichEditorClick)
        .aboutToDelete(this.aboutToDelete)
        .onDeleteComplete(this.onDeleteComplete)
        .onIMEInputComplete(this.onIMEInputComplete)
        .aboutToIMEInput(this.aboutToIMEInput)
      // [EndExclude comment_keyboard9]
      // [End comment_keyboard9]
      Row({ space: 15 }) {
        ForEach(this.getOperateButtons(), (operateButton: OperateButton) => {
          Image(operateButton.icon)
            .width($r('app.float.comment_operate_button_width'))
            .onClick(operateButton.onClick)
        }, (operateButton: OperateButton) => JSON.stringify(operateButton))
      }
      .justifyContent(FlexAlign.End)
      .width('100%')
      .padding({ bottom: 5, right: 10 })
    }
    .margin($r('app.float.padding_small'))
    .backgroundColor($r('app.string.comment_button_bg_color'))
    .borderRadius(20)
  }

  // [Start comment_keyboard10]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  @Builder
  EmojiKeyboard() {
    Grid() {
      ForEach(this.getEmojiIcons(), (icon: Resource) => {
        GridItem() {
          Image(icon)
            .width(45)
            .onClick(() => {
              this.onEmojiClick(icon)
            })
        }
      })
    }
    .width('100%')
    .height(this.keyboardHeight + this.frequentEmojiListHeight)
    // [StartExclude comment_keyboard10]
    .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr')
    .rowsGap(15)
    .padding(10)
    .scrollBar(BarState.Off)

    // [EndExclude comment_keyboard10]
  }

  // [End comment_keyboard10]

  @Builder
  FrequentEmojiList() {
    List({ space: 12 }) {
      ForEach(this.getFrequentEmojiIcons(), (icon: Resource) => {
        ListItem() {
          Image(icon)
            .width(40)
            .onClick(() => {
              this.onEmojiClick(icon)
            })
        }
      })
    }
    .width('100%')
    .height(this.frequentEmojiListHeight)
    .padding({ left: 15 })
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .alignListItem(ListItemAlign.Center)
    .align(Alignment.Start)
  }

  @Builder
  AtFriendList() {
    List({ space: 20 }) {
      ForEach(this.friends, (friend: User) => {
        ListItem() {
          Column() {
            Image(friend.avatar)
              .width(40)
            Text(friend.nickname)
              .constraintSize({ maxWidth: 100 })
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
          }
          .onClick(() => this.onAtFriendClick(friend))
        }
      }, (friend: User) => friend.id)
    }
    .listDirection(Axis.Horizontal)
    .scrollBar(BarState.Off)
    .width('100%')
    .height(this.isAtFriendListVisible ? 70 : 0)
    .animation({ duration: 150 })
    .padding({ left: 15, top: 10 })
    .alignListItem(ListItemAlign.Center)
    .align(Alignment.Start)
  }

  // [Start comment_keyboard11]
  // features/home/src/main/ets/view/CommentKeyboard.ets
  build() {
    NavigationDialog({ maskBackgroundColor: 'rgba(0, 0, 0, 0.1)' }) {
      Column() {
        this.AtFriendList()
        this.ToolBar()
        Divider()
        if (!this.isEmojiKeyboardVisible) {
          this.FrequentEmojiList()
        }
        Column()
          .height(
            this.isEmojiKeyboardVisible ?
              this.keyboardHeight + this.frequentEmojiListHeight :
              this.keyboardHeight
          )
      }
      .backgroundColor(Color.White)
    }
  }

  // [End comment_keyboard11]
}