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

// [Start PromptActionClass_open]
import { PromptActionClass } from '../uitls/PromptActionClass';
import { ComponentContent } from '@kit.ArkUI';

class Params {
  text: string = '';

  constructor(text: string) {
    this.text = text;
  }
}

@Builder
function buildText(params: Params) {
  Column() {
    Row() {
      Text('Title')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
    }
    .width('100%')
    .height(56)
    .justifyContent(FlexAlign.Center)

    Text(params.text)
      .fontSize(14)

    Button('CONFIRM')
      .fontSize(16)
      .fontColor('#0A59F7')
      .backgroundColor(Color.White)
      .onClick(() => {
        PromptActionClass.closeDialog(); // Close customDialog.
      })
      .width('100%')
      .margin({
        top: 8,
        bottom: 16
      })
  }
  .padding({
    left: 24,
    right: 24
  })
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
  .backgroundColor(Color.White)
  .borderRadius(32)
  .margin({ left: 16, right: 16 })
}

@Component
export struct GlobalDialogDecoupledFromThePage {
  @State message: string = 'This is a dialog content.';
  private ctx: UIContext = this.getUIContext();
  private contentNode: ComponentContent<Object> =
    new ComponentContent(this.ctx, wrapBuilder(buildText), new Params(this.message));

  aboutToAppear(): void {
    PromptActionClass.setContext(this.ctx);
    PromptActionClass.setContentNode(this.contentNode);
    PromptActionClass.setOptions({ alignment: DialogAlignment.Center, maskColor: 'rgba(0, 0, 0, 0.2)' });
  }

  aboutToDisappear(): void {
    if (PromptActionClass.contentNode !== null) {
      PromptActionClass.contentNode.dispose(); // release contentNode.
    }
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          Button('OPEN')
            .fontSize(16)
            .width('100%')
            .borderRadius(20)
            .margin({ bottom: 16 })
            .backgroundColor('#0A59F7')
            .onClick(() => {
              PromptActionClass.openDialog(); // Open customDialog.
            })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .padding({
        left: 16,
        right: 16
      })
      .justifyContent(FlexAlign.End)
    }
  }
}
// [End PromptActionClass_open]