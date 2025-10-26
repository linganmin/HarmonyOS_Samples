/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { ChatListPage } from './ChatListPage';
import { MailPage } from './MailPage';
import { ContactPage } from './ContactPage';
import { Comment } from './Comment';
import { CommonConstants as Const } from '../common/constants/CommonConstants';
import { Contact } from '../viewmodel/ContactData';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();

  @Builder
  PagesMap(name: string, param: object) {
    if (name === 'Comment') {
      NavDestination() {
        Comment()
      }
      .hideTitleBar(true)
      .backgroundColor($r('app.color.comment_background'))
      .mode(NavDestinationMode.DIALOG)
    } else {
      NavDestination() {
        if (name === 'ChatListPage') {
          ChatListPage()
        } else if (name === 'MailPage') {
          MailPage()
        } else if (name === 'ContactPage') {
          ContactPage(param as Contact)
        }
      }
      .hideTitleBar(true)
    }

  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Button($r('app.string.chat_list'))
          .width(Const.FULL_SIZE)
          .onClick(() => {
            this.pageStack.pushPathByName('ChatListPage', '');
          })
        Button($r('app.string.mail_page'))
          .margin({
            top: $r('app.float.margin_12')
          })
          .width(Const.FULL_SIZE)
          .onClick(() => {
            this.pageStack.pushPathByName('MailPage', '');
          })
        Button($r('app.string.comment_page'))
          .margin({
            top: $r('app.float.margin_12'),
            bottom: $r('app.float.margin_16')
          })
          .width(Const.FULL_SIZE)
          .onClick(() => {
            this.pageStack.pushPathByName('Comment', '');
          })
      }
      .padding({
        bottom: $r('app.float.margin_16'),
        left: $r('app.float.margin_16'),
        right: $r('app.float.margin_16')
      })
      .height(Const.FULL_SIZE)
      .justifyContent(FlexAlign.End)
    }
    .hideTitleBar(true)
    .mode(NavigationMode.Stack)
    .navDestination(this.PagesMap)
  }
}

