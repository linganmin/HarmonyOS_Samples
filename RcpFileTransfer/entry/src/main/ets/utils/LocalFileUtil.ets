/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
/**
 * 最佳实践：基于RCP的文件上传与下载
 */
import { fileIo, fileUri } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { imageExtensions } from '../constants/Constants';
import { Logger } from '../utils/Logger';

const TAG = 'LocalFileUtil';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext!.getHostContext()!;

export function getSandboxPath(path: string) {
  return `${context.filesDir}/${path}`;
}

export function copyFileSync(srcPath: string, destPath: string) {
  try {
    const srcFile = fileIo.openSync(srcPath, fileIo.OpenMode.READ_ONLY);
    const destFile = fileIo.openSync(destPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    fileIo.copyFileSync(srcFile.fd, destFile.fd);
    fileIo.closeSync(srcFile);
    fileIo.closeSync(destFile);
  } catch (exception) {
    Logger.error(TAG, `createAsset failed. Code:${exception.code}, message:${exception.message}`);
  }
}

function getPhotoType(fileNameExtension: string) {
  return imageExtensions.includes(fileNameExtension) ?
    photoAccessHelper.PhotoType.IMAGE :
    photoAccessHelper.PhotoType.VIDEO;
}

export async function getAlbumAsset(fileNameExtension: string) {
  const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
  try {
    return await phAccessHelper.createAsset(getPhotoType(fileNameExtension), fileNameExtension);
  } catch (exception) {
    Logger.error(TAG, `createAsset failed. Code:${exception.code}, message:${exception.message}`);
    return '';
  }
}

// [Start album]
export async function saveImageToAlbum(sandboxPath: string) {
  const phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
  const fileNameExtension = sandboxPath.split('.').pop() || 'png';
  const photoCreationConfig: photoAccessHelper.PhotoCreationConfig = {
    fileNameExtension,
    photoType: getPhotoType(fileNameExtension),
  };
  const uri: string = fileUri.getUriFromPath(sandboxPath);
  let desFileUris: string[] = [];
  try {
    desFileUris = await phAccessHelper.showAssetsCreationDialog([uri], [photoCreationConfig]);
  } catch (exception) {
    Logger.error(TAG, `showAssetsCreationDialog failed. Code:${exception.code}, message:${exception.message}`);
  }
  const filePath = desFileUris[0];
  if (!filePath) {
    throw new Error('photo assets permission denied');
  }
  copyFileSync(sandboxPath, filePath);
  return filePath;
}

// [End album]

// [Start from_album]
export async function selectImagesFromAlbum(maxNumber: number = 1): Promise<string[]> {
  const photoPicker = new photoAccessHelper.PhotoViewPicker();
  const photoSelectOptions: photoAccessHelper.PhotoSelectOptions = {
    MIMEType: photoAccessHelper.PhotoViewMIMETypes.IMAGE_VIDEO_TYPE,
    maxSelectNumber: maxNumber
  };
  return photoPicker.select(photoSelectOptions).then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
    const filePaths = photoSelectResult.photoUris;
    return filePaths.map(filePath => {
      const imageName = filePath.split('/').pop() || '';
      const sandboxPath = getSandboxPath(imageName);
      copyFileSync(filePath, sandboxPath);
      return sandboxPath;
    });
  }).catch((err: BusinessError) => {
    Logger.error(TAG, `selectImagesFromAlbum failed. Code:${err.code}, message:${err.message}`);
    return [];
  });
}

// [End from_album]
