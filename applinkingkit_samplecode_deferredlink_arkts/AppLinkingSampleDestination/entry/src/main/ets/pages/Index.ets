/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { deferredLink } from '@kit.AppLinkingKit';
import { Constants } from '../constants/Constants';
import { Page1 } from './Page1';
import { Want } from '@kit.AbilityKit';

@Entry
@Component
struct Index {
  @State message: string = 'App Link target APP';
  @Provide('pageInfos') pageInfos: NavPathStack = new NavPathStack();

  async aboutToAppear(): Promise<void> {
    let want: Want = AppStorage.get('EntryAbilityWant') as Want;
    let uri = want?.uri
    if (uri) {
      if (uri === Constants.APP_LINK_PAGE) {
        this.pageInfos.pushPath({
          name: 'Page1',
          param: 'Pull up the Page1 through AppLinking when the app is already installed'
        });
      }
      return;
    }

    let curDeferredLink: string = await deferredLink.popDeferredLink();
    if (curDeferredLink === Constants.APP_LINK_PAGE) {
      this.pageInfos.pushPath({
        name: 'Page1',
        param: 'Pull up the Page1 through deferred link when the app has not be installed'
      });
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column() {
        Row() {
          Text(this.message)
            .fontWeight(700)
            .fontSize(30)
            .height(40)
            .margin({ left: 16, top: 82 })
        }
        .height('30%')
        .width('100%')
        .justifyContent(FlexAlign.Start)
        .alignItems(VerticalAlign.Top)

        Column() {
          this.newButton('Jump Detail Page', async () => {
            this.pageInfos.pushPath({ name: 'Page1', param: 'Pull up the Page1 through click button' });
          })
        }
        .justifyContent(FlexAlign.End)
        .height('70%')
        .padding({ left: 16, right: 16, bottom: 16 })
        .alignItems(HorizontalAlign.Center)
      }
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .width('100%')
      .height('100%')
    }
    .mode(NavigationMode.Stack)
    .navDestination(this.pageMap)
    .hideToolBar(true)
  }

  @Builder
  newButton(title: string, action: () => void) {
    Button(title, { type: ButtonType.Normal })
      .fontSize(15)
      .fontWeight(FontWeight.Bold)
      .width(328)
      .height(40)
      .onClick(async () => {
        action();
      })
      .borderRadius(20)
  }

  @Builder
  pageMap(name: string) {
    if (name === 'Page1') {
      Page1()
    }
  }
}