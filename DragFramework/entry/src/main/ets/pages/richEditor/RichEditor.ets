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

import { unifiedDataChannel, uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { SubHeader, TextModifier } from '@kit.ArkUI';
import { common } from '@kit.AbilityKit';
import { getStringSync } from '../../utils/StringUtil';

@Builder
export function PageRichEditorBuilder() {
  RichEditorDrag();
}

@Entry
@Component
struct RichEditorDrag {
  @State changeValue: string = '';
  @State submitValue: string = '';
  @State flag: boolean = true;
  @Consume('NavPathStack') pageStack: NavPathStack;
  controller1: RichEditorController = new RichEditorController();
  controller2: RichEditorController = new RichEditorController();
  options: RichEditorOptions = { controller: this.controller2 };
  @State primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private context?: Context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          RichEditor(this.options)
            .onReady(() => {
              this.controller2.addTextSpan(this.context!
                .resourceManager
                .getStringSync($r('app.string.rich_editor_text').id),
                {
                  style: {
                    fontSize: '16fp',
                    lineHeight: 22
                  }
                })
            })
            .borderRadius(16)
            .height('175vp')
            .backgroundColor($r('sys.color.comp_background_primary'))
            .draggable(this.flag)
            .onDragEnd((event) => {
              if (event.getResult() === DragResult.DRAG_SUCCESSFUL) {
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ duration: 100, bottom: '80vp', message: $r('app.string.drag_successfully') });
              } else if (event.getResult() === DragResult.DRAG_FAILED) {
                this.getUIContext()
                  .getPromptAction()
                  .showToast({ duration: 100, bottom: '80vp', message: $r('app.string.drag_failed'), });
              }
            })
            .margin({
              left: '16vp',
              right: '16vp',
              top: '8vp'
            })

          SubHeader({
            primaryTitle: $r('app.string.rich_editor_text_title'),
            primaryTitleModifier: this.primaryModifier
          })
          RichEditor({ controller: this.controller1 })
            .margin({
              left: '16vp',
              right: '16vp'
            })
            .height('175vp')
            .backgroundColor($r('sys.color.comp_background_primary'))
            .borderRadius(16)
            .onDrop((event: DragEvent) => {
              let value: unifiedDataChannel.UnifiedData = event.getData() as unifiedDataChannel.UnifiedData;
              if (value === undefined) {
                return;
              }
              let records = value.getRecords();
              for (let record of records) {
                let types = record.getTypes();
                if (types.includes(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT)) {
                  const plainTextUds =
                    record.getEntry(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) as uniformDataStruct.PlainText;
                  this.controller1.addTextSpan(plainTextUds.textContent, {
                    style: {
                      fontSize: '16fp',
                      lineHeight: 22
                    }
                  });
                  event.setResult(DragResult.DRAG_SUCCESSFUL);
                }
              }
            })
        }
        .alignItems(HorizontalAlign.Start)
        .backgroundColor($r('sys.color.background_secondary'))
        .margin({
          bottom: '16vp'
        })
      }
    }
    .title(getStringSync(this.context!, $r('app.string.rich_editor_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}