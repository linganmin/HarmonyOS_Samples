/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import testNapi from 'libentry.so';
import { NodeContent } from '@kit.ArkUI';
import { pasteboard } from '@kit.BasicServicesKit'

@Entry
@Component
struct Index {
  private nodeContent: Content = new NodeContent();
  controllers: RichEditorController = new RichEditorController();
  options: RichEditorOptions = { controller: this.controllers }

  build() {
    Row() {
      Column() {
        ContentSlot(this.nodeContent)
        Text("测试CAPI，测试前下面框中先粘贴一次").fontSize(8)
        RichEditor(this.options)
          .borderWidth(1)
          .borderColor(Color.Red)
          .width("100%")
          .height(50)
          .enableDataDetector(true)
          // .backgroundColor(Color.Gray)
          .selectedBackgroundColor(Color.Gray)
        Button("点击测试CAPI").fontSize(8)
          .onClick(() =>{
            let sysBoard = pasteboard.getSystemPasteboard()
            pasteboard.MIMETYPE_TEXT_HTML
            try {
              let result: boolean = sysBoard.hasDataType("openharmony.styled-string");
              console.info(`zyx Succeeded in checking the DataType. Result: ${result}`);
            } catch (err) {
              console.error('zyx Failed to check the DataType. Cause:' + err.message);
            };
            sysBoard.getData((err, data) => { // MulitTypeRecord.
              let count = data.getRecordCount()  // "1234[图]" ,  record1 : {plainText : "1234",  openharmony.styled-string : arrayBuffer}, mimeType = "plainText"
              //              record2 {UriText : "/../../.png, openharmony.styled-string : arrayBuffer"}, mimeType = "UriText"
              for (let i = 0; i < count; i++) {
                const record = data.getRecord(i)
                let  mimeTypes = data.getMimeTypes(); // 获得 所有record 的mimeType 集合。  // text, uri, arraybuffer
                let type = record.mimeType;
                let types = new Array(pasteboard.MIMETYPE_TEXT_PLAIN,pasteboard.MIMETYPE_TEXT_URI,pasteboard.MIMETYPE_PIXELMAP,"openharmony.styled-string")
                let validTypes = record.getValidTypes(types) // 获取record1 里的所有数据的样式集合。
                if (validTypes.includes("openharmony.styled-string")) {
                  let spanString = record.getData("openharmony.styled-string")  // spanString instanseOf Promise<ValueType>,
                  // type ValueType = string | image.PixelMap | Want | ArrayBuffer;
                  spanString.then((value) => {
                    // value ：  type ValueType = string | image.PixelMap | Want | ArrayBuffer;
                    let buffer = value as ArrayBuffer;
                    // buffer : ArrayBuffer
                    let length = buffer.byteLength
                    let uint8Array = new Uint8Array(buffer); // 从剪切板中获取属性字符串的序列化的字节数组。 uint8Array -> 属性字符串
                    console.info(`zyx Succeeded obtain buffer ` + length);
                    testNapi.createUintNativeNode(uint8Array);  // napi ，将JS侧数据传到C侧.
                  })
                }
              }
            })
          })
      }
      .width('100%')
    }
    .height('100%')
  }

  aboutToAppear(): void {
    testNapi.createNativeNode(this.nodeContent);
  }
}
