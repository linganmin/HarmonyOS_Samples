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

import { common } from '@kit.AbilityKit';
import { unifiedDataChannel, uniformDataStruct, uniformTypeDescriptor } from '@kit.ArkData';
import { TextModifier, SubHeader, LengthUnit } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../../common/Constants';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageRichEditorDragBuilder() {
  RichEditorDrag();
}

@Entry
@Component
struct RichEditorDrag {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private sourceController: RichEditorController = new RichEditorController();
  private targetController: RichEditorController = new RichEditorController();
  private primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  private imageStyle: RichEditorImageSpanStyle = {
    size: [50, 50],
    layoutStyle: {
      borderRadius: 8
    },
    verticalAlign: ImageSpanAlignment.CENTER
  };
  private textStyle: RichEditorTextStyle = {
    fontSize: 16,
    fontWeight: FontWeight.Normal
  };

  // [Start RichEditorReceiveDragData]
  async receiveDragData(event: DragEvent) {
    try {
      let dragData: UnifiedData = (event as DragEvent).getData() as UnifiedData;
      if (dragData !== undefined) {
        let records: Array<unifiedDataChannel.UnifiedRecord> = dragData.getRecords();
        if (records.length > 0) {
          for (let i = 0; i < records.length; i++) {
            let types = records[i].getTypes();
            if (types.includes(uniformTypeDescriptor.UniformDataType.FILE_URI)) {
              const fileUriUds =
                records[i].getEntry(uniformTypeDescriptor.UniformDataType.FILE_URI) as uniformDataStruct.FileUri;
              let typeDescriptor = uniformTypeDescriptor.getTypeDescriptor(fileUriUds.fileType);
              if (typeDescriptor.belongsTo(uniformTypeDescriptor.UniformDataType.IMAGE)) {
                this.targetController.addImageSpan(fileUriUds.oriUri,
                  {
                    imageStyle: this.imageStyle,
                    offset: this.targetController.getCaretOffset()
                  })
              }
              continue;
            }
            if (types.includes(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT)) {
              const plainTextUds =
                records[i].getEntry(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) as uniformDataStruct.PlainText;
              this.targetController.addTextSpan(plainTextUds.textContent,
                {
                  style: this.textStyle,
                  offset: this.targetController.getCaretOffset(),
                })
              continue;
            }
            if (types.includes(uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP)) {
              const pixelMapUds =
                records[i].getEntry(uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP) as uniformDataStruct.PixelMap;
              this.targetController.addImageSpan(pixelMapUds.pixelMap,
                {
                  imageStyle: this.imageStyle,
                  offset: this.targetController.getCaretOffset()
                })
              continue;
            }
          }
        }
        // [StartExclude RichEditorReceiveDragData]
        else {
          hilog.info(0x0000, TAG, 'dragData records is null');
        }
        // [EndExclude RichEditorReceiveDragData]
      }
      // [StartExclude RichEditorReceiveDragData]
      else {
        hilog.info(0x0000, TAG, 'dragData is undefind');
      }
      // [EndExclude RichEditorReceiveDragData]
    }
    // [StartExclude RichEditorReceiveDragData]
    catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
    }
    // [EndExclude RichEditorReceiveDragData]
  }

  // [End RichEditorReceiveDragData]

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          RichEditor({ controller: this.sourceController })
            .height(175)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            .onReady(async () => {
              this.sourceController.addTextSpan(await this.context.resourceManager.getStringValue($r('app.string.text_and_image_text_description').id),
                {
                  style: {
                    fontSize: 16,
                    fontWeight: FontWeight.Normal
                  },
                  paragraphStyle: {
                    textAlign: TextAlign.Start
                  }
                })
              this.sourceController.addImageSpan($rawfile('river.png'),
                {
                  imageStyle: {
                    size: [50, 50],
                    layoutStyle: {
                      borderRadius: 8
                    },
                    verticalAlign: ImageSpanAlignment.CENTER
                  }
                })
            })
          SubHeader({
            primaryTitle: $r('app.string.image_and_text_text_title'),
            primaryTitleModifier: this.primaryModifier,
            contentMargin: {
              start: {
                value: 0,
                unit: LengthUnit.VP
              }
            }
          })
          // [Start RichEditorOnDrop]
          RichEditor({ controller: this.targetController })
          // [StartExclude RichEditorOnDrop]
            .height(175)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            // [EndExclude RichEditorOnDrop]
            .allowDrop([uniformTypeDescriptor.UniformDataType.IMAGE,
              uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP, uniformTypeDescriptor.UniformDataType.TEXT,
              uniformTypeDescriptor.UniformDataType.PLAIN_TEXT])
            .onDrop((event: DragEvent) => {
              try {
                event.setResult(0);
                this.receiveDragData(event);
              } catch (error) {
                const err = error as BusinessError;
                hilog.error(0x0000, TAG, `on drop error, errorCode: ${err.code}, errorMessage: ${err.message}`);
              }
            })
          // [End RichEditorOnDrop]
        }
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 8,
        })
        .backgroundColor($r('sys.color.background_secondary'))
      }
    }
    .title(getStringSync(this.context, $r('app.string.RichEditor_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}