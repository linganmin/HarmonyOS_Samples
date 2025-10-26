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
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Sample_DragFramework]';

enum DROP_AREA {
  PIXELMAP_AREA,
  URI_AREA
};

@Builder
export function PageMultiEntryDragBuilder() {
  MultiEntryDrag();
}
;

@Entry
@Component
struct MultiEntryDrag {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  private primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;
  private sourceController: RichEditorController = new RichEditorController();
  private targetController1: RichEditorController = new RichEditorController();
  private targetController2: RichEditorController = new RichEditorController();
  private originImage: Resource | string | null = $rawfile('river.png');
  private unifiedData: unifiedDataChannel.UnifiedData = new unifiedDataChannel.UnifiedData();
  private selectedStartIndex: number = -1;
  private selectedEndIndex: number = -1;
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

  // [Start MultiEntryBuildUnifiedRecords]
  buildUnifiedRecords(selection: RichEditorSelection) {
    try {
      selection.spans.forEach(async (item) => {
        if (typeof (item as RichEditorImageSpanResult)['imageStyle'] != 'undefined') {
          let originImageUri = this.getOriginImageUri();
          const imageData: uniformDataStruct.FileUri = {
            uniformDataType: 'general.file-uri',
            oriUri: originImageUri,
            fileType: 'general.image'
          }
          const unifiedRecord =
            new unifiedDataChannel.UnifiedRecord(uniformTypeDescriptor.UniformDataType.FILE_URI, imageData);
          let createdPixelMap = this.getOriginPixelMap();
          if (createdPixelMap) {
            let pixelMap: uniformDataStruct.PixelMap = {
              uniformDataType: 'openharmony.pixel-map',
              pixelMap: createdPixelMap,
            }
            unifiedRecord.addEntry(uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP, pixelMap);
            this.unifiedData.addRecord(unifiedRecord);
          }
          // [StartExclude MultiEntryBuildUnifiedRecords]
          else {
            hilog.info(0x0000, TAG, 'pixelMap is null');
          }
          // [EndExclude MultiEntryBuildUnifiedRecords]
        } else {
          if (typeof (item as RichEditorTextSpanResult)['value'] != 'undefined') {
            const selectedText = this.getSelectedText(item as RichEditorTextSpanResult);
            const textData: uniformDataStruct.PlainText = {
              uniformDataType: 'general.plain-text',
              textContent: selectedText
            }
            const unifiedRecord =
              new unifiedDataChannel.UnifiedRecord(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT, textData);
            this.unifiedData.addRecord(unifiedRecord);
          }
        }
      })
    }
    // [StartExclude MultiEntryBuildUnifiedRecords]
    catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
    }
    // [EndExclude MultiEntryBuildUnifiedRecords]
  }

  // [End MultiEntryBuildUnifiedRecords]

  // [Start MultiEntryGetOriginImageUri]
  getOriginImageUri(): string {
    let filePath = this.context.filesDir + '/river.png';
    try {
      let data = this.context.resourceManager.getRawFdSync('river.png');
      let dest = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      let bufferSize = data.length as number;
      let buf = new ArrayBuffer(bufferSize);
      fileIo.readSync(data.fd, buf, { offset: data.offset, length: bufferSize });
      fileIo.writeSync(dest.fd, buf, { offset: 0, length: bufferSize });
      fileIo.close(dest.fd).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `getOriginImageUri failed. code=${err.code}, message=${err.message}`);
      });
      this.context.resourceManager.closeRawFd('river.png');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `getOriginImageUri failed. code=${err.code}, message=${err.message}`);
    }
    const originImageUri = fileUri.getUriFromPath(filePath);
    return originImageUri;
  }

  // [End MultiEntryGetOriginImageUri]

  // [Start MultiEntryGetOriginPixelMap]
  getOriginPixelMap(): PixelMap | undefined {
    try {
      let data = this.context.resourceManager.getRawFileContentSync('river.png');
      let arrayBuffer = data.buffer.slice(0);
      let imageSource: image.ImageSource = image.createImageSource(arrayBuffer);
      let value = imageSource.getImageInfoSync();
      let opts: image.DecodingOptions = {
        editable: true,
        desiredSize: {
          height: value.size.height,
          width: value.size.width
        }
      };
      let pixelMap = imageSource.createPixelMapSync(opts);
      return pixelMap;
    }
    // [StartExclude MultiEntryGetOriginPixelMap]
    catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
      return undefined;
    }
    // [EndExclude MultiEntryGetOriginPixelMap]
  }

  // [End MultiEntryGetOriginPixelMap]

  // [Start MultiEntryGetSelectedText]
  getSelectedText(item: RichEditorTextSpanResult): string {
    const textStart: number = item.spanPosition.spanRange[0];
    const textEnd: number = item.spanPosition.spanRange[1];
    let textSelected: string = '';
    if (textStart >= this.selectedStartIndex) {
      const begin = 0;
      const end = Math.min(textEnd, this.selectedEndIndex) - textStart;
      textSelected = item.value.substring(begin, end);
    } else {
      const begin = this.selectedStartIndex - textStart;
      const end = Math.min(this.selectedEndIndex, textEnd) - textStart;
      textSelected = item.value.substring(begin, end);
    }
    return textSelected;
  }

  // [End MultiEntryGetSelectedText]

  // [Start MultiEntryReceiveDragData]
  receiveDragData(event: DragEvent, area: DROP_AREA) {
    try {
      let dragData: UnifiedData = (event as DragEvent).getData() as UnifiedData;
      if (dragData !== undefined) {
        let records: Array<unifiedDataChannel.UnifiedRecord> = dragData.getRecords();
        if (records.length > 0) {
          for (let i = 0; i < records.length; i++) {
            let types = records[i].getTypes();
            if (area === DROP_AREA.URI_AREA) {
              if (types.includes(uniformTypeDescriptor.UniformDataType.FILE_URI)) {
                const fileUriUds =
                  records[i].getEntry(uniformTypeDescriptor.UniformDataType.FILE_URI) as uniformDataStruct.FileUri;
                let typeDescriptor = uniformTypeDescriptor.getTypeDescriptor(fileUriUds.fileType);
                if (typeDescriptor.belongsTo(uniformTypeDescriptor.UniformDataType.IMAGE)) {
                  let targetImage = fileUriUds.oriUri;
                  this.targetController2.addImageSpan(targetImage,
                    {
                      imageStyle: this.imageStyle,
                      offset: this.targetController2.getCaretOffset()
                    })
                }
                continue;
              }
              if (types.includes(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT)) {
                const plainTextUds =
                  records[i].getEntry(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) as uniformDataStruct.PlainText;
                this.targetController2.addTextSpan(plainTextUds.textContent,
                  {
                    style: this.textStyle,
                    offset: this.targetController2.getCaretOffset()
                  })
                continue;
              }
            } else {
              if (types.includes(uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP)) {
                const pixelMapUds =
                  records[i].getEntry(uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP) as uniformDataStruct.PixelMap;
                let targetImage = pixelMapUds.pixelMap;
                this.targetController1.addImageSpan(targetImage,
                  {
                    imageStyle: this.imageStyle,
                    offset: this.targetController1.getCaretOffset()
                  })
                continue;
              }
              if (types.includes(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT)) {
                const plainTextUds =
                  records[i].getEntry(uniformTypeDescriptor.UniformDataType.PLAIN_TEXT) as uniformDataStruct.PlainText;
                this.targetController1.addTextSpan(plainTextUds.textContent,
                  {
                    style: this.textStyle,
                    offset: this.targetController1.getCaretOffset()
                  })
                continue;
              }
            }
          }
        }
        // [StartExclude MultiEntryReceiveDragData]
        else {
          hilog.info(0x0000, TAG, 'dragData records is null');
        }
        // [EndExclude MultiEntryReceiveDragData]
      }
      // [StartExclude MultiEntryReceiveDragData]
      else {
        hilog.info(0x0000, TAG, 'dragData is undefined');
      }
      // [EndExclude MultiEntryReceiveDragData]
      event.setResult(DragResult.DRAG_SUCCESSFUL);
    }
    // [StartExclude MultiEntryReceiveDragData]
    catch (error) {
      const err = error as BusinessError;
      hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
    }
    // [EndExclude MultiEntryReceiveDragData]
  }

  // [End MultiEntryReceiveDragData]

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          // [Start MultiEntryOnDragStart]
          // [Start StartDragExample]
          RichEditor({ controller: this.sourceController })
          // [StartExclude MultiEntryOnDragStart]
          // [StartExclude StartDragExample]
            .height(175)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            // [EndExclude MultiEntryOnDragStart]
            .onSelectionChange((value: RichEditorRange) => {
              this.selectedStartIndex = value.start as number;
              this.selectedEndIndex = value.end as number;
            })
            // [StartExclude MultiEntryOnDragStart]
            .onReady(async () => {
              this.sourceController.addTextSpan(await this.context.resourceManager.getStringValue($r('app.string.text_and_image_text_description').id),
                {
                  style: this.textStyle,
                })
              this.sourceController.addImageSpan(this.originImage,
                {
                  imageStyle: this.imageStyle
                })
            })
            // [EndExclude StartDragExample]
            // [EndExclude MultiEntryOnDragStart]
            .onDragStart((event) => {
              try {
                const selection = this.sourceController.getSelection();
                // construct drag data
                this.buildUnifiedRecords(selection);
                event.setData(this.unifiedData);
              } catch (error) {
                const err = error as BusinessError;
                hilog.error(0x0000, TAG, `%{public}s`, err.code, err.message);
              }
            })
            // [StartExclude StartDragExample]
            // [StartExclude MultiEntryOnDragStart]
            .onDragEnd(() => {
              this.unifiedData = new unifiedDataChannel.UnifiedData();
            })
          // [EndExclude StartDragExample]
          // [EndExclude MultiEntryOnDragStart]
          // [End StartDragExample]
          // [End MultiEntryOnDragStart]
          SubHeader({
            primaryTitle: $r('app.string.pixelMap_text_title'),
            primaryTitleModifier: this.primaryModifier,
            contentMargin: {
              start: {
                value: 0,
                unit: LengthUnit.VP
              }
            }
          })
          // [Start RichEditor1OnDrop]
          RichEditor({ controller: this.targetController1 })
          // [StartExclude RichEditor1OnDrop]
            .height(175)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            // [EndExclude RichEditor1OnDrop]
            .allowDrop([uniformTypeDescriptor.UniformDataType.OPENHARMONY_PIXEL_MAP,
              uniformTypeDescriptor.UniformDataType.PLAIN_TEXT, uniformTypeDescriptor.UniformDataType.TEXT])
            .onDrop((event: DragEvent) => {
              event.setResult(0);
              this.receiveDragData(event, DROP_AREA.PIXELMAP_AREA);
            })
          // [End RichEditor1OnDrop]
          SubHeader({
            primaryTitle: $r('app.string.uri_text_title'),
            primaryTitleModifier: this.primaryModifier,
            contentMargin: {
              start: {
                value: 0,
                unit: LengthUnit.VP
              }
            }
          })
          // [Start RichEditor2OnDrop]
          RichEditor({ controller: this.targetController2 })
          // [StartExclude RichEditor2OnDrop]
            .height(175)
            .borderRadius(16)
            .backgroundColor($r('sys.color.comp_background_primary'))
            // [EndExclude RichEditor2OnDrop]
            .allowDrop([uniformTypeDescriptor.UniformDataType.PLAIN_TEXT, uniformTypeDescriptor.UniformDataType.TEXT,
              uniformTypeDescriptor.UniformDataType.IMAGE])
            .onDrop((event: DragEvent) => {
              try {
                event.setResult(0);
                this.receiveDragData(event, DROP_AREA.URI_AREA);
              } catch (error) {
                const err = error as BusinessError;
                hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
              }
            })
          // [End RichEditor2OnDrop]
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
    .title(getStringSync(this.context, $r('app.string.MultiEntry_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}