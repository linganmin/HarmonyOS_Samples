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
/**
 * 最佳实践：图片获取与保存实践
 */
import { BusinessError } from '@kit.BasicServicesKit';
import { cameraPicker, camera } from '@kit.CameraKit';
import { picker } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { PhotoPickerComponent, PickerController, photoAccessHelper, ReminderMode } from '@kit.MediaLibraryKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { copyImg2Sandbox, pixelMap2File } from '../common/utils/Utils';

const TAG = 'IMAGE_APP';

@Entry
@Component
struct Index {
  @State path: string = this.getUIContext().getHostContext()!.filesDir + '/image.jpg';
  @State pixelMapPath: string = this.getUIContext().getHostContext()!.filesDir + '/pixelMap.jpg';
  @State imageUri: string | undefined = undefined;
  @State imageSource: image.ImageSource | undefined = undefined;
  @State pixelMap: image.PixelMap | undefined = undefined;
  @State isShowGet: boolean = false;
  @State isShowPicker: boolean = false;
  @State isShowSave: boolean = false;
  @State pickerController: PickerController = new PickerController();

  @Builder
  getImage() {
    Column({ space: 12 }) {
      Button($r('app.string.get_image_from_component'))
        .width('100%')
        .height(40)
        .onClick(() => {
          this.isShowPicker = true;
        })
        .bindSheet($$this.isShowPicker, this.photoPicker(), {
          height: SheetSize.FIT_CONTENT,
          title: { title: $r('app.string.title_get_image_from_component') }
        })

      Button($r('app.string.get_image_from_photo_picker'))
        .width('100%')
        .height(40)
        .onClick(async () => {
          try {
            let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
            PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
            PhotoSelectOptions.maxSelectNumber = 1;
            let photoPicker = new photoAccessHelper.PhotoViewPicker();
            photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult: photoAccessHelper.PhotoSelectResult) => {
              this.imageUri = PhotoSelectResult.photoUris[0] ? PhotoSelectResult.photoUris[0] : this.imageUri;
              hilog.info(0x0000, TAG, 'PhotoViewPicker.select succeed, uri: ' + JSON.stringify(PhotoSelectResult));
            }).catch((err: BusinessError) => {
              hilog.error(0x0000, TAG, `PhotoViewPicker.select failed, error: ${err.code}, ${err.message}`);
            });
          } catch (error) {
            let err: BusinessError = error as BusinessError;
            hilog.error(0x0000, TAG, `PhotoViewPicker failed, error: ${err.code}, ${err.message}`);
          }
          this.isShowGet = false;
        })

      Button($r('app.string.get_image_from_camera_picker'))
        .width('100%')
        .height(40)
        .onClick(async () => {
          // [Start pick_file]
          try {
            let pickerProfile: cameraPicker.PickerProfile =
              { cameraPosition: camera.CameraPosition.CAMERA_POSITION_BACK };
            //Select the action of pulling up the camera to take pictures.
            let pickerResult: cameraPicker.PickerResult = await cameraPicker.pick(this.getUIContext().getHostContext(),
              [cameraPicker.PickerMediaType.PHOTO], pickerProfile);
            //Return the photo uri to the application.
            this.imageUri = pickerResult.resultUri ? pickerResult.resultUri : this.imageUri;
            hilog.info(0x0000, TAG, 'cameraPicker.pick succeed, uri: ' + JSON.stringify(pickerResult));
          } catch (error) {
            let err = error as BusinessError;
            hilog.error(0x0000, TAG, `cameraPicker.pick failed, error: ${err.code}, ${err.message}`);
          }
          // [End pick_file]
          this.isShowGet = false;
        })

