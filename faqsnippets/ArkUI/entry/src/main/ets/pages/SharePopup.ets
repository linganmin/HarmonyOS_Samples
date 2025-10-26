/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

/*
* FAQ:如何使用自定义弹窗实现分享弹窗
*/

// [Start custom_share_dialog]
import { ComponentContent } from '@kit.ArkUI';

let componentContent: ComponentContent<Params> | undefined = undefined;

class Params {
  applicationSharings: string[] = [];
  sharings: string[] = [];

  constructor(applicationSharings: string[], sharings: string[] = []) {
    this.applicationSharings = applicationSharings;
    this.sharings = sharings;
  }
}

const context = AppStorage.get("context") as UIContext

@Builder
function  buildText($$: Params) {
  Column() {
    Text('share')
    Grid() {
      ForEach($$.applicationSharings, (item: string, index) => {
        GridItem() {
          Column() {
            Image($r('app.media.startIcon'))
              .height(50)
              .width(50)
            Text(item)
              .fontSize(10)
          }
        }
      })
    }
    .height(100)
    .rowsGap(20)
    .columnsGap(20)
    .scrollBar(BarState.Off)
    .rowsTemplate('1fr')

    Grid() {
      ForEach($$.sharings, (item: string, index) => {
        GridItem() {
          Column() {
            Image($r('app.media.startIcon'))
              .height(50)
              .width(50)
            Text(item)
              .fontSize(10)
          }
        }
      })
    }
    .height(100)
    .rowsGap(20)
    .columnsGap(20)
    .scrollBar(BarState.Off)
    .rowsTemplate('1fr')

    Button('Cancel')
      .width('100%')
      .fontColor(Color.Black)
      .backgroundColor(Color.White)
      .onClick(() => {
        context.getPromptAction().closeCustomDialog(componentContent);
      })
  }
  .backgroundColor('#FFF0F0F0')
  .width('90%')
  .height('30%')
  .borderRadius(10)
}

@Entry
@Component
struct CustomShareDialog {
  @State applicationSharings: string[] =
    ['share1', 'share2', 'share3', 'share4', 'share5', 'share6', 'share7', 'share8'];
  @State sharings: string[] = ['share1', 'share2', 'share3', 'share4', 'share5', 'share6', 'share7', 'share8'];


  build() {
    Row() {
      Column() {
        Button('click me')
          .onClick(() => {
            let contentNode = new ComponentContent(this.getUIContext(), wrapBuilder(buildText),
              new Params(this.applicationSharings, this.sharings));
            componentContent = contentNode;
            this.getUIContext().getPromptAction().openCustomDialog(contentNode);
          })
      }
      .width('100%')
      .height('100%')
    }
    .height('100%')
  }
}
// [End custom_share_dialog]