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
import { drawing } from '@kit.ArkGraphics2D';
import { display, TextModifier, SubHeader, LengthUnit } from '@kit.ArkUI';
import { BusinessError, systemDateTime } from '@kit.BasicServicesKit';
import { fileIo as fs, fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { Constants } from '../../common/Constants';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BreakpointType } from '../../common/Utils';
import { getStringSync } from '../../utils/StringUtil';

const TAG = '[Watermark]';

@Builder
export function PageWatermarkBuilder() {
  WatermarkDrag();
}

@Entry
@Component
struct WatermarkDrag {
  @Consume('NavPathStack') pageStack: NavPathStack;
  @State targetImage: string = '';
  @State primaryModifier: TextModifier =
    new TextModifier().fontColor(Color.Gray).fontSize(18).fontWeight(FontWeight.Medium);
  @StorageProp('topRectHeight') topRectHeight: number = 0;
  @StorageLink('currentBreakpoint') curBp: string = Constants.BREAK_POINT_SM;
  context?: Context = this.getUIContext().getHostContext();
  time: string = '0';

  getTimeWatermark(str: number): string {
    let time: string = '';
    let date: Date = new Date(str);
    try {
      let year: number = date.getFullYear();
      let month: string | number = (date.getMonth() + 1) < 10 ? '0' + (date.getMonth() + 1) : (date.getMonth() + 1);
      let day: string | number = date.getDate() < 10 ? '0' + date.getDate() : date.getDate();
      let hour: string | number = date.getHours() < 10 ? '0' + date.getHours() : date.getHours();
      let min: string | number = date.getMinutes() < 10 ? '0' + date.getMinutes() : date.getMinutes();
      let second: string | number = date.getSeconds() < 10 ? '0' + date.getSeconds() : date.getSeconds();
      time = year + '-' + month + '-' + day + ' ' + hour + ':' + min + ':' + second;
      hilog.info(0x0000, TAG, `%{public}s`, `getTimeWatermark`);
    } catch (error) {
      hilog.error(0x0000, TAG,
        `Failed to get currentTime, code = ${(error as BusinessError).code}, message = ${(error as BusinessError).message}`);
    }
    return time;
  }

  getDataFromUdmfRetry(event: DragEvent, callback: (data: DragEvent) => void) {
    try {
      let data: UnifiedData = event.getData();
      if (!data) {
        return false;
      }
      let records: unifiedDataChannel.UnifiedRecord[] = data.getRecords();
      if (!records || records.length <= 0) {
        return false;
      }
      callback(event);
      return true;
    } catch (error) {
      hilog.error(0x0000, TAG,
        `getData failed, code = ${(error as BusinessError).code}, message = ${(error as BusinessError).message}`);
      return false;
    }
  }

  getDataFromUdmf(event: DragEvent, callback: (data: DragEvent) => void) {
    if (this.getDataFromUdmfRetry(event, callback)) {
      return;
    }
    setTimeout(() => {
      this.getDataFromUdmfRetry(event, callback);
    }, 1500);
  }

  // [Start waterMarkImageAddWaterMarkFunction]
  addWaterMark(watermark: string, pixelMap: image.PixelMap) {
    try {
      if (!canIUse('SystemCapability.Graphics.Drawing')) {
        hilog.error(0x0000, TAG, `%{public}s`, `watermark is not supported`);
        return pixelMap;
      }
      watermark = this.context!.resourceManager.getStringSync($r('app.string.drag_time').id) + watermark;
      const imageInfo: image.Size = pixelMap.getImageInfoSync().size;
      const imageWidth: number = imageInfo.width;
      const imageHeight: number = imageInfo.height;
      const imageScale: number = imageWidth / display.getDefaultDisplaySync().width;
      const canvas: drawing.Canvas = new drawing.Canvas(pixelMap);
      const pen: drawing.Pen = new drawing.Pen();
      const brush: drawing.Brush = new drawing.Brush();
      pen.setColor({
        alpha: 102,
        red: 255,
        green: 255,
        blue: 255
      });
      brush.setColor({
        alpha: 102,
        red: 255,
        green: 255,
        blue: 255
      });
      const font: drawing.Font = new drawing.Font();
      font.setSize(48 * imageScale);
      let textWidth: number = font.measureText(watermark, drawing.TextEncoding.TEXT_ENCODING_UTF8);
      const textBlob: drawing.TextBlob =
        drawing.TextBlob.makeFromString(watermark, font, drawing.TextEncoding.TEXT_ENCODING_UTF8);
      canvas.attachBrush(brush);
      canvas.attachPen(pen);
      canvas.drawTextBlob(textBlob, imageWidth - 24 * imageScale - textWidth, imageHeight - 32 * imageScale);
      canvas.detachBrush();
      canvas.detachPen();
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s', 'addWaterMark failed:', (error as BusinessError).message);
    }
    return pixelMap;
  }

  // [End waterMarkImageAddWaterMarkFunction]

