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
* FAQ:Text组件设置maxLines后如何确定文本是否被隐藏
*/

// [Start text_input_example]
@Entry
@Component
struct TextInputExample {
  @State text: string = '';
  @State truncatedHint: string = "Text not truncated";
  controller: TextInputController = new TextInputController();

  build() {
    Column() {
      TextInput({ text: this.text, placeholder: 'input your word...', controller: this.controller })
        .placeholderColor(Color.Grey)
        .placeholderFont({ size: 14, weight: 400 })
        .caretColor(Color.Blue)
        .width(400)
        .height(40)
        .margin(20)
        .fontSize(14)
        .fontColor(Color.Black)
        .onChange((value: string) => {
          this.text = value;
          let textSizeShow1: SizeOptions = this.getUIContext().getMeasureUtils().measureTextSize({
            textContent: this.text,
            constraintWidth: 100,
            fontSize: 14,
            overflow: TextOverflow.Ellipsis,
            maxLines: 2
          })
          let textSizeShow2: SizeOptions = this.getUIContext().getMeasureUtils().measureTextSize({
            textContent: this.text + " ",
            constraintWidth: 100,
            fontSize: 14,
            overflow: TextOverflow.Ellipsis,
            maxLines: 2000000
          })
          console.log("textSizeShow1.height=" + textSizeShow1.height);
          console.log("textSizeShow2.height=" + textSizeShow2.height);

          if (textSizeShow2 && textSizeShow1 && textSizeShow2?.height && textSizeShow1?.height && (textSizeShow2?.height > textSizeShow1?.height)) {
            console.log("Text truncated");
            this.truncatedHint = "Text truncated";
          } else {
            console.log("Text not truncated");
            this.truncatedHint = "Text not truncated";
          }
        })
      Text(this.text)
        .maxLines(2)
        .width(100)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .border({ width: 1 })
        .minFontSize(14)
        .maxFontSize(24)
      Text(this.truncatedHint)

    }.width('100%')
  }
}
// [End text_input_example]