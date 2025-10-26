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
import { LengthUnit, SubHeader, TextModifier } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { textRecognition } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../../common/Constants';
import { BreakpointType } from '../../common/Utils';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageAIRecognitionBuilder() {
  AIRecognitionDrag();
}

@Entry
@Component
struct AIRecognitionDrag {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State textContent: string = '';
  @State primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  private context: UIContext = this.getUIContext();

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
            Image($r('app.media.architecture'))
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .fitOriginalSize(true)
              .borderRadius(16)
              .draggable(true)
              .onDragEnd((event) => {
                if (event.getResult() === DragResult.DRAG_SUCCESSFUL) {
                  this.context.getPromptAction().showToast({
                    duration: 100,
                    bottom: '80vp',
                    message: $r('app.string.drag_successfully')
                  });
                } else if (event.getResult() === DragResult.DRAG_FAILED) {
                  this.context.getPromptAction()
                    .showToast({ duration: 100, bottom: '80vp', message: $r('app.string.drag_failed') });
                }
              })
          }

          SubHeader({
            primaryTitle: $r('app.string.area_can_drag'),
            primaryTitleModifier: this.primaryModifier,
            contentMargin: {
              start: {
                value: 0,
                unit: LengthUnit.VP
              }
            }
          })
          // [Start AIAllowDrop]
          // [Start AIonDropGetData]
          // [Start AIcreatePixelMap]
          // [Start AIrecognizeText]
          Column() {
            Text(this.textContent)
            // [StartExclude AIAllowDrop]
            // [StartExclude AIonDropGetData]
            // [StartExclude AIcreatePixelMap]
            // [StartExclude AIrecognizeText]
              .fontSize('16fp')
              .lineHeight(22)
              .width('100%')
              .align(Alignment.TopStart)
              .padding({
                top: '8vp',
              })
            // [EndExclude AIonDropGetData]
            // [EndExclude AIAllowDrop]
            // [StartExclude AIcreatePixelMap]
            // [EndExclude AIrecognizeText]
          }
          // [StartExclude AIAllowDrop]
          // [StartExclude AIonDropGetData]
          // [StartExclude AIcreatePixelMap]
          // [StartExclude AIrecognizeText]
          .backgroundColor($r('sys.color.comp_background_primary'))
          .width('100%')
          .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
          .constraintSize({ maxWidth: '100%' })
          // [EndExclude AIAllowDrop]
          .allowDrop([uniformTypeDescriptor.UniformDataType.IMAGE])
          // [StartExclude AIAllowDrop]
          // [EndExclude AIonDropGetData]
          // [EndExclude AIcreatePixelMap]
          // [EndExclude AIrecognizeText]
          .onDrop(async (event?: DragEvent) => {
            try {
              // [StartExclude AIcreatePixelMap]
              // [StartExclude AIrecognizeText]
              let dragData: UnifiedData = (event as DragEvent).getData() as UnifiedData;
              if (dragData === undefined) {
                hilog.info(0x0000, TAG, `%{public}s`, `ondrop undefined data`);
                return;
              }
              let records: unifiedDataChannel.UnifiedRecord[] = dragData.getRecords();
              // [StartExclude AIonDropGetData]
              // [EndExclude AIcreatePixelMap]
              // [EndExclude AIrecognizeText]
              for (let i = 0; i < records.length; i++) {
                let types = records[i].getTypes();
                if (types.includes(uniformTypeDescriptor.UniformDataType.FILE_URI)) {
                  // [StartExclude AIrecognizeText]
                  const fileUriUds =
                    records[i].getEntry(uniformTypeDescriptor.UniformDataType.FILE_URI) as uniformDataStruct.FileUri;
                  let typeDescriptor = uniformTypeDescriptor.getTypeDescriptor(fileUriUds.fileType);
                  // [EndExclude AIrecognizeText]
                  if (typeDescriptor.belongsTo(uniformTypeDescriptor.UniformDataType.IMAGE)) {
                    // [StartExclude AIrecognizeText]
                    const resourceReg = new RegExp('resource');
                    // [EndExclude AIrecognizeText]
                    if (resourceReg.test(fileUriUds.oriUri)) {
                      // [StartExclude AIrecognizeText]
                      const numberReg = new RegExp('[0-9]+');
                      let idArray = fileUriUds.oriUri.match(numberReg);
                      // [EndExclude AIrecognizeText]
                      if (idArray !== null) {
                        // [StartExclude AIrecognizeText]
                        let id = idArray[0];
                        let drawableDescriptor =
                          this.context.getHostContext()!.resourceManager.getDrawableDescriptor(Number(id), 0, 1);
                        let pixelMapInit = drawableDescriptor.getPixelMap() as image.PixelMap;
                        let imageHeight = pixelMapInit.getImageInfoSync().size.height;
                        let imageWidth = pixelMapInit.getImageInfoSync().size.width;
                        const readBuffer: ArrayBuffer = new ArrayBuffer(imageHeight * imageWidth * 4);
                        pixelMapInit.readPixelsToBufferSync(readBuffer);
                        let opts: image.InitializationOptions = {
                          editable: true,
                          size: { height: imageHeight, width: imageWidth },
                          srcPixelFormat: pixelMapInit.getImageInfoSync().pixelFormat,
                          pixelFormat: 3,
                          alphaType: pixelMapInit.getImageInfoSync().alphaType,
                          scaleMode: 0
                        };
                        let pixelMap: image.PixelMap = image.createPixelMapSync(readBuffer, opts);
                        // [EndExclude AIrecognizeText]
                        // [StartExclude AIcreatePixelMap]
                        let visionInfo: textRecognition.VisionInfo = { pixelMap: pixelMap };
                        let data = await textRecognition.recognizeText(visionInfo);
                        let recognitionString = data.value;
                        this.textContent = recognitionString;
                        // [EndExclude AIcreatePixelMap]
                      }
                    }
                  }
                }
              }
              // [EndExclude AIonDropGetData]
            } catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `onDrop error, error code: ${err.code}, errorMessage: ${err.message}`);
            }
          })
          // [End AIrecognizeText]
          // [EndExclude AIAllowDrop]
          // [End AIcreatePixelMap]
          // [End AIAllowDrop]
          // [End AIonDropGetData]
          .borderRadius(16)
        }
        .padding({
          top: '8vp',
          left: '16vp',
          right: '16vp',
          bottom: '16vp'
        })
      }
    }
    .title(getStringSync(this.context.getHostContext()!, $r('app.string.ai_recognition_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}