  build() {
    NavDestination() {
      Scroll() {
        Column() {
          Flex({ direction: FlexDirection.Row, alignItems: ItemAlign.Center, justifyContent: FlexAlign.SpaceAround }) {
            // [Start waterMarkImageToDrag]
            // [Start waterMarkImageOnDragStart]
            // [Start waterMarkImageAddWaterMark]
            // [Start waterMarkImagePack]
            Image($rawfile('river.png'))
              // [StartExclude waterMarkImageToDrag]
              // [StartExclude waterMarkImageOnDragStart]
              // [StartExclude waterMarkImageAddWaterMark]
              // [StartExclude waterMarkImagePack]
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .fitOriginalSize(true)
              .borderRadius(16)
                // [EndExclude waterMarkImageToDrag]
              .draggable(true)
                // [End waterMarkImageToDrag]
                // [EndExclude waterMarkImageOnDragStart]
                // [EndExclude waterMarkImageAddWaterMark]
                // [EndExclude waterMarkImagePack]
              .onDragStart((event: DragEvent) => {
                // [StartExclude waterMarkImagePack]
                // [StartExclude waterMarkImageAddWaterMark]
                const resourceMgr: resourceManager.ResourceManager = this.context!.resourceManager;
                let rawFileDescriptor = resourceMgr.getRawFdSync('river.png');
                const imageSourceApi: image.ImageSource = image.createImageSource(rawFileDescriptor);
                let pixelMap: image.PixelMap = imageSourceApi.createPixelMapSync();
                // [StartExclude waterMarkImageOnDragStart]
                imageSourceApi?.release();
                // [EndExclude waterMarkImageAddWaterMark]
                this.time = this.getTimeWatermark(systemDateTime.getTime(false));
                let markPixelMap: image.PixelMap = this.addWaterMark(this.time, pixelMap);
                // [StartExclude waterMarkImageAddWaterMark]
                // [EndExclude waterMarkImagePack]
                let packOpts: image.PackingOption = { format: 'image/png', quality: 20 };
                let file: fs.File =
                  fs.openSync(`${this.context!.filesDir}/watermark.png`, fs.OpenMode.CREATE | fs.OpenMode.READ_WRITE);
                const imagePackerApi: image.ImagePacker = image.createImagePacker();
                imagePackerApi.packToFile(markPixelMap, file.fd, packOpts);
                imagePackerApi?.release();
                let imgData: uniformDataStruct.FileUri = {
                  uniformDataType: 'general.file-uri',
                  oriUri: fileUri.getUriFromPath(`${this.context!.filesDir}/watermark.png`),
                  fileType: 'general.image'
                }
                let unifiedRecord =
                  new unifiedDataChannel.UnifiedRecord(uniformTypeDescriptor.UniformDataType.FILE_URI, imgData);
                let unifiedData = new unifiedDataChannel.UnifiedData(unifiedRecord);
                event.setData(unifiedData);
                fs.closeSync(file.fd);
                // [StartExclude waterMarkImagePack]
                pixelMap.release();
                markPixelMap.release();
                // [EndExclude waterMarkImageAddWaterMark]
                // [EndExclude waterMarkImageOnDragStart]
                // [EndExclude waterMarkImagePack]
              })
                // [End waterMarkImageOnDragStart]
                // [End waterMarkImageAddWaterMark]
                // [End waterMarkImagePack]
              .onDragEnd((event) => {
                if (event.getResult() === DragResult.DRAG_SUCCESSFUL) {
                  this.getUIContext().getPromptAction().showToast({
                    duration: 100,
                    bottom: '80vp',
                    message: $r('app.string.drag_successfully')
                  });
                } else if (event.getResult() === DragResult.DRAG_FAILED) {
                  this.getUIContext().getPromptAction().showToast({ duration: 100, bottom: '80vp', message: $r('app.string.drag_failed') });
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
          Column() {
            Image(this.targetImage)
              .constraintSize({ maxWidth: '100%' })
              .width('100%')
              .height(new BreakpointType('180vp', '224vp', '391vp').getValue(this.curBp))
              .fitOriginalSize(true)
              .borderRadius(16)
              .draggable(true)
          }
          .alignItems(HorizontalAlign.Center)
          .allowDrop([uniformTypeDescriptor.UniformDataType.IMAGE])
          .onDrop((dragEvent?: DragEvent) => {
            try {
              this.getDataFromUdmf((dragEvent as DragEvent), (event: DragEvent) => {
                let records: unifiedDataChannel.UnifiedRecord[] = event.getData().getRecords();
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
                event.useCustomDropAnimation = false;
                event.setResult(DragResult.DRAG_SUCCESSFUL);
              })
            } catch (error) {
              const err = error as BusinessError;
              hilog.error(0x0000, TAG, `startDataLoading errorCode: ${err.code}, errorMessage: ${err.message}`);
            }
          })
          .backgroundColor($r('sys.color.comp_background_primary'))
          .constraintSize({ maxWidth: '100%' })
          .borderRadius(16)
        }
        .padding({
          left: '16vp',
          right: '16vp',
          top: '8vp',
          bottom: '16vp'
        })
      }
    }
    .title(getStringSync(this.context!, $r('app.string.watermark_title').id))
    .backgroundColor($r('sys.color.background_secondary'))
    .padding({ top: this.getUIContext().px2vp(this.topRectHeight) })
  }
}