      Button($r('app.string.get_image_from_document_picker'))
        .width('100%')
        .height(40)
        .onClick(() => {
          try {
            let documentSelectOptions = new picker.DocumentSelectOptions();
            documentSelectOptions.maxSelectNumber = 1;
            let documentPicker = new picker.DocumentViewPicker(this.getUIContext().getHostContext()!);
            documentPicker.select(documentSelectOptions).then((documentSelectResult: Array<string>) => {
              hilog.info(0x0000, TAG,
                'DocumentViewPicker.select succeed, uri: ' + JSON.stringify(documentSelectResult));
              if (documentSelectResult[0].endsWith('.jpg') || documentSelectResult[0].endsWith('.png')) {
                this.imageUri = documentSelectResult[0] ? documentSelectResult[0] : this.imageUri;
              } else {
                this.getUIContext().getPromptAction().showToast({
                  message: $r('app.string.document_alert'),
                  duration: 2000
                })
              }
            }).catch((err: BusinessError) => {
              hilog.error(0x0000, TAG, `DocumentViewPicker.select failed, error: ${err.code}, ${err.message}`);
            });
          } catch (error) {
            let err: BusinessError = error as BusinessError;
            hilog.error(0x0000, TAG, `DocumentViewPicker failed, error: ${err.code}, ${err.message}`);
          }
          this.isShowGet = false;
        })
    }
    .width('100%')
    .height(196)
    .padding({ left: 16, right: 16 })
    .margin({ top: 16, bottom: 44 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  onSelect(uri: string): void {
    if (uri) {
      this.imageUri = uri;
    }
  }

  @Builder
  photoPicker() {
    Column({ space: 12 }) {
      Scroll() {
        PhotoPickerComponent({
          pickerOptions: {
            maxPhotoSelectNumber: 1,
            maxVideoSelectNumber: 0,
            maxSelectedReminderMode: ReminderMode.TOAST,
          },
          onSelect: (uri: string) => this.onSelect(uri),
          pickerController: this.pickerController
        })
          .width('100%')
          .height('100%')
      }
      .width('100%')
      .height(400)

      Column() {
        Button($r('app.string.confirm'))
          .width('100%')
          .height(40)
          .onClick(() => {
            this.isShowPicker = false;
            this.isShowGet = false;
          })
      }
      .width('100%')
      .height(40)
      .padding({ left: 16, right: 16 })
    }
    .width('100%')
    .height(452)
    .margin({ top: 16, bottom: 44 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  saveImage() {
    Column({ space: 12 }) {
      Button($r('app.string.save_image_in_sandbox'))
        .width('100%')
        .height(40)
        .onClick(async () => {
          if (!this.pixelMap) {
            this.showToast($r('app.string.no_pixel_map_alert'), 2000);
            return;
          }

          await pixelMap2File(this.pixelMap, this.path);
          this.showToast($r('app.string.save_in_sandbox_success'), 2000);
          this.isShowSave = false;
        })

      SaveButton({ text: SaveDescription.SAVE_TO_GALLERY })
        .width('100%')
        .height(40)
        .onClick(async (event, result: SaveButtonOnClickResult) => {
          if (!this.pixelMap) {
            this.showToast($r('app.string.no_pixel_map_alert'), 2000);
            return;
          }

          if (result === SaveButtonOnClickResult.SUCCESS) {
            try {
              await pixelMap2File(this.pixelMap, this.path);
              let context = this.getUIContext().getHostContext();
              let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
              let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
                photoAccessHelper.MediaAssetChangeRequest.createImageAssetRequest(context, this.path);
              await phAccessHelper.applyChanges(assetChangeRequest);
              this.getUIContext().getPromptAction().showToast({
                message: $r('app.string.save_in_gallery_success'),
                duration: 2000
              });
            } catch (err) {
              hilog.error(0x0000, TAG, 'createAsset failed, error: ' + JSON.stringify(err));
            }
          } else {
            hilog.error(0x0000, TAG, 'SaveButtonOnClickResult create asset failed.');
          }
          this.isShowSave = false;
        })
    }
    .width('100%')
    .height(92)
    .padding({ left: 16, right: 16 })
    .margin({ top: 16, bottom: 44 })
    .justifyContent(FlexAlign.SpaceBetween)
  }

  build() {
    Navigation() {
      Column() {
        Image(this.imageUri)
          .height(350)
          .margin({ top: 16 })

        Column({ space: 12 }) {
          Button($r('app.string.get_image'))
            .width('100%')
            .height(40)
            .onClick(() => {
              this.isShowGet = true;
            })
            .bindSheet($$this.isShowGet, this.getImage(), {
              height: SheetSize.FIT_CONTENT,
              title: { title: $r('app.string.get_image') }
            })

          Button($r('app.string.get_image_info'))
            .width('100%')
            .height(40)
            .onClick(() => {
              if (!this.imageUri) {
                this.showToast($r('app.string.no_image_alert'), 2000);
                return;
              }

              copyImg2Sandbox(this.imageUri, this.path).then(() => {
                // [Start image_source]
                this.imageSource = image.createImageSource(this.path);
                this.imageSource.getImageInfo((error: BusinessError, imageInfo: image.ImageInfo) => {
                  if (error) {
                    hilog.error(0x0000, TAG, `getImageInfo failed, error: ${error.code}, ${error.message}`);
                  } else {
                    hilog.info(0x0000, TAG, 'getImageInfo succeed, info: ' + JSON.stringify(imageInfo));
                  }
                });
                // [End image_source]
                // [Start image_proper]
                let key = [image.PropertyKey.IMAGE_WIDTH, image.PropertyKey.IMAGE_LENGTH, image.PropertyKey.F_NUMBER];
                this.imageSource.getImageProperties(key).then((data) => {
                  hilog.info(0x0000, TAG, 'getImageProperties succeed, data: ' + JSON.stringify(data));
                }).catch((error: BusinessError) => {
                  hilog.error(0x0000, TAG, 'getImageProperties failed, error: ' + JSON.stringify(error));
                });
                // [End image_proper]
              });

              this.showToast($r('app.string.get_image_info_success'), 2000);
            })

          Button($r('app.string.get_pixel_map'))
            .width('100%')
            .height(40)
            .onClick(() => {
              if (!this.imageSource) {
                this.showToast($r('app.string.no_image_info_alert'), 2000);
                return;
              }

              this.imageSource.createPixelMap().then((pixelMap: image.PixelMap) => {
                this.pixelMap = pixelMap;
                this.showToast($r('app.string.get_pixel_map_success'), 2000);
              }).catch((error: BusinessError) => {
                hilog.error(0x0000, TAG, 'createPixelMap failed, error: ' + JSON.stringify(error));
              })
            })

          Button($r('app.string.save_image'))
            .width('100%')
            .height(40)
            .onClick(() => {
              this.isShowSave = true;
            })
            .bindSheet($$this.isShowSave, this.saveImage(), {
              height: SheetSize.FIT_CONTENT,
              title: { title: $r('app.string.save_image') }
            })
        }
        .width('100%')
        .height(196)
        .padding({ left: 16, right: 16 })
        .margin({ bottom: 16 })
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.SpaceBetween)
    }
    .width('100%')
    .height('100%')
    .title($r('app.string.title'))
  }

  showToast(message: ResourceStr, duration?: number) {
    try {
      this.getUIContext().getPromptAction().showToast({
        message: message,
        duration: duration
      });
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Index', `showToast failed, error code=${err.code}, message=${err.message}`);
    }
  }
}