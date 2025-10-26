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

import { fileUriService } from '@kit.ScenarioFusionKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const COL_ROW_CONFIG: GridRowOptions = {
  columns: 12,
  gutter: { x: 5, y: 20 },
  direction: GridRowDirection.Row
};

const GRID_COL_BORDER: BorderOptions = {
  color: 'rgba(0, 0, 0, 0.6)',
  width: { left: 1 ,right: 1 }
};

@Entry
@Component
struct ConvertFileUrisExamplePage {
  // FilePath Can be Media URI, Media URI ID or File Path.
  // 100 indicates the URI ID, Same as content://media/external/images/media/100.
  // /storage/emulated/0/Pictures/test.gif indicates File Path of test.gif.
  @State filePath: string = '100,/storage/emulated/0/Pictures/test.gif';
  @State convertFileUrisResults: Array<fileUriService.FileUriResult> = [];

  build() {
    Column() {
      Text('convertFileUris')
        .fontSize(30)
        .fontWeight(700)
        .fontColor(Color.Black)
        .padding({
          right: '16vp',
          bottom: '8vp',
          top: '56vp'
        })
        .width('100%')
      Text('File Path')
        .fontSize(14)
        .fontWeight(500)
        .fontColor('rgba(0, 0, 0, 0.6)')
        .padding({
          top: '28vp',
          bottom: '8vp',
          left: '12vp'
        })
        .width('100%')
      TextInput({
        text: this.filePath,
        placeholder: 'Combine multiple paths with commas, eg:pathA,pathB'
      })
        .placeholderFont({
         size: 16,
         weight: 400
        })
        .placeholderColor(Color.Gray)
        .onChange((val: string) => {
          this.filePath = val;
        })
        .width('100%')
        .height('40vp')
        .backgroundColor(Color.White)

      Button('convertFileUris')
        .type(ButtonType.Capsule)
        .margin(16)
        .backgroundColor('#0A59F7')
        .width('100%')
        .onClick(() => {
          let arr: Array<string> = this.filePath?.split(',')?.filter(str => str !== '');
          // Calling convertFileUris to convert uris.
          fileUriService.convertFileUris(arr).then((result) => {
            hilog.info(0x0000, 'testTag', 'succeeded in converting file uris');
            // If input path exists, targetUri in the result will be the converted uri.
            // Otherwise targetUri will same as the input path, targetType will be UNKNOWN.
            this.convertFileUrisResults = result;
          }).catch((err: BusinessError) => {
            hilog.error(0x0000, 'testTag', `converting file uris error: %{public}d, %{public}s`, err.code, err.message);
          });
        })


      if (this.convertFileUrisResults.length) {
        Text('Result')
          .fontSize(14)
          .fontWeight(500)
          .fontColor('rgba(0, 0, 0, 0.6)')
          .padding({
            top: '28vp',
            bottom: '8vp',
            left: '12vp'
          })
          .height(56)
          .width('100%')
        Column() {
          GridRow(COL_ROW_CONFIG) {
            GridCol({
              span: 4
            }) {
              Text('sourceUri')
                .fontSize(16)
                .fontWeight(700)
                .fontColor(Color.Black)
                .padding({
                  top: '10vp',
                  left: '16vp',
                })
                .width('100%')
            }
            GridCol({
              span: 4
            }) {
              Text('targetUri')
                .fontSize(16)
                .fontWeight(700)
                .fontColor(Color.Black)
                .padding({
                  top: '10vp',
                  bottom: '10vp',
                  right:' 10vp',
                  left: '16vp',
                })
                .width('100%')
            }
            .border(GRID_COL_BORDER)
            GridCol({
              span: 4
            }) {
              Text('targetType')
                .fontSize(16)
                .fontWeight(700)
                .fontColor(Color.Black)
                .padding({
                  top: '10vp',
                  bottom: '10vp',
                  left: '12vp',
                })
                .width('100%')
            }
          }
          .border({
            color: Color.Gray,
            width: 1
          })
          ForEach(this.convertFileUrisResults, (item: fileUriService.FileUriResult) => {
            GridRow(COL_ROW_CONFIG) {
              GridCol({
                span: 4
              }) {
                Text(item.sourceUri)
                  .fontSize(16)
                  .fontWeight(400)
                  .fontColor('rgba(0, 0, 0, 0.6)')
                  .lineHeight(19)
                  .padding({
                    top: '10vp',
                    right: '10vp',
                    bottom: '10vp',
                    left: '16vp',
                  })
                  .width('100%')
              }
              GridCol({
                span: 4
              }) {
                Text(item.targetUri)
                  .fontSize(16)
                  .fontWeight(400)
                  .fontColor('rgba(0, 0, 0, 0.6)')
                  .lineHeight(19)
                  .padding({
                    top: '10vp',
                    bottom: '10vp',
                    left: '16vp',
                    right: '10vp',
                  })
                  .width('100%')
              }
              .border(GRID_COL_BORDER)
              GridCol({
                span: 4
              }) {
                Text(String(item.targetType))
                  .fontSize(16)
                  .fontWeight(400)
                  .fontColor('rgba(0, 0, 0, 0.6)')
                  .lineHeight(19)
                  .padding({
                    top: '10vp',
                    bottom: '10vp',
                    left: '12vp',
                  })
                  .width('100%')
              }
            }
            .border({
              color: Color.Gray,
              width: { left: 1, right: 1, bottom: 1 }
            })
          }, (item: fileUriService.FileUriResult, index) => {
            return String(index) + item.sourceUri;
          })
        }
        .width('100%')
        .backgroundColor($r('sys.color.comp_background_list_card'))
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F1F3F5')
    .padding({
      left:'16vp',
      right:'16vp',
      top: '56vp'
    })
  }
}