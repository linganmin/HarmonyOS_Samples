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
import { image } from '@kit.ImageKit';
import { fileUri, fileIo as fs } from '@kit.CoreFileKit';
import { CommonConstants } from '../common/CommonConstants';
import Logger from './Logger';
import { ImageInfo } from '../model/ContentInfo';

export class FileUtils {
  public static readonly tag: string = 'FileUtils';
  public static readonly qualityValue: number = 98;
  public static readonly formatValue: string = 'image/jpeg';
  public static readonly extensionValue: string = 'jpg';
  // [Start create_pixe_lmapfromuri]
  public static options: image.DecodingOptions = {
    index: 0,
    editable: false,
    desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
  };

  // [End create_pixe_lmapfromuri]
  /**
   * Copy file to destination address
   *
   * @param sourceUri source uri
   * @param destination destination address
   */
  // [Start copy_to_files_dir]
  static copyFileToDestination(sourceUri: string, destination: string) {
    try {
      let buf = new ArrayBuffer(CommonConstants.FILE_BUFFER_SIZE);
      let readSize = 0;
      let file = fs.openSync(sourceUri, fs.OpenMode.READ_ONLY);
      let readLen = fs.readSync(file.fd, buf, { offset: readSize });
      let destinationDistribute =
        fs.openSync(`${destination}/${file.name}`, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
      while (readLen > 0) {
        readSize += readLen;
        fs.writeSync(destinationDistribute.fd, buf);
        readLen = fs.readSync(file.fd, buf, { offset: readSize });
      }
      Logger.info(FileUtils.tag, 'copyFileToDestination success');
      fs.closeSync(file);
      fs.closeSync(destinationDistribute);
    } catch (err) {
      Logger.error(FileUtils.tag, `copyFileToDestination failed. Code: ${err.code}, message: ${err.message}`);
    }
  }

  // [End copy_to_files_dir]
  
  /**
   * create pixelMap by uri
   *
   * @param uri file uri
   * @returns imageInfo
   */
  // [Start create_pixe_lmapfromuri]
  static createPixelMap(uri: string): ImageInfo | undefined {
    let imageInfo: ImageInfo | undefined;
    try {
      let file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
      let displayName = file.name;
      let imageResource = image.createImageSource(file.fd);
      let pixelMap = imageResource.createPixelMapSync(FileUtils.options);
      imageInfo = { imagePixelMap: pixelMap, imageName: displayName };
      fs.closeSync(file);
    } catch (error) {
      Logger.error(FileUtils.tag, `createPixelMap error: ${JSON.stringify(error)}`);
    }
    return imageInfo;
  }

  // [End create_pixe_lmapfromuri]

  /**
   * save file by buffer
   *
   * @param context context
   * @param buffer ArrayBuffer
   * @returns uri
   */
  static saveFile(context: Context, buffer: ArrayBuffer): string {
    let filesDir: string = context.filesDir;
    let photoUri: string = fileUri.getUriFromPath(`${filesDir}/${Date.now().toString()}.${FileUtils.extensionValue}`);
    let file = fs.openSync(photoUri, fs.OpenMode.READ_WRITE | fs.OpenMode.CREATE);
    fs.writeSync(file.fd, buffer);
    Logger.debug(FileUtils.tag, `saveFile uri: ${photoUri}}`);
    fs.closeSync(file);
    return photoUri;
  }
}