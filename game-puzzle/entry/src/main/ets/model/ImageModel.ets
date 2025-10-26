/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import PictureItem from './PictureItem';
import { CommonConstants as Common } from '../common/CommonConstants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = '[ImageModel]';

export default class ImageModel {
  private phAccessHelper: photoAccessHelper.PhotoAccessHelper | null = null;

  constructor(context: Context) {
    this.phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
  }

  async getAllImg(): Promise<photoAccessHelper.PhotoAsset[]> {
    hilog.info(0x0000, TAG, 'getAllImg');
    let photoList: Array<photoAccessHelper.PhotoAsset> = [];
    if (this.phAccessHelper === null) {
      hilog.error(0x0000, TAG, 'phAccessHelper fail');
      return photoList;
    }
    let fileKeyType = photoAccessHelper.PhotoKeys.PHOTO_TYPE;
    let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
    hilog.info(0x0000, TAG, fileKeyType);
    let fetchOptions: photoAccessHelper.FetchOptions = {
      fetchColumns: [],
      predicates: predicates
    };

    try {
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await this.phAccessHelper.getAssets(fetchOptions);
      if (fetchResult !== undefined) {
        hilog.info(0x0000, TAG, 'fetchResult success');
        let photoAsset: Array<photoAccessHelper.PhotoAsset> = await fetchResult.getAllObjects();
        if (photoAsset !== undefined && photoAsset.length > 0) {
          for (let i = 0; i < photoAsset.length; i++) {
            if (photoAsset[i].photoType === 1) {
              photoList.push(photoAsset[i]);
            }
          }
        }
      }
    } catch (err) {
      hilog.error(0x0000, TAG, 'getAssets failed, message = ', err);
    }
    hilog.info(0x0000, TAG, 'photoList success');
    return photoList;
  }

  async splitPic(index: number): Promise<PictureItem[]> {
    let imagePixelMap: PictureItem[] = [];
    let imagesData: Array<photoAccessHelper.PhotoAsset> = await this.getAllImg();
    let imagePackerApi = image.createImagePacker();
    fileIo.open(imagesData[index].uri, fileIo.OpenMode.READ_ONLY).then(async (file: fileIo.File) => {
      let fd: number = file.fd;
      let imageSource = image.createImageSource(fd);
      let imageInfo = await imageSource.getImageInfo();
      hilog.info(0x0000, TAG, `sizeImg createImageSource ${JSON.stringify(imageSource)}`);
      let height = imageInfo.size.height / Common.SPLIT_COUNT;
      for (let i = 0; i < Common.SPLIT_COUNT; i++) {
        for (let j = 0; j < Common.SPLIT_COUNT; j++) {
          let picItem: PictureItem;
          if (i === Common.SPLIT_COUNT - 1 && j === Common.SPLIT_COUNT - 1) {
            picItem = new PictureItem(Common.PICTURE_ITEM_NUMBER, {} as image.PixelMap);
            imagePixelMap.push(picItem);
          } else {
            hilog.info(0x0000, TAG, `sizeImg x = ${imageInfo.size.width / Common.SPLIT_COUNT} y = ${height}`);
            let decodingOptions: image.DecodingOptions = {
              desiredRegion: {
                size: {
                  height: height,
                  width: imageInfo.size.width / Common.SPLIT_COUNT
                },
                x: j * imageInfo.size.width / Common.SPLIT_COUNT,
                y: i * height
              }
            }
            imagePixelMap.push(
              new PictureItem(i * Common.SPLIT_COUNT + j, await imageSource.createPixelMap(decodingOptions)));
          }
        }
      }
      imagePackerApi.release();
      try {
        fileIo.closeSync(fd);
      } catch (err) {
        hilog.error(0x0000, TAG, `fileIo.close failed, error code=${err.code}, message=${err.message}`);
      }
    }).catch((err: BusinessError) => {
      hilog.info(0x0000, TAG, `fileIo.open failed, error code=${err.code}, message=${err.message}`);
    })
    return imagePixelMap;
  }
}