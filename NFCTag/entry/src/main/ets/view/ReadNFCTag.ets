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

@Builder
export function ReadNFCTagBuilder() {
  ReadNFCTag()
}

interface TagTypeInterface {
  id: number,
  type: string
}

@Component
struct ReadNFCTag {
  @State nfcInfo: string = '';
  @State technology: number[] = [];
  @Consume('NavPathStack') pageStack: NavPathStack;

  aboutToAppear() {
    // Obtain tagInfo through AppStorage.
    let tagInfo: tag.TagInfo | undefined = AppStorage.get('tagInfo');
    if (canIUse('SystemCapability.Communication.NFC.Tag')) {
      if (tagInfo && tagInfo.technology && tagInfo.technology.length !== 0) {
        this.nfcInfo = JSON.stringify(tagInfo);
        this.technology = tagInfo.technology;
      }
    }
  }

  // NFC card related technology types and their corresponding values.
  getTagType() {
    let tagTypeArr: TagTypeInterface[] = [
      { id: 1, type: 'NfcA' },
      { id: 2, type: 'NfcB' },
      { id: 3, type: 'IsoDep' },
      { id: 4, type: 'NfcF' },
      { id: 5, type: 'NfcV' },
      { id: 6, type: 'NDEF' },
      { id: 7, type: 'NDEF Formatable' },
      { id: 8, type: 'MifareClassic' },
      { id: 9, type: 'MifareUltralight' },
    ]
    return tagTypeArr;
  }

  // NavDestination title.
  @Builder
  navDestinationTitle() {
    Text($r('app.string.nfc_tag_information'))
      .width('100%')
      .fontSize(20)
      .lineHeight(42)
      .fontWeight(700)
      .padding({ left: 12 })
  }

  build() {
    NavDestination() {
      Column() {
        Column() {
          Text($r('app.string.card_Technology_types'))
            .fontSize(18)
            .fontWeight(700)
            .margin({ bottom: 6 })
          Row() {
            // Display the technology types supported by the card.
            if (this.technology.length !== 0) {
              ForEach(this.technology, (item: number) => {
                ForEach(this.getTagType(), (tagItem: TagTypeInterface) => {
                  Text(item === tagItem.id ?
                    this.technology.indexOf(item) === this.technology.length - 1 ? tagItem.type :
                      tagItem.type + '/' : '')
                    .fontColor('#606162')
                }, (item: TagTypeInterface) => JSON.stringify(item))
              }, (item: number) => JSON.stringify(item))
            } else {
              Text($r('app.string.no_card_message'))
            }
          }
          .width('100%')
          .padding({
            top: 8,
            bottom: 8,
            left: 16,
            right: 16
          })
          .borderRadius(12)
          .backgroundColor('#f8f8f8')
        }
        .padding({ top: 18, bottom: 8 })
        .alignItems(HorizontalAlign.Start)

        Text($r('app.string.tagInfo_information'))
          .fontSize(18)
          .fontWeight(700)
          .margin({ top: 18, bottom: 8 })
        // TagInfo object information.
        TextArea({
          text: this.nfcInfo.length === 0 ? $r('app.string.no_card_message') : this.nfcInfo
        })
          .fontColor('#606162')
      }
      .width('100%')
      .height('100%')
      .padding(16)
      .alignItems(HorizontalAlign.Start)
    }
    .title(this.navDestinationTitle())
    .width('100%')
    .height('100%')
    .onReady((context: NavDestinationContext) => {
      this.pageStack = context.pathStack;
    })
    .onWillHide(() => {
      AppStorage.setOrCreate('tagInfo', {});
    })
  }
}