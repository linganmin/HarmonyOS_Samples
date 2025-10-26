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
* FAQ:如何将内容直接复制到剪贴板
*/

// [Start copy_text]
import { pasteboard } from '@kit.BasicServicesKit';

@Entry
@Component
struct CopyText {
  private textContent: string = 'Copy me';

  aboutToAppear(): void {
    AppStorage.setOrCreate('context', this.getUIContext());
  }

  build() {
    Column() {
      Text(this.textContent)
        .fontSize(20)
        .borderRadius(9)
        .borderWidth(1)
        .padding({
          left: 8,
          right: 8
        })
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontWeight(FontWeight.Medium)
        .opacity($r('sys.float.ohos_id_alpha_content_secondary'))
        .onClick(() => copyText(this.textContent))
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignSelf(ItemAlign.Center)
  }
}

/*
 * Copy the text to the system clipboard
 * @param text - text
 * @returns void
 */
function copyText(text: string) {
  const uiContext: UIContext | undefined = AppStorage.get('context');
  // Create clipboard content object
  const pasteboardData = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
  // Get system clipboard object
  const systemPasteboard = pasteboard.getSystemPasteboard();
  systemPasteboard.setData(pasteboardData); // Put data into clipboard
  systemPasteboard.getData().then((data) => { // Read clipboard content
    if (data) {
      uiContext?.getPromptAction().showToast({ message: 'Copy succeeded' });
    } else {
      uiContext?.getPromptAction().showToast({ message: 'Copy failed' });
    }
  })
}
// [End copy_text]