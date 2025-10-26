/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:如何将相册选择的图片生成PixelMap
*/

// [Start SelectedAlbumPictureGeneratePixelMap_One]
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { dataSharePredicates } from '@kit.ArkData';
import { common } from '@kit.AbilityKit';

const context = AppStorage.get("context") as common.UIAbilityContext;
@Entry
@Component
struct WebComponent {
  build() {
    Column() {
      Button('选择图片').onClick(() => {
        try {
          let uris: Array<string> = [];
          let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
          PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
          PhotoSelectOptions.maxSelectNumber = 1;
          let photoPicker = new photoAccessHelper.PhotoViewPicker();
          photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
            console.info('photoPicker.select successfully, PhotoSelectResult uri: ' + JSON.stringify(PhotoSelectResult));
            uris = PhotoSelectResult.photoUris;
            let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
            let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
            // Configure query conditions, use PhotoViewPicker to select the URI of the image to be queried
            predicates.equalTo('uri', uris[0]);
            let fetchOptions: photoAccessHelper.FetchOptions = {
              fetchColumns: [],
              predicates: predicates
            };
            phAccessHelper.getAssets(fetchOptions, async (err, fetchResult) => {
              if (fetchResult !== undefined) {
                console.info('fetchResult success');
                let photoAsset: photoAccessHelper.PhotoAsset = await fetchResult.getFirstObject();
                if (photoAsset !== undefined) {
                  // Get Thumbnail
                  photoAsset.getThumbnail((err, pixelMap) => {
                    if (err == undefined) {
                      console.info('getThumbnail successful ' + JSON.stringify(pixelMap));
                    } else {
                      console.error('getThumbnail fail', err);
                    }
                  });
                  console.info('photoAsset.displayName : ' + photoAsset.displayName);
                }
              } else {
                console.error(`fetchResult fail with error: ${err.code}, ${err.message}`);
              }
            });
          }).catch((err: BusinessError) => {
            console.error('photoPicker.select failed with err: ' + JSON.stringify(err));
          });
        } catch (error) {
          let err: BusinessError = error as BusinessError;
          console.error('photoPicker failed with err: ' + JSON.stringify(err));
        }
      })
    }
  }
}
// [End SelectedAlbumPictureGeneratePixelMap_One]