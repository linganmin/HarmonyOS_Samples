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
import { CommonConstants } from '../common/CommonConstants'
import Logger from '../utils/Logger'
import { Context } from '@ohos.arkui.UIContext'
import { camera } from '@kit.CameraKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { photoAccessHelper } from '@kit.MediaLibraryKit'
import { sensor } from '@kit.SensorServiceKit'
import { display } from '@kit.ArkUI'

class CameraService {
  public supperCameraArr: camera.CameraDevice[] = [];
  private tag: string = 'CameraService';
  private cameraManager: camera.CameraManager | undefined = undefined;
  private photoSession: camera.PhotoSession | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private currentContext: Context | undefined = undefined;
  private rotation: camera.ImageRotation = camera.ImageRotation.ROTATION_0;
  private takePhotoCallback: ((photoAsset: photoAccessHelper.PhotoAsset) => void) | undefined = undefined;
  private isMirror: boolean = false;

  constructor() {
  }

  async initCamera(context: Context, cameraIndex: number, surfaceId: string) {
    this.currentContext = context;
    this.releaseCamera()
    this.cameraManager = camera.getCameraManager(this.currentContext)
    let supperCameras = this.cameraManager.getSupportedCameras();
    this.distinguishCamera(supperCameras);
    let cameraDevice = this.supperCameraArr[cameraIndex];
    this.isMirror = cameraDevice.cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT;
    let cameraOutputCapability =
      this.cameraManager.getSupportedOutputCapability(cameraDevice, camera.SceneMode.NORMAL_PHOTO);
    this.createCameraInputFn(cameraDevice);

    this.cameraInput?.open()
    let photoProfileObj = cameraOutputCapability.photoProfiles[0]
    let previewProfileObj = cameraOutputCapability.previewProfiles[0]
    photoProfileObj.size.width = CommonConstants.CAMERA_SIZE[0].width
    photoProfileObj.size.height = CommonConstants.CAMERA_SIZE[0].height
    previewProfileObj.size.width = CommonConstants.CAMERA_SIZE[0].width
    previewProfileObj.size.height = CommonConstants.CAMERA_SIZE[0].height
    this.createPreviewOutputFn(previewProfileObj, surfaceId)
    this.createPhotoOutputFn(photoProfileObj)
    this.photoOutPutCallBack()
    this.sessionFlowFn()
  }

  private distinguishCamera(cameras: Array<camera.CameraDevice>) {
    this.supperCameraArr.length = 0;
    cameras.forEach((item: camera.CameraDevice) => {
      if (item.connectionType === camera.ConnectionType.CAMERA_CONNECTION_BUILT_IN) {
        this.supperCameraArr.push(item);
      }
    });
    Logger.debug(this.tag,
      `distinguishCamera cameras: ${cameras.length}, supperCameraArr: ${this.supperCameraArr.length}`)
  }

  async releaseCamera() {
    this.previewOutput?.release()
    this.photoOutput?.release()
    this.photoSession?.stop();
    this.photoSession?.release();
    this.cameraInput?.close()
  }

