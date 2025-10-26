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
export function PageTextAreaBuilder() {
  TextAreaDrag();
}

@Entry
@Component
struct TextAreaDrag {
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
          TextArea({ placeholder: 'Please input words...' })
            .fontSize('16fp')
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius(16)
            .copyOption(CopyOptions.InApp)
            .width('100%')
            .constraintSize({ maxWidth: '100%' })
            .height('155vp')
            .draggable(true)
            .margin({
              left: '16vp',
              right: '16vp',
              top: '16vp'
            })
            .padding({
              top: '8vp',
              bottom: '8vp',
              left: '16vp',
              right: '16vp'
            })
            .lineHeight(22)

          SubHeader({
            primaryTitle: $r('app.string.textarea_text_title'),
            primaryTitleModifier: this.primaryModifier
          })
          Column() {
            Text(this.dropContent)
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
          }
          .height('175vp')
          .width('100%')
          .constraintSize({ maxWidth: '100%' })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
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
            } catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
            }
          })
          .margin({
            left: '16vp',
            right: '16vp'
          })
        }
        .backgroundColor($r('sys.color.background_secondary'))
        .margin({
          bottom: '16vp'
        })
      }
    }
    .title(getStringSync(this.getUIContext().getHostContext()!, $r('app.string.textarea_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}