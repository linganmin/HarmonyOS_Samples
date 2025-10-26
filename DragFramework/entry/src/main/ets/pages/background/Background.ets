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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';
import { BreakpointType } from '../../common/Utils';
import { Constants } from '../../common/Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

@Builder
export function PageBackgroundBuilder() {
  BackgroundDrag();
}

@Entry
@Component
struct BackgroundDrag {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State targetImage: string = '';
  @State primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  @State pixelMap: image.PixelMap | undefined = undefined;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  private context: UIContext = this.getUIContext();

  // [Start BackgroundPixelMapBuilder]
  @Builder
  pixelMapBuilder() {
    Column() {
      Text($r('app.string.background_content'))
        .fontSize('16fp')
        .margin({
          left: '16vp',
          right: '16vp',
          top: '8vp',
          bottom: '8vp'
        })
    }
    .backgroundColor($r('sys.color.comp_background_primary'))
    .borderRadius(16)
  }

  // [End BackgroundPixelMapBuilder]

  // [Start BackgroundGetComponentSnapshot]
  private getComponentSnapshot(): void {
    this.getUIContext().getComponentSnapshot().createFromBuilder(() => {
      this.pixelMapBuilder()
    }, (error: Error, pixmap: image.PixelMap) => {
      if (error) {
        hilog.error(0x0000, TAG, `%{public}s`, error.message);
        return;
      }
      this.pixelMap = pixmap;
    })
  }

  // [End BackgroundGetComponentSnapshot]

  // [Start BackgroundPreDragChange]
  private PreDragChange(preDragStatus: PreDragStatus): void {
    if (preDragStatus == PreDragStatus.ACTION_DETECTING_STATUS) {
      this.getComponentSnapshot();
    }
  }

  // [End BackgroundPreDragChange]

  aboutToDisappear(): void {
    this.pixelMap?.release();
  }

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
            // [Start BackgroundOnDragStart]
            // [Start BackgroundPreDrag]
            // [Start Draging]
            Image($r('app.media.mount'))
            // [StartExclude BackgroundPreDrag]
            // [StartExclude BackgroundOnDragStart]
            // [StartExclude Draging]
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .fitOriginalSize(true)
              .borderRadius(16)
              .draggable(true)
              // [EndExclude BackgroundPreDrag]
              .onPreDrag((status: PreDragStatus) => {
                this.PreDragChange(status);
              })
              // [EndExclude BackgroundOnDragStart]
              // [StartExclude BackgroundPreDrag]
              // [EndExclude Draging]
              .onDragStart(() => {
                let dragItemInfo: DragItemInfo = {
                  pixelMap: this.pixelMap,
                  builder: () => {
                    this.pixelMapBuilder()
                  },
                };
                return dragItemInfo;
              })
              // [StartExclude Draging]
              // [StartExclude BackgroundOnDragStart]
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
            // [EndExclude Draging]
            // [EndExclude BackgroundOnDragStart]
            // [EndExclude BackgroundPreDrag]
            // [End BackgroundPreDrag]
            // [End BackgroundOnDragStart]
            // [End Draging]
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
          Column() {
            Image(this.targetImage)
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .fitOriginalSize(true)
              .constraintSize({ maxWidth: '100%' })
              .borderRadius(16)
          }
          .constraintSize({ maxWidth: '100%' })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .borderRadius(16)
          .allowDrop([uniformTypeDescriptor.UniformDataType.IMAGE])
          .onDrop((event?: DragEvent) => {
            try {
              let dragData: UnifiedData = (event as DragEvent).getData() as UnifiedData;
              if (dragData !== undefined) {
                let records: unifiedDataChannel.UnifiedRecord[] = dragData.getRecords();
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
                    }
                  }
                } else {
                  hilog.info(0x0000, TAG, `%{public}s`, `dragData arr is null`);
                }
              } else {
                hilog.info(0x0000, TAG, `%{public}s`, `dragData is undefined`);
              }
              event?.setResult(DragResult.DRAG_SUCCESSFUL);
            } catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
            }
          })
        }
        .padding({
          left: 16,
          right: 16,
          top: 8,
          bottom: 16
        })
      }
    }
    .title(getStringSync(this.context.getHostContext()!, $r('app.string.background_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}