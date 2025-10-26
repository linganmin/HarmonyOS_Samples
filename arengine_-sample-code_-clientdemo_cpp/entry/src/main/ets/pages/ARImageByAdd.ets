/*
 * Copyright (c) 2024-2025 Huawei Device Co., Ltd.
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

import { display } from '@kit.ArkUI';
import { taskpool } from '@kit.ArkTS';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { resourceManager } from '@kit.LocalizationKit';
import { systemDateTime } from '@kit.BasicServicesKit';
import arEngineDemo from 'libentry.so';
import { Logger } from '../utils/Logger';

@Builder
export function ARImageByAddBuilder() {
  ARImageByAdd();
}

@Component
struct ARImageByAdd {
  pageInfos: NavPathStack = new NavPathStack();
  private imageAddFailedNumbers: number = 0;
  private imageAddNumbers: number = 0;
  private imagePathList: string[] = [];
  private isSurfaceDestroy: boolean = false;
  private interval: number = -1;
  private isUpdate: boolean = false;
  private xComponentId: string = 'ARImage';
  @State addImageLog: string = '';
  @State context: Context = this.getUIContext().getHostContext() as Context;
  private resMgr: resourceManager.ResourceManager = this.context.resourceManager;
  @State imageTotalNumbers: number = 0;
  @State private isImageAddComplete: boolean = false;
  @State rotation: number = display.getDefaultDisplaySync().rotation;
  @State showPage: boolean = true;
  private idStr: string = systemDateTime.getTime(false).toString() + this.xComponentId;

  build(): void {
    NavDestination() {
      RelativeContainer() {
        XComponent({ id: this.idStr, type: XComponentType.SURFACE, libraryname: 'entry' })
          .width('100%')
          .height('100%')
          .visibility(this.showPage ? Visibility.Visible : Visibility.None)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
          .onLoad(() => {
            Logger.info(`XComponent onLoad ${this.idStr}.`);
            this.interval = setInterval(() => {
              if (!this.isUpdate || !this.isImageAddComplete || this.imageAddNumbers === 0) {
                return;
              }
              arEngineDemo.update(this.idStr);
            }, 33) // Set the frame rate to 30 fps (with the frame refreshed every 33 ms).
          })
          .onDestroy(() => {
            Logger.info(`XComponent onDestroy ${this.idStr}.`);
            this.isSurfaceDestroy = true;
            clearInterval(this.interval);
          })

        Text(this.context.resourceManager.getStringByNameSync('add_image_msg_count') +
        this.imageTotalNumbers.toString() + '/' + this.imagePathList.length.toString() + '\n ' +
        this.context.resourceManager.getStringByNameSync('add_image_msg_success') +
        this.imageAddNumbers + ' \n' +
        this.context.resourceManager.getStringByNameSync('add_image_msg_fail') +
        this.imageAddFailedNumbers + '\n' + this.addImageLog)
          .width(300)
          .textAlign(TextAlign.Center)
          .fontColor(Color.Red)
          .visibility(!this.isImageAddComplete ? Visibility.Visible : Visibility.None)
          .alignRules({
            center: { anchor: '__container__', align: VerticalAlign.Center },
            middle: { anchor: '__container__', align: HorizontalAlign.Center }
          })
      }
    }
    .onBackPressed(() => {
      Logger.error('Failed to onBackPressed.');
      return false;
    })
    .onAppear(() => {
      arEngineDemo.init(this.resMgr);
      let config: Int32Array = new Int32Array([1, this.rotation]);
      arEngineDemo.start(this.idStr, config);

      try {
        Logger.info(`Image path length: ${this.imagePathList.length}.`);
        this.RegisterAddImageCallback();
        taskpool.execute(addImage, this.idStr, this.imagePathList, errcode).then(() => {
          Logger.info('Add image task complete.');
          emitter.emit('checkAddImageResult');
        })
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        Logger.error(`Failed to promise options error. Code: ${err.code}, message is ${err.message}.`);
      }
    })
    .onWillDisappear(() => {
      if (this.imageAddNumbers > 0) {
        arEngineDemo.saveImageDataBaseToLocal(this.idStr, this.context.filesDir);
      }
      arEngineDemo.stop(this.idStr);
    })
    .onShown(() => {
      this.isUpdate = true;
      arEngineDemo.show(this.idStr);
    })
    .onHidden(() => {
      this.isUpdate = false;
      if (!this.isSurfaceDestroy) {
        arEngineDemo.hide(this.idStr);
      }
    })
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
      this.imagePathList = context.pathInfo.param as string[];
    })
    .hideTitleBar(true)
    .hideBackButton(false)
    .hideToolBar(true)
  }

  private ShowDialog(msg: string): void {
    this.getUIContext().showAlertDialog({
      title: $r('app.string.warning'),
      message: msg,
      autoCancel: true,
      alignment: DialogAlignment.Center,
      offset: { dx: 0, dy: -20 },
      gridCount: 3,
      transition: TransitionEffect
        .asymmetric(TransitionEffect.OPACITY
          .animation({ duration: 1000, curve: Curve.Sharp })
          .combine(TransitionEffect
            .scale({ x: 1.5, y: 1.5 })
            .animation({ duration: 1000, curve: Curve.Sharp })
          ),
          TransitionEffect.OPACITY
            .animation({ duration: 100, curve: Curve.Smooth })
            .combine(TransitionEffect.scale({ x: 0.5, y: 0.5 })
              .animation({ duration: 100, curve: Curve.Smooth })
            )
        ),
      buttons: [{
        enabled: true,
        defaultFocus: true,
        style: DialogButtonStyle.HIGHLIGHT,
        value: $r('app.string.back'),
        action: () => {
          Logger.info('Callback when the second button is clicked');
          this.pageInfos.pop();
        }
      }]
    })
  }

  private RegisterAddImageCallback(): void {
    emitter.on('addImage', (data: emitter.EventData) => {
      if (data.data?.addImageReason === 0) {
        this.imageAddNumbers++;
        Logger.info(`Succeeded in adding image, image numbers: ${this.imageAddNumbers}.`);
      } else {
        this.imageAddFailedNumbers++;
        this.addImageLog += this.context.resourceManager.getStringByNameSync('image_name_by_add') +
          data.data?.imageName + '\n' +
          this.context.resourceManager.getStringByNameSync('image_add_reason_by_add') +
          errcode.get(data.data?.addImageReason) + '\n';
        Logger.error(`Failed to add image, image numbers: ${this.imageAddFailedNumbers}.`);
      }
      this.imageTotalNumbers++;
    })

    emitter.on('checkAddImageResult', () => {
      if (this.imageAddNumbers === 0 && this.isUpdate) {
        this.showPage = false;
        this.ShowDialog(this.context.resourceManager.getStringByNameSync('invalid_image_added'));
      }
      emitter.off('addImage');
      this.isImageAddComplete = true;
      emitter.off('checkAddImageResult');
    })
  }
}

let errcode: Map<number, string> = new Map<number, string>([[0, 'success'], [1, 'size not match'],
  [2, 'too bright or too dark'], [3, 'image color is relatively single'], [4, 'other error']]);

// Asynchronously execute the task of adding pictures
@Concurrent
async function addImage(componentId: string, imagePathList: string[],
  errcode: Map<number, string>): Promise<void> {
  for (let index = 0; index < imagePathList.length; index++) {
    const magePath: string = imagePathList[index];
    let file: fileIo.File = fileIo.openSync(magePath, fileIo.OpenMode.READ_ONLY);
    let imageName: string = file.name;
    const imageSourceApi: image.ImageSource = image.createImageSource(file.fd);
    try {
      fileIo.closeSync(file);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      Logger.error(`Failed to closeSync. Code is ${err.code}, message is ${err.message}.`);
      imageSourceApi.release();
      continue;
    }
    const imageInfo: image.ImageInfo = imageSourceApi.getImageInfoSync();
    if (!imageInfo) {
      Logger.error(`Failed to obtain the image pixel map information.`);
      imageSourceApi.release();
      continue;
    }
    const opts: image.DecodingOptions = {
      editable: true,
      desiredPixelFormat: image.PixelMapFormat.RGBA_8888,
      desiredSize: { width: imageInfo.size.width, height: imageInfo.size.height }
    }
    const pixelMap: image.PixelMap = imageSourceApi.createPixelMapSync(opts);
    if (!pixelMap) {
      Logger.error('Failed to create pixelMap.');
      imageSourceApi.release();
      continue;
    }
    const readBuffer: ArrayBuffer = new ArrayBuffer(pixelMap.getPixelBytesNumber());
    await pixelMap.readPixelsToBuffer(readBuffer);
    pixelMap.release();

    let result: number = arEngineDemo.initImage(componentId, imageInfo.size.width, imageInfo.size.height, readBuffer);
    if (errcode.has(result) === false) {
      Logger.error('Failed to add image, break.');
      imageSourceApi.release();
      break;
    }
    if (result !== 0) {
      Logger.error(`Failed to Add image, reason is: ${errcode.get(result)}, imageName is: ${imageName}.`);
    }
    let eventData: emitter.EventData = {
      data: {
        'addImageReason': result,
        'imageName': imageName,
      }
    }
    emitter.emit('addImage', eventData);
    imageSourceApi.release();
  }
}
