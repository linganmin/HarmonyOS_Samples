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

import { tag } from '@kit.ConnectivityKit';

@Entry
@Component
struct Index {
  @Provide('NavPathStack') pageStack: NavPathStack = new NavPathStack();
  // If the tagInfo information changes, call the tagInfoChange function to jump to the subpage and display the data.
  @StorageLink('tagInfo') @Watch('tageInfoChange') tagInfo: tag.TagInfo = {
    uid: [],
    technology: [],
    supportedProfiles: []
  };

  tageInfoChange() {
    if (canIUse('SystemCapability.Communication.NFC.Tag')) {
      // If the tagInfo object and technology field are not empty, jump to the rotor page.
      if (this.tagInfo && this.tagInfo.technology && this.tagInfo.technology.length !== 0) {
        this.pageStack.pushPathByName('ReadNFCTag', null);
      }
    }
  }

  // Navigation title.
  @Builder
  navTitleBuilder() {
    Text($r('app.string.nfc_tag'))
      .fontSize(30)
      .fontWeight(700)
      .padding({ left: 16 })
  }

  build() {
    Navigation(this.pageStack) {
      Column() {
        Text($r('app.string.near_identify_NFC_Tag'))
          .width('100%')
          .height('20%')
          .borderWidth(2)
          .borderRadius(8)
          .borderColor('#e6e8e9')
          .borderStyle(BorderStyle.Dashed)
          .textAlign(TextAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .justifyContent(FlexAlign.Start)
    }
    .title(this.navTitleBuilder())
    .width('100%')
    .height('100%')
  }
}