  private async createCameraInputFn(camera: camera.CameraDevice) {
    try {
      this.cameraInput = this.cameraManager?.createCameraInput(camera)
      Logger.info(this.tag, `createCameraInputFn success: ${this.cameraInput}`)
    } catch (err) {
      Logger.error(this.tag, `createCameraInputFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  private async createPreviewOutputFn(previewProfile: camera.Profile, surfaceId: string) {
    try {
      Logger.info(this.tag, `createPreviewOutputFn previewProfilesObj success: ` + JSON.stringify(previewProfile))
      this.previewOutput = this.cameraManager?.createPreviewOutput(previewProfile, surfaceId.toString())
      Logger.info(this.tag, `createPreviewOutputFn success: ` + JSON.stringify(this.previewOutput))
    } catch (err) {
      Logger.error(this.tag, `createPreviewOutputFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  private async createPhotoOutputFn(photoProfile: camera.Profile) {
    try {
      Logger.info(this.tag, `createPhotoOutputFn photoProfileObj success: ` + JSON.stringify(photoProfile))
      this.photoOutput = this.cameraManager?.createPhotoOutput(photoProfile)
      Logger.info(this.tag, `createPhotoOutputFn success: ` + JSON.stringify(this.photoOutput))
    } catch (err) {
      Logger.error(this.tag, `createPhotoOutputFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  /**
   * Photo out put callback
   * @param photoOutput
   */
  private photoOutPutCallBack(): void {
    // Saving camera Photo
    this.photoOutput?.on('photoAssetAvailable',
      async (err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset): Promise<void> => {
        if (err) {
          Logger.error(this.tag, `getPhoto failed err: ${err.code}`);
          return;
        }
        try {
          let accessHelper: photoAccessHelper.PhotoAccessHelper =
            photoAccessHelper.getPhotoAccessHelper(this.currentContext);
          let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
            new photoAccessHelper.MediaAssetChangeRequest(photoAsset);
          assetChangeRequest.saveCameraPhoto();
          await accessHelper.applyChanges(assetChangeRequest);
          Logger.info(this.tag, 'apply saveCameraPhoto successfully');
          if (this.takePhotoCallback !== undefined) {
            this.takePhotoCallback(photoAsset);
          }
        } catch (err) {
          Logger.error(this.tag, `apply saveCameraPhoto failed with error: ${err.code}, ${err.message}`);
        }
      });
  }

  /**
   * Session
   */
  private async sessionFlowFn() {
    try {
      // create captureSession
      Logger.info(this.tag, `sessionFlowFn success`)
      this.photoSession = this.cameraManager?.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
      if (this.photoSession === undefined) {
        Logger.error(this.tag, `sessionFlowFn photoSession is failed`)
        return;
      }
      // Begin session config
      this.photoSession?.beginConfig()

      // Add cameraInput to session
      Logger.info(this.tag, `cameraInput success: ` + JSON.stringify(this.cameraInput))
      if (this.cameraInput) {
        this.photoSession?.addInput(this.cameraInput)
      }
      // Add preview output to session
      this.photoSession?.addOutput(this.previewOutput)
      // Add photo output to session
      this.photoSession?.addOutput(this.photoOutput)
      // Commit session config
      await this.photoSession?.commitConfig()
      // set preview rotation
      this.setPreviewRotation()
      // Start session
      await this.photoSession?.start()
    } catch (err) {
      Logger.info(this.tag, `sessionFlowFn fail err: ${err}, message: ${err.message}, code: ${err.code}`)
    }
  }

  private setPreviewRotation() {
    try {
      let initDisplayRotation = display.getDefaultDisplaySync().rotation;
      let imageRotation = initDisplayRotation * camera.ImageRotation.ROTATION_90;
      this.previewOutput?.setPreviewRotation(this.previewOutput?.getPreviewRotation(imageRotation), false);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(this.tag, `The previewOutput.getPreviewRotation call failed. error code: ${err.code}`);
    }
  }

  private getPhotoRotation(): camera.ImageRotation {
    let photoRotation: camera.ImageRotation = camera.ImageRotation.ROTATION_0;
    try {
      photoRotation = this.photoOutput?.getPhotoRotation(this.rotation) ?? camera.ImageRotation.ROTATION_0;
      Logger.info(this.tag, `Photo rotation is: ${photoRotation}`);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(this.tag, `The photoOutput.getPhotoRotation call failed. error code: ${err.code}`);
    }
    return photoRotation;
  }

  takePhoto() {
    let settings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
      rotation: this.getPhotoRotation(),
      mirror: this.isMirror
    };
    this.photoOutput?.capture(settings);
  }

  // [Start set_enable_live_photo]
  setEnableLivePhoto(isMovingPhoto: boolean) {
    if (this.photoOutput?.isMovingPhotoSupported()) {
      this.photoOutput?.enableMovingPhoto(isMovingPhoto);
    }
  }

  // [End set_enable_live_photo]

  register() {
    if (!canIUse('SystemCapability.Sensors.Sensor')) {
      return;
    }
    sensor.on(sensor.SensorId.GRAVITY, (data: sensor.GravityResponse) => {
      let degree: number = -1;
      degree = this.getCalDegree(data.x, data.y, data.z);
      if (degree >= 0 && (degree <= 30 || degree >= 330)) {
        this.rotation = camera.ImageRotation.ROTATION_0;
      } else if (degree >= 60 && degree <= 120) {
        // Use ROTATION_90 when degree range is [60, 120]
        this.rotation = camera.ImageRotation.ROTATION_90;
      } else if (degree >= 150 && degree <= 210) {
        // Use ROTATION_180 when degree range is [150, 210]
        this.rotation = camera.ImageRotation.ROTATION_180;
      } else if (degree >= 240 && degree <= 300) {
        // Use ROTATION_270 when degree range is [240, 300]
        this.rotation = camera.ImageRotation.ROTATION_270;
      }
    });
  }

  unRegister() {
    sensor.off(sensor.SensorId.GRAVITY);
  }

  setTakePhotoCallback(callback?: (photoAsset: photoAccessHelper.PhotoAsset) => void) {
    this.takePhotoCallback = callback;
  }

  private getCalDegree(x: number, y: number, z: number): number {
    let degree: number = -1;
    // three is Effective Delta Angle Threshold Coefficient
    if ((x * x + y * y) * 3 < z * z) {
      return degree;
    }
    degree = 90 - (Number)(Math.round(Math.atan2(y, -x) / Math.PI * 180));
    return degree >= 0 ? degree % 360 : degree % 360 + 360;
  }
}

export default new CameraService()