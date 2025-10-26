/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { abilityAccessCtrl } from '@kit.AbilityKit';
import { common } from '@kit.AbilityKit';
import { display } from '@kit.ArkUI';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { dataSharePredicates } from '@kit.ArkData';
import { image } from '@kit.ImageKit';
import cameraDemo from 'libentry.so';
import Logger from '../common/utils/Logger';
import { DividerPage } from '../views/DividerPage';
import { ModeSwitchPage } from '../views/ModeSwitchPage';
import { FocusPage } from '../views/FocusPage';
import { FocusAreaPage } from '../views/FocusAreaPage';
import { Constants } from '../common/Constants';
import { SettingDataObj } from '../common/Constants';
import DisplayCalculator from '../common/DisplayCalculator';

const TAG: string = 'UI indexPage';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.UIAbilityContext;

@Entry
@Component
struct Index {
  // surfaceID value.
  @State surfaceId: string = '';
  // Select mode.
  @State modelBagCol: string = 'photo';
  // Exposure area.
  @State focusPointBol: boolean = false;
  // Finger click coordinates in the exposure area.
  @State focusPointVal: Array<number> = [0, 0];
  // Display where scale, focal length value, and focus box cannot coexist.
  @State exposureBol: boolean = true;
  // Exposure value.
  @State exposureNum: number = 0;
  // Countdown, photography, and video recording.
  @State countdownNum: number = 0;
  // Front and rear cameras.
  @State cameraDeviceIndex: number = 0;
  @State xComponentWidth: number = 384;
  @State xComponentHeight: number = 450;
  // Reference line.
  @State referenceLineBol: boolean = false;
  @State onShow: boolean = false;
  @StorageLink('defaultAspectRatio') @Watch('initXComponentSize') defaultAspectRatio: number
    = Constants.MIN_ASPECT_RATIO;
  @StorageLink('ratioXC') ratioXC: number = 0.0;
  // Thumbnails
  @StorageLink('thumbnail') thumbnail: image.PixelMap | undefined | string = '';
  // XComponentController.
  private mXComponentController: XComponentController = new XComponentController();
  private options: XComponentOptions = {
    type: XComponentType.SURFACE,
    controller: this.mXComponentController
  }
  private screenHeight: number = 0;
  private screenWidth: number = 0;
  private settingDataObj: SettingDataObj = {
    mirrorBol: false,
    videoStabilizationMode: 0,
    exposureMode: 1,
    focusMode: 2,
    photoQuality: 1,
    locationBol: false,
    photoFormat: 1,
    photoOrientation: 0,
    photoResolution: 0,
    videoResolution: 0,
    videoFrame: 0,
    referenceLineBol: false
  };
  private appContext: common.Context = this.getUIContext().getHostContext()!;
  atManager = abilityAccessCtrl.createAtManager();

  // Entry initialization function.
  async aboutToAppear() {
    try {
      await this.requestPermissionsFn();
      let mDisplay = display.getDefaultDisplaySync();
      this.screenWidth = this.getUIContext().px2vp(mDisplay.width);
      this.screenHeight = this.getUIContext().px2vp(mDisplay.height);
      this.initXComponentSize();
    } catch (e) {
      Logger.error(TAG, `getDefaultDisplaySync error ${JSON.stringify(e)}`);
    }
  }

  initXComponentSize(): void {
    let defaultSize =
      DisplayCalculator.calcSurfaceDisplaySize(this.screenWidth, this.screenHeight, this.defaultAspectRatio);
    this.xComponentWidth = defaultSize.width;
    this.xComponentHeight = defaultSize.height;
    if (defaultSize.width > defaultSize.height) {
      this.ratioXC = defaultSize.width / defaultSize.height;
    } else {
      this.ratioXC = defaultSize.height / defaultSize.width;
    }
  }

  async aboutToDisAppear() {
    cameraDemo.releaseCamera();
  }

