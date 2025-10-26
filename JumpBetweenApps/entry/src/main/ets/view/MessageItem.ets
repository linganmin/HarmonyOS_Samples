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
import { Message } from '../viewmodel/MessageViewModel';

@Builder
function EmptyBuilder() {}

@Component
export struct MessageItem {
  UIContext = this.getUIContext();

  @Prop message: Message;
  @BuilderParam contentBuilder: () => void = EmptyBuilder;
  private context: common.UIAbilityContext = this.UIContext.getHostContext() as common.UIAbilityContext;

  build() {
    Row() {
      Image($r('app.media.default_avatar'))
        .width(40)
        .height(40)
        .borderRadius(20)
        .margin({ right: 8 })

      Row() {
        this.contentBuilder()
      }
      .constraintSize({ maxWidth: 210 })
      .borderRadius({
        topLeft: 2,
        topRight: 24,
        bottomLeft: 24,
        bottomRight: 24
      })
      .backgroundColor(Color.White)
      .onClick(() => this.message.getCallBack() && this.message.getCallBack()(this.context))
    }
    .justifyContent(FlexAlign.Start)
    .alignItems(VerticalAlign.Top)
  }
}