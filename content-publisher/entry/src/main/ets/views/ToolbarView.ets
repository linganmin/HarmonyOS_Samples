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

import { CommonConstants } from '../constants/CommonConstants';
import { GraphicTitleView } from './GraphicTitleView';
import { TopicView } from './TopicView';

@Component
export struct ToolbarView {
  @Link isTopicViewVisible: boolean;
  @State isGraphicTitleViewVisible: boolean = false;
  @Link isEmojiKeyboard: boolean;

  closeTopicView(): void {
    this.isTopicViewVisible = false;
  }

  closeGraphicTitleView() {
    this.isGraphicTitleViewVisible = false;
  }

  @Styles
  toolButton() {
    .width(24)
    .height(24)
    .margin({ right: 16 })
  }

  @Builder
  topicViewBuilder() {
    TopicView({
      onSelect: () => {
        this.closeTopicView();
      }
    })
  }

  @Builder
  graphicTitleViewBuilder() {
    GraphicTitleView({
      onSelect: () => {
        this.closeGraphicTitleView();
      }
    })
  }

  build() {
    Column() {
      Flex({ justifyContent: FlexAlign.Start, alignItems: ItemAlign.Center }) {
        Image(this.isEmojiKeyboard ? $r('app.media.ic_public_keyboard') : $r('app.media.ic_symbol1'))
          .toolButton()
          .onClick(() => {
            this.isEmojiKeyboard = !this.isEmojiKeyboard;
            // set richEditor on focus when toggle emoji keyboard
            this.getUIContext().getFocusController().requestFocus(CommonConstants.RICH_EDITOR_ID);
          })
        Image($r('app.media.ic_symbol2'))
          .focusable(true)
          .toolButton()
          .onClick(() => {
            this.isGraphicTitleViewVisible = !this.isGraphicTitleViewVisible;
          })
          .bindSheet($$this.isGraphicTitleViewVisible, this.graphicTitleViewBuilder(), {
            detents: [SheetSize.MEDIUM],
            backgroundColor: Color.White,
            blurStyle: BlurStyle.Thick,
            showClose: true,
            title: { title: $r('app.string.topic') },
            preferType: SheetType.CENTER
          })
        Image($r('app.media.ic_symbol3'))
          .toolButton()
          .onClick(() => {
            this.getUIContext().getRouter().pushUrl({ url: 'pages/ContactListPage' });
          })
        Image($r('app.media.ic_symbol4'))
          .toolButton()
          .onClick(() => {
            this.isTopicViewVisible = true;
          })
          .bindSheet($$this.isTopicViewVisible, this.topicViewBuilder(), {
            detents: [SheetSize.LARGE],
            backgroundColor: Color.White,
            blurStyle: BlurStyle.Thick,
            showClose: true,
            title: { title: $r('app.string.topic') },
            preferType: SheetType.CENTER
          })
      }
      .width('100%')
      .padding({ left: 17 })
      .height(56)
    }
    .backgroundColor($r('sys.color.background_secondary'))
    .justifyContent(FlexAlign.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}