  // Obtain permissions.
  async requestPermissionsFn() {
    Logger.info(TAG, `requestPermissionsFn entry`);
    try {
      this.atManager.requestPermissionsFromUser(this.appContext, [
        'ohos.permission.CAMERA',
        'ohos.permission.MICROPHONE',
        'ohos.permission.WRITE_IMAGEVIDEO'
      ]).then(() => {
        Logger.info(TAG, `request Permissions success!`);
        this.onShow = true;
        this.getThumbnail();
      });
    } catch (err) {
      Logger.error(TAG, `requestPermissionsFromUser call Failed! error: ${err.code}`);
    }
  }

  async getThumbnail() {
    try {
      let phAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
      let predicates: dataSharePredicates.DataSharePredicates = new dataSharePredicates.DataSharePredicates();
      let fetchOptions: photoAccessHelper.FetchOptions = {
        fetchColumns: [],
        predicates: predicates
      };
      let fetchResult: photoAccessHelper.FetchResult<photoAccessHelper.PhotoAsset> =
        await phAccessHelper.getAssets(fetchOptions);
      let asset: photoAccessHelper.PhotoAsset = await fetchResult.getLastObject();
      console.info('asset displayName = ', asset.displayName);
      asset.getThumbnail((err, pixelMap) => {
        if (err === undefined) {
          this.thumbnail = pixelMap;
          console.info('getThumbnail successful ' + pixelMap);
        } else {
          console.error(`getThumbnail fail with error: ${err.code}, ${err.message}`);
        }
      });
    } catch (e) {
      Logger.error(TAG, `getThumbnail error ${JSON.stringify(e)}`);
    }
  }

  async onPageShow() {
    Logger.info(TAG, `onPageShow App`);
    if (this.surfaceId && this.onShow) {
      Logger.error(TAG, `initCamera start`);
      cameraDemo.initCamera(this.surfaceId, this.settingDataObj.focusMode, this.cameraDeviceIndex, this.ratioXC);
      Logger.error(TAG, `initCamera end`);
    }
    this.getThumbnail();
  }

  onPageHide() {
    Logger.info(TAG, `onPageHide App`);
    this.thumbnail = '';
  }

  build() {
    Stack() {
      if (this.onShow) {
        // General appearance of a picture.
        XComponent(this.options)
          .onLoad(async () => {
            Logger.info(TAG, 'onLoad is called');
            this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
            Logger.info(TAG, `onLoad surfaceId: ${this.surfaceId}`);
            Logger.info(TAG, `initCamera start`);
            cameraDemo.initCamera(this.surfaceId, this.settingDataObj.focusMode, this.cameraDeviceIndex, this.ratioXC);
            Logger.info(TAG, `initCamera end`);
          })
          .backgroundColor(Color.Black)
          .width(Constants.FULL_PERCENT)
          .height(Constants.SEVENTY_PERCENT)
          .margin({
            bottom: Constants.FIFTEEN_PERCENT
          })

        // Reference line.
        DividerPage({ referenceLineBol: this.referenceLineBol });
        // Exposure frame and focus frame.
        FocusPage({
          focusPointBol: $focusPointBol,
          focusPointVal: $focusPointVal,
          exposureBol: $exposureBol,
          exposureNum: $exposureNum
        });
        // Exposure focusing finger click area.
        FocusAreaPage({
          focusPointBol: $focusPointBol,
          focusPointVal: $focusPointVal,
          exposureBol: $exposureBol,
          exposureNum: $exposureNum,
          xComponentWidth: this.xComponentWidth,
          xComponentHeight: this.xComponentHeight
        });
        // Reverse camera_Multiple workstations_Take photos_Video.
        ModeSwitchPage({
          surfaceId: this.surfaceId,
          cameraDeviceIndex: $cameraDeviceIndex,
          countdownNum: $countdownNum
        });
      }
    }
    .height(Constants.FULL_PERCENT)
    .width(Constants.FULL_PERCENT)
    .backgroundColor(Color.Black)
  }
}