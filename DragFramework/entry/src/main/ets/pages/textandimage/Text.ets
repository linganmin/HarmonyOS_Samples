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
import { TextModifier, SubHeader, LengthUnit } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../../common/Constants';
import { common } from '@kit.AbilityKit';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageTextDragBuilder() {
  TextDrag();
}

@Entry
@Component
struct TextDrag {
  @State targetImage: string | Resource | PixelMap | null = '';
  @State targetTextContent: string = '';
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  private primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Start, justifyContent: FlexAlign.SpaceAround }) {
            Text() {
              Span($r('app.string.text_and_image_text_description'))
                .fontSize(16)
                .fontWeight(FontWeight.Normal)
              ImageSpan($rawfile('river.png'))
                .width(50)
                .height(50)
                .verticalAlign(ImageSpanAlignment.CENTER)
                .border({ radius: 8 })
            }
            .padding({
              left: 16,
              top: 8
            })
            .width('100%')
            .onDragEnd((event) => {
              let ret = event.getResult();
              if (ret === 0) {
                hilog.info(0x0000, TAG, `%{public}s`, `enter ret === 0`);
              } else {
                hilog.info(0x0000, TAG, `%{public}s`, `enter ret === 0`);
              }
            })
            .copyOption(CopyOptions.InApp)
          }
          .constraintSize({ maxWidth: '100%' })
          .width('100%')
          .height(175)
          .borderRadius(16)
          .backgroundColor($r('sys.color.comp_background_primary'))

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
          // [Start Text]
          Column() {
            Text() {
              // [StartExclude Text]
              Span(this.targetTextContent)
                .fontSize(16)
                .fontWeight(FontWeight.Normal)
              ImageSpan(this.targetImage)
                .width(50)
                .height(50)
                .verticalAlign(ImageSpanAlignment.CENTER)
                .border({ radius: 8 })
              // [EndExclude Text]
            }
            // [StartExclude Text]
            .padding({
              left: 16,
              top: 8
            })
            .width('100%')

            // [EndExclude Text]
          }
          // [StartExclude Text]
          .width('100%')
          .height(175)
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .allowDrop([uniformTypeDescriptor.UniformDataType.IMAGE,
            uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP,
            uniformTypeDescriptor.UniformDataType.PLAIN_TEXT, uniformTypeDescriptor.UniformDataType.TEXT])
          // [EndExclude Text]
          .onDrop(async (event?: DragEvent) => {
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
                        this.targetImage = fileUriUds.oriUri;
                      }
                      continue;
                    }
                    if (types.includes(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT)) {
                      const plainTextUds =
                        records[i].getEntry(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) as uniformDataStruct.PlainText;
                      this.targetTextContent = plainTextUds.textContent;
                      continue;
                    }
                    if (types.includes(uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP)) {
                      const pixelMapUds =
                        records[i].getEntry(uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP) as uniformDataStruct.PixelMap;
                      this.targetImage = pixelMapUds.pixelMap;
                      continue;
                    }
                  }
                }
                // [StartExclude Text]
                else {
                  hilog.info(0x0000, TAG, 'dragData arr is null');
                }
                // [EndExclude Text]
              }
              // [StartExclude Text]
              else {
                hilog.info(0x0000, TAG, 'dragData arr is undefind');
              }
              // [EndExclude Text]
              event?.setResult(0);
            }
            // [StartExclude Text]
            catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
            }
            // [EndExclude Text]
          })

          // [End Text]
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
    .title(getStringSync(this.context, $r('app.string.Text_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}