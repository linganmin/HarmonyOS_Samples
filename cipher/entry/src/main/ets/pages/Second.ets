/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { Decrypt } from '../common/Decrypt';
import { Encrypt } from '../common/Encrypt';

@Entry
@Component
struct Second {
  private params: rouTmp = this.getUIContext().getRouter().getParams() as rouTmp;
  private flag: boolean = this.params.flag;

  build() {
    Column() {
      Row() {
        Row() {
          Image($r('app.media.left'))
            .objectFit(ImageFit.Contain)
            .width('10%')
          Text($r('app.string.back'))
            .fontSize(20)
            .textAlign(TextAlign.End)
            .fontColor(Color.White)
        }
        .layoutWeight(1)
        .onClick(() => {
          this.getUIContext().getRouter().back();
        })
        .id('back')

        Text(this.flag ? $r('app.string.encrypt') : $r('app.string.decrypt'))
          .fontSize(20)
          .fontColor(Color.White)
          .textAlign(TextAlign.Start)
          .margin({ right: '5%' })
          .id('encryptAndDecrypt')

      }
      .height('6%')
      .width('100%')
      .padding({ left: 16 })
      .backgroundColor('#0D9FFB')
      .constraintSize({ minHeight: 50 })

      if (this.flag) {
        Encrypt()
      } else {
        Decrypt()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F1F1')
  }
}

class rouTmp {
  flag: boolean = true;
}