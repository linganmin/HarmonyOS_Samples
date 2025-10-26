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

import { uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { TextModifier, SubHeader } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageTextInputBuilder() {
  TextInputDrag();
}

@Entry
@Component
struct TextInputDrag {
  @State dragStartContent: string = '';
  @State dropContent: ResourceStr = '';
  @State description: string = '';
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  @StorageProp('topRectHeight') topRectHeight: number = 0;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          TextInput({ placeholder: 'Please input words...' })
            .fontSize('16fp')
            .backgroundColor($r('sys.color.comp_background_primary'))
            .copyOption(CopyOptions.InApp)
            .borderRadius(16)
            .width('100%')
            .constraintSize({ maxWidth: '100%' })
            .height('50vp')
            .draggable(true)
            .margin({
              left: '16vp',
              right: '16vp',
              top: '8vp'
            })

          SubHeader({
            primaryTitle: $r('app.string.textarea_text_title'),
            primaryTitleModifier: this.primaryModifier
          })
          // [Start onDropExample]
          Column() {
            Text(this.dropContent)
              // [StartExclude onDropExample]
              .fontSize('16fp')
              .lineHeight(22)
              .width('100%')
              .constraintSize({ maxWidth: '100%' })
              .margin({
                left: '16vp',
                right: '16vp',
                top: '8vp',
                bottom: '8vp'
              })
              .textAlign(TextAlign.Start)
            // [EndExclude onDropExample]
          }
          // [StartExclude onDropExample]
          .height('175vp')
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          // [EndExclude onDropExample]
          .allowDrop([uniformTypeDescriptor.UniformDataType.TEXT,
            uniformTypeDescriptor.UniformDataType.PLAIN_TEXT])
          .onDrop((event: DragEvent) => {
            try {
              let dragData = event.getData();
              let records = dragData.getRecords();
              for (let record of records) {
                let types = record.getTypes();
                if (types.includes(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT)) {
                  const plainTextUds =
                    record.getEntry(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) as uniformDataStruct.PlainText;
                  this.dropContent = plainTextUds.textContent;
                  event.setResult(DragResult.DRAG_SUCCESSFUL);
                }
              }
            }
            // [StartExclude onDropExample]
            catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
            }
            // [EndExclude onDropExample]
          })
          // [End onDropExample]
          .margin({
            left: '16vp',
            right: '16vp'
          })
        }
        .alignItems(HorizontalAlign.Center)
        .backgroundColor($r('sys.color.background_secondary'))
        .margin({
          bottom: '16vp'
        })
      }
    }
    .title(getStringSync(this.getUIContext().getHostContext()!, $r('app.string.text_input_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}