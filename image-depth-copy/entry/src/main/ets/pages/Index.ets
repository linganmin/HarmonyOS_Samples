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

import { common } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { resourceManager } from '@kit.LocalizationKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit'
import { CropTasks, TaskData, cropTaskDates } from '../model/AdjustData';
import { savePixelMap } from '../util/FileUtil';
import { copyPixelMap } from '../util/CopyObj';
import { ImageCropConstants } from '../constants/ImageCropConstants';

@Entry
@Component
struct Index {
  private imageSource: image.ImageSource | undefined = undefined;
  private pixelMapSrc: PixelMap | undefined | null = undefined;
  @State pixelMapDst: PixelMap | undefined | null = undefined;
  @State cropIndex: number = 0;
  @State currentCropTask: number = CropTasks.NONE;
  @State bottomSafeHeight: number = 0;

  UIContext = this.getUIContext();
  context = this.UIContext.getHostContext() as common.UIAbilityContext;

  /**
   * Save image.
   */
  async onSave(): Promise<void> {
    try {
      if (this.pixelMapDst !== undefined && this.pixelMapDst !== null) {
        const uri: string = await savePixelMap(this.context, this.pixelMapDst!);
        const strMsg: string =
          this.context.resourceManager.getStringSync($r('app.string.image_depth_copy_save_path').id) + uri;
        this.UIContext.getPromptAction().showToast({
          message: strMsg,
          duration: ImageCropConstants.SHOW_TOAST_DURATION
        });
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `save PixelMap fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  /**
   * Image cropping.
   */
  async cropImage(proportion: number): Promise<void> {
    if (!this.pixelMapSrc) {
      return;
    }
    const pixelMapTemp = await copyPixelMap(this.pixelMapSrc);
    const imageInfo: image.ImageInfo = await pixelMapTemp.getImageInfo();
    if (!imageInfo) {
      return;
    }
    let imageHeight: number = imageInfo.size.height;
    let imageWith: number = imageInfo.size.width;
    if (proportion === ImageCropConstants.ONE_ONE) {
      if (imageHeight > imageWith) {
        imageHeight = imageWith;
      } else {
        imageWith = imageHeight;
      }
    }
    await pixelMapTemp.crop({
      size: { height: imageHeight / proportion, width: imageWith },
      x: 0,
      y: 0
    });
    this.pixelMapDst = pixelMapTemp;
  }

  async aboutToAppear(): Promise<void> {
    try {
      let windowHeight: window.Window = await window.getLastWindow(this.context);
      await windowHeight.setWindowLayoutFullScreen(true);
      this.bottomSafeHeight =
        this.UIContext.px2vp(windowHeight.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR).bottomRect.height)

      const context: Context = this.context;
      const resourceMgr: resourceManager.ResourceManager = context.resourceManager;
      const fileData: Uint8Array = await resourceMgr.getRawFileContent(ImageCropConstants.RAWFILE_PIC_PATH);
      const buffer = fileData.buffer.slice(fileData.byteOffset, fileData.byteLength + fileData.byteOffset);
      this.imageSource = image.createImageSource(buffer);
      const decodingOptions: image.DecodingOptions = {
        editable: false,
        desiredPixelFormat: image.PixelMapFormat.BGRA_8888,
      }

      this.pixelMapSrc = await this.imageSource.createPixelMap(decodingOptions);
      this.pixelMapDst = await copyPixelMap(this.pixelMapSrc);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'testTag', `init fail. code = ${err.code}, message = ${err.message}`);
    }
  }

  @Builder
  getCropTool() {
    Row() {
      List() {
        ForEach(cropTaskDates, (item: TaskData, index: number) => {
          ListItem() {
            Column() {
              Image(item.image)
                .width(ImageCropConstants.LIST_ITEM_LENGTH)
                .height(ImageCropConstants.LIST_ITEM_LENGTH)
                .margin({ top: $r('app.float.size_5') })
              Text(item.text)
                .fontColor(Color.White)
                .fontSize($r('app.float.size_14'))
                .margin({ top: $r('app.float.size_5'), bottom: $r('app.float.size_5') })
            }
            .backgroundColor(this.cropIndex === index ? $r('app.color.edit_image_public_background') :
            $r('app.color.edit_image_crop_select'))
            .justifyContent(FlexAlign.Center)
            .width(ImageCropConstants.PERCENT_TWENTY_FIVE)
            .onClick(async () => {
              if (item.task !== undefined) {
                if (item.task === this.currentCropTask) {
                  return;
                }
                this.currentCropTask = item.task;
              }
              this.cropIndex = index;
              if (this.currentCropTask === CropTasks.ORIGIN) {
                this.pixelMapDst = await this.imageSource!.createPixelMap();
              } else if (this.currentCropTask === CropTasks.ONE_ONE) {
                await this.cropImage(ImageCropConstants.ONE_ONE);
              } else if (this.currentCropTask === CropTasks.THREE_FOUR) {
                await this.cropImage(ImageCropConstants.THREE_FOUR);
              } else if (this.currentCropTask === CropTasks.NINE_SIXTH) {
                await this.cropImage(ImageCropConstants.NINE_SIXTH);
              }
            })
          }
        }, (item: TaskData, index: number) => item.task?.toString())
      }
      .listDirection(Axis.Horizontal)
      .width(ImageCropConstants.FULL_SCREEN)
      .height(ImageCropConstants.FULL_SCREEN)
    }
    .width(ImageCropConstants.FULL_SCREEN)
    .height(ImageCropConstants.LIST_HEIGHT)
    .margin({ bottom: $r('app.integer.list_margin') })
  }

  build() {
    Column() {
      Row() {
        Blank()
        Row({ space: ImageCropConstants.ROW_SPACE }) {
          Image($r('app.media.ic_public_save'))
            .height(ImageCropConstants.SAVE_LENGTH)
            .width(ImageCropConstants.SAVE_LENGTH)
            .onClick(() => {
              this.onSave();
            })
        }
      }
      .width(ImageCropConstants.FULL_SCREEN)
      .margin({ left: $r('app.integer.image_margin'), right: $r('app.integer.image_margin') })

      Row() {
        Image(this.pixelMapDst).objectFit(ImageFit.None)
      }
      .width(ImageCropConstants.FULL_SCREEN)
      .height(ImageCropConstants.PERCENT_SEVENTY)

      Blank()

      this.getCropTool();
    }
    .padding({
      top: $r('app.integer.padding_top'),
      left: $r('app.integer.components_padding'),
      right: $r('app.integer.components_padding'),
      bottom: this.bottomSafeHeight
    })
    .width(ImageCropConstants.FULL_SCREEN)
    .height(ImageCropConstants.FULL_SCREEN)
    .backgroundColor(Color.Black)
  }
}

