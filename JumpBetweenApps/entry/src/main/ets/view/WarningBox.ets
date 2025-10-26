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

import { common } from '@kit.AbilityKit';
import { pullUpSystemSetting } from '../viewmodel/MessageViewModel';

@Component
export struct WarningBox {
  UIContext = this.getUIContext();

  private context: common.UIAbilityContext = this.UIContext.getHostContext() as common.UIAbilityContext;

  build() {
    Row() {
      Image($r('app.media.warning'))
        .width(19)
        .height(19)
        .margin({ right: 8.5 })
      Text($r('app.string.no_network'))
        .fontColor('#E84026')
        .fontSize(16)
        .fontWeight(500)
        .lineHeight(21)
        .letterSpacing(0)
        .textAlign(TextAlign.Start)
        .width('80%')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .borderRadius(16)
    .backgroundColor('#FCE3DF')
    .size({ width: 'calc(100% - 24vp)', height: 56 })
    .justifyContent(FlexAlign.Center)
    .onClick(() => {
      pullUpSystemSetting(this.context)
    })
  }
}