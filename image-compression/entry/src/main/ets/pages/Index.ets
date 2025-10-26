/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import CommonConstants from '../common/CommonConstants'

const TAG = 'IMAGE_COMPRESSION';

class CompressedImageInfo {
  imageUri: string = "";
  imageByteLength: number = 0;
}

async function compressedImage(sourcePixelMap: image.PixelMap,
  maxCompressedImageSize: number): Promise<CompressedImageInfo> {
  const imagePackerApi = image.createImagePacker();
  const IMAGE_QUALITY = 0;
  const packOpts: image.PackingOption = { format: "image/jpeg", quality: IMAGE_QUALITY };
  let compressedImageData: ArrayBuffer = await imagePackerApi.packToData(sourcePixelMap, packOpts)
    .catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, `releaseVideo catch error, code: ${error.code}, message: ${error.message}`);
      return new ArrayBuffer(0);
    });
  const maxCompressedImageByte = maxCompressedImageSize * CommonConstants.BYTE_CONVERSION;
  if (maxCompressedImageByte > compressedImageData.byteLength) {
    compressedImageData =
      await packingImage(compressedImageData, sourcePixelMap, IMAGE_QUALITY, maxCompressedImageByte);
  } else {
    let imageScale = 1;
    const REDUCE_SCALE = CommonConstants.REDUCE_SCALE;
    while (compressedImageData.byteLength > maxCompressedImageByte) {
      if (imageScale > 0) {
        imageScale = imageScale - REDUCE_SCALE;
        await sourcePixelMap.scale(imageScale, imageScale);
        compressedImageData = await packing(sourcePixelMap, IMAGE_QUALITY);
      } else {
        break;
      }
    }
  }
  const compressedImageInfo: CompressedImageInfo = await saveImage(compressedImageData);
  return compressedImageInfo;
}

async function packing(sourcePixelMap: image.PixelMap, imageQuality: number): Promise<ArrayBuffer> {
  const imagePackerApi = image.createImagePacker();
  const packOpts: image.PackingOption = { format: "image/jpeg", quality: imageQuality };
  const data: ArrayBuffer = await imagePackerApi.packToData(sourcePixelMap, packOpts).catch((error: BusinessError) => {
    hilog.error(0x0000, TAG, `releaseVideo catch error, code: ${error.code}, message: ${error.message}`);
    return new ArrayBuffer(0);
  });
  return data;
}

async function packingImage(compressedImageData: ArrayBuffer, sourcePixelMap: image.PixelMap,
  imageQuality: number, maxCompressedImageByte: number): Promise<ArrayBuffer> {
  const packingArray: number[] = [];
  const DICHOTOMY_ACCURACY = CommonConstants.DICHOTOMY_ACCURACY;
  for (let i = 0; i <= CommonConstants.PICTURE_QUALITY_MAX; i += DICHOTOMY_ACCURACY) {
    packingArray.push(i);
  }
  let left = 0;
  let right = packingArray.length - 1;
  while (left <= right) {
    const mid = Math.floor((left + right) / 2);
    imageQuality = packingArray[mid];
    compressedImageData = await packing(sourcePixelMap, imageQuality);
    if (compressedImageData.byteLength <= maxCompressedImageByte) {
      left = mid + 1;
      if (mid === packingArray.length - 1) {
        break;
      }
      compressedImageData = await packing(sourcePixelMap, packingArray[mid + 1]);
      if (compressedImageData.byteLength > maxCompressedImageByte) {
        compressedImageData = await packing(sourcePixelMap, packingArray[mid]);
        break;
      }
    } else {
      right = mid - 1;
    }
  }
  return compressedImageData;
}

const uiContext: UIContext | undefined = AppStorage.get('uiContext');

async function saveImage(compressedImageData: ArrayBuffer): Promise<CompressedImageInfo> {
  const context: Context = uiContext!.getHostContext()!;
  const compressedImageUri: string = context.filesDir + '/' + 'afterCompression.jpeg';
  try {
    const res = fileIo.accessSync(compressedImageUri);
    if (res) {
      fileIo.unlinkSync(compressedImageUri);
    }
    const file: fileIo.File = fileIo.openSync(compressedImageUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.writeSync(file.fd, compressedImageData);
    fileIo.closeSync(file);
  } catch (err) {
    hilog.error(0x0000, TAG, JSON.stringify(err));
  }
  let compressedImageInfo: CompressedImageInfo = new CompressedImageInfo();
  compressedImageInfo.imageUri = compressedImageUri;
  compressedImageInfo.imageByteLength = compressedImageData.byteLength;
  return compressedImageInfo;
}

@Entry
@Component
struct Index {
  @State compressedImageSrc: string | Resource = '';
  @State beforeCompressionSize: string = '';
  @State afterCompressionSize: string = '';
  private sourceImageByteLength: number = 0;
  private compressedByteLength: number = 0;
  private maxCompressedImageSize: number = 0;
  private context: Context = this.getUIContext().getHostContext()!;

  aboutToAppear(): void {
    const context: Context = this.getUIContext().getHostContext()!;
    const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
    resourceMgr.getRawFileContent('beforeCompression.jpeg').then((fileData: Uint8Array) => {
      const buffer = fileData.buffer.slice(0);
      this.sourceImageByteLength = buffer.byteLength;
      this.beforeCompressionSize = (this.sourceImageByteLength / CommonConstants.BYTE_CONVERSION).toFixed(1);
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, JSON.stringify(err));
    });
  }

  imageCompression(): void {
    const resourceMgr: resourceManager.ResourceManager = this.context.resourceManager;
    resourceMgr.getRawFileContent('beforeCompression.jpeg').then((fileData: Uint8Array) => {
      const buffer = fileData.buffer.slice(0);
      const imageSource: image.ImageSource = image.createImageSource(buffer);
      const decodingOptions: image.DecodingOptions = {
        editable: true,
        desiredPixelFormat: 3,
      }
      imageSource.createPixelMap(decodingOptions).then((originalPixelMap: image.PixelMap) => {
        compressedImage(originalPixelMap, this.maxCompressedImageSize).then((showImage: CompressedImageInfo) => {
          this.compressedImageSrc = fileUri.getUriFromPath(showImage.imageUri);
          this.compressedByteLength = showImage.imageByteLength;
          this.afterCompressionSize = (this.compressedByteLength / CommonConstants.BYTE_CONVERSION).toFixed(1);
        })
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, JSON.stringify(err));
      });
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, TAG, JSON.stringify(err));
    });
  }

  build() {
    Column({ space: CommonConstants.SPACE_TEN }) {
      Row({ space: CommonConstants.SPACE_TEN }) {
        Text($r('app.string.max_compression_image_size')).fontSize($r('app.float.font_size_16'))
        TextInput()
          .type(InputType.Number)
          .fontSize($r('app.float.font_size_16'))
          .width($r('app.string.text_input_width'))
          .onChange((value: string) => {
            this.maxCompressedImageSize = Number(value);
          })
      }

      Button($r('app.string.image_compression')).onClick(() => {
        if (this.maxCompressedImageSize === 0) {
          this.getUIContext().showAlertDialog({
            message: $r('app.string.prompt_enter_value_greater_than_0'),
            alignment: DialogAlignment.Center
          });
          return;
        }
        if (this.maxCompressedImageSize * CommonConstants.BYTE_CONVERSION > this.sourceImageByteLength) {
          if (this.sourceImageByteLength === 0) {
            this.getUIContext().showAlertDialog({
              message: $r('app.string.image_get_failed'),
              alignment: DialogAlignment.Center
            });
          } else {
            this.getUIContext().showAlertDialog({
              message: $r('app.string.prompt_not_require_compression'),
              alignment: DialogAlignment.Center
            });
          }
          return;
        }
        this.compressedImageSrc = '';
        this.imageCompression();
      }).fontSize($r('app.float.font_size_16')).width($r('app.string.button_width'))

      Row() {
        Text($r('app.string.image_size_before_compression'))
          .fontSize($r('app.float.font_size_16'))
        Text(this.beforeCompressionSize)
          .fontSize($r('app.float.font_size_16'))
      }

      Image($rawfile('beforeCompression.jpeg'))
        .width($r('app.string.image_width'))
        .height($r('app.string.image_height'))

      Row() {
        Text($r('app.string.image_size_after_compression'))
          .fontSize($r('app.float.font_size_16'))
        Text(this.afterCompressionSize)
          .fontSize($r('app.float.font_size_16'))
      }

      Image(this.compressedImageSrc)
        .width($r('app.string.image_width'))
        .height($r('app.string.image_height'))
    }.alignItems(HorizontalAlign.Start).padding($r('app.float.column_padding'))
  }
}