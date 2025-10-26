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
* FAQ:如何设置customspan不同位置的点击事件
*/

// [Start custom_span]
@Entry
@Component
struct Index {
  controller: RichEditorController = new RichEditorController();
  option: RichEditorOptions = { controller: this.controller };

  @Builder
  comment() {
    Row() {
      Text() {
        Span('123123123')
        ImageSpan($r('app.media.startIcon')).width(20).height(20)
        Span('ggggggggggggggggggggggxxxxxxxxxxxxxxxxxxxxxxx')
      }
      .maxLines(1)
      .wordBreak(WordBreak.BREAK_ALL)
      .textOverflow({ overflow: TextOverflow.Ellipsis })
      .constraintSize({
        maxWidth: '90%'
      })

      Image($r('app.media.startIcon'))
        .width(25)
        .height(25)
        .onClick(() => {
          this.getUIContext().getPromptAction().showToast({
            message: 'Click to delete'
          })
        })
    }
    .width('100%')
    .align(Alignment.Center)
    .padding({
      top: 5,
      bottom: 5
    })
    .borderRadius(20)
    .backgroundColor(Color.Gray)
  }

  build() {
    Column() {
      Column() {
        RichEditor(this.option)
          .onReady(() => {
            this.controller.addBuilderSpan(() => this.comment())
          })
          .borderWidth(1)
          .borderColor(Color.Green)
          .width('100%')
          .height('30%')
      }
      .borderWidth(1)
      .borderColor(Color.Red)
      .width('100%')
      .height('70%')
    }
  }
}
// [End custom_span]