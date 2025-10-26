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

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { camera } from '@kit.CameraKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { JSON } from '@kit.ArkTS';
import { GlobalContext } from '../common/utils/GlobalContext';
import Logger from '../common/utils/Logger';
import { Constants } from '../common/Constants';
import { image } from '@kit.ImageKit';

const TAG: string = 'CameraService';

export class SliderValue {
  min: number = 1;
  max: number = 6;
  step: number = 0.1;
}

class CameraService {
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  private photoMode: string | undefined = undefined;
  private session: camera.PhotoSession | camera.VideoSession | undefined = undefined;
  private handlePhotoAssetCb: (photoAsset: photoAccessHelper.PhotoAsset | image.PixelMap) => void = () => {
  };
  private curCameraDevice: camera.CameraDevice | undefined = undefined;
  // One of the recommended photo resolution
  private photoProfileObj: camera.Profile = {
    format: 2000,
    size: {
      width: 1920,
      height: 1080
    }
  };
  // One of the recommended photo resolution
  private previewProfileObj: camera.Profile = {
    format: 1003,
    size: {
      width: 1920,
      height: 1080
    }
  };
  private curSceneMode: camera.SceneMode = camera.SceneMode.NORMAL_PHOTO;

  constructor() {
  }

  setSavePictureCallback(callback: (photoAsset: photoAccessHelper.PhotoAsset | image.PixelMap) => void): void {
    this.handlePhotoAssetCb = callback;
  }

  setSceneMode(sceneMode: camera.SceneMode): void {
    this.curSceneMode = sceneMode;
  }

  getSceneMode(): camera.SceneMode {
    return this.curSceneMode;
  }

  getPreviewProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | undefined {
    let previewProfiles = cameraOutputCapability.previewProfiles;
    if (previewProfiles.length < 1) {
      return undefined;
    }
    let index = previewProfiles.findIndex((previewProfile: camera.Profile) => {
      return previewProfile.size.width === this.previewProfileObj.size.width &&
        previewProfile.size.height === this.previewProfileObj.size.height &&
        previewProfile.format === this.previewProfileObj.format;
    });
    if (index === -1) {
      return undefined;
    }
    return previewProfiles[index];
  }

  getPhotoProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | undefined {
    let photoProfiles = cameraOutputCapability.photoProfiles;
    if (photoProfiles.length < 1) {
      return undefined;
    }
    let index = photoProfiles.findIndex((photoProfile: camera.Profile) => {
      return photoProfile.size.width === this.photoProfileObj.size.width &&
        photoProfile.size.height === this.photoProfileObj.size.height &&
        photoProfile.format === this.photoProfileObj.format;
    });
    if (index === -1) {
      return undefined;
    }
    return photoProfiles[index];
  }

  isSupportedSceneMode(cameraManager: camera.CameraManager, cameraDevice: camera.CameraDevice): boolean {
    let sceneModes = cameraManager.getSupportedSceneModes(cameraDevice);
    if (sceneModes === undefined) {
      return false;
    }
    let index = sceneModes.findIndex((sceneMode: camera.SceneMode) => {
      return sceneMode === this.curSceneMode;
    });
    if (index === -1) {
      return false;
    }
    return true;
  }

  // [Start init_camera]
  /**
   * Initialize Camera Functions
   * @param surfaceId - Surface ID
   * @param cameraDeviceIndex - Camera Device Index
   * @returns No return value
   */
  async initCamera(surfaceId: string, cameraDeviceIndex: number): Promise<void> {
    Logger.debug(TAG, `initCamera cameraDeviceIndex: ${cameraDeviceIndex}`);
    this.photoMode = AppStorage.get('photoMode');
    if (!this.photoMode) {
      return;
    }
    try {
      await this.releaseCamera();
      // Get Camera Manager Instance
      this.cameraManager = this.getCameraManagerFn();
      if (this.cameraManager === undefined) {
        Logger.error(TAG, 'cameraManager is undefined');
        return;
      }
      // Gets the camera device object that supports the specified
      this.cameras = this.getSupportedCamerasFn(this.cameraManager);
      if (this.cameras.length < 1 || this.cameras.length < cameraDeviceIndex + 1) {
        return;
      }
      this.curCameraDevice = this.cameras[cameraDeviceIndex];
      let isSupported = this.isSupportedSceneMode(this.cameraManager, this.curCameraDevice);
      if (!isSupported) {
        Logger.error(TAG, 'The current scene mode is not supported.');
        return;
      }
      let cameraOutputCapability =
        this.cameraManager.getSupportedOutputCapability(this.curCameraDevice, this.curSceneMode);
      let previewProfile = this.getPreviewProfile(cameraOutputCapability);
      if (previewProfile === undefined) {
        Logger.error(TAG, 'The resolution of the current preview stream is not supported.');
        return;
      }
      this.previewProfileObj = previewProfile;
      // Creates the previewOutput output object
      this.previewOutput = this.createPreviewOutputFn(this.cameraManager, this.previewProfileObj, surfaceId);
      if (this.previewOutput === undefined) {
        Logger.error(TAG, 'Failed to create the preview stream.');
        return;
      }
      // Listening for preview events
      this.previewOutputCallBack(this.previewOutput);
      let photoProfile = this.getPhotoProfile(cameraOutputCapability);
      if (photoProfile === undefined) {
        Logger.error(TAG, 'The resolution of the current photo stream is not supported.');
        return;
      }
      this.photoProfileObj = photoProfile;
      // Creates a photoOutPut output object
      this.photoOutput = this.createPhotoOutputFn(this.cameraManager, this.photoProfileObj);
      if (this.photoOutput === undefined) {
        Logger.error(TAG, 'Failed to create the photo stream.');
        return;
      }
      // Creates a cameraInput output object
      this.cameraInput = this.createCameraInputFn(this.cameraManager, this.curCameraDevice);
      if (this.cameraInput === undefined) {
        Logger.error(TAG, 'Failed to create the camera input.');
        return;
      }
      // Turn on the camera
      let isOpenSuccess = await this.cameraInputOpenFn(this.cameraInput);
      if (!isOpenSuccess) {
        Logger.error(TAG, 'Failed to open the camera.');
        return;
      }
      // Camera status callback
      this.onCameraStatusChange(this.cameraManager);
      // Listens to CameraInput error events
      this.onCameraInputChange(this.cameraInput, this.curCameraDevice);
      // Session Process
      await this.sessionFlowFn(this.cameraManager, this.cameraInput, this.previewOutput, this.photoOutput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `initCamera fail: ${JSON.stringify(err)}`);
    }
  }

  // [End init_camera]

  /**
   * Obtains the variable focal length range
   */
  getZoomRatioRange(): Array<number> {
    let zoomRatioRange: Array<number> = [];
    if (this.session !== undefined) {
      try {
        zoomRatioRange = this.session.getZoomRatioRange();
      } catch (error) {
        let err = error as BusinessError;
        Logger.warn('testTag', `getZoomRatioRange failed, code=${err.code}, message=${err.message}`);
      }
    }
    return zoomRatioRange;
  }

  /**
   * Zoom
   */
  setZoomRatioFn(zoomRatio: number): void {
    Logger.info(TAG, `setZoomRatioFn value ${zoomRatio}`);
    // Get the supported zoom range
    try {
      let zoomRatioRange = this.getZoomRatioRange();
      Logger.info(TAG, `getZoomRatioRange success: ${JSON.stringify(zoomRatioRange)}`);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getZoomRatioRange fail: ${JSON.stringify(err)}`);
    }

    try {
      this.session?.setZoomRatio(zoomRatio);
      Logger.info(TAG, 'setZoomRatioFn success');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `setZoomRatioFn fail: ${JSON.stringify(err)}`);
    }
  }

  // [Start take_picture]
  /**
   * Trigger a photo taking based on the specified parameters
   */
  async takePicture(): Promise<void> {
    Logger.info(TAG, 'takePicture start');
    let cameraDeviceIndex = GlobalContext.get().getT<number>('cameraDeviceIndex');
    let photoSettings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
      mirror: cameraDeviceIndex ? true : false
    };
    try {
      await this.photoOutput?.capture(photoSettings);
      Logger.info(TAG, 'takePicture end');
    } catch (error) {
      let err = error as BusinessError;
      Logger.warn('testTag', `capture failed, code=${err.code}, message=${err.message}`);
    }
  }

  // [End take_picture]

  /**
   * Release the session and related parameters
   */
  async releaseCamera(): Promise<void> {
    Logger.info(TAG, 'releaseCamera is called');
    try {
      await this.previewOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `previewOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.previewOutput = undefined;
    }
    try {
      await this.photoOutput?.release();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `photoOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.photoOutput = undefined;
    }
    try {
      await this.session?.release();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `captureSession release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.session = undefined;
    }
    try {
      await this.cameraInput?.close();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `cameraInput close fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.cameraInput = undefined;
    }
    this.offCameraStatusChange();
    Logger.info(TAG, 'releaseCamera success');
  }

  /**
   * Get Camera Manager Instance
   */
  getCameraManagerFn(): camera.CameraManager | undefined {
    if (this.cameraManager) {
      return this.cameraManager;
    }
    let cameraManager: camera.CameraManager;
    try {
      cameraManager = camera.getCameraManager(GlobalContext.get().getCameraSettingContext());
      Logger.info(TAG, `getCameraManager success: ${cameraManager}`);
      return cameraManager;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getCameraManager failed: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  /**
   * Gets the camera device object that supports the specified
   */
  getSupportedCamerasFn(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
    let supportedCameras: Array<camera.CameraDevice> = [];
    try {
      supportedCameras = cameraManager.getSupportedCameras();
      Logger.info(TAG, `getSupportedCameras success: ${this.cameras}, length: ${this.cameras?.length}`);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getSupportedCameras failed: ${JSON.stringify(err)}`);
    }
    return supportedCameras;
  }

  /**
   * Creates the previewOutput output object
   */
  createPreviewOutputFn(cameraManager: camera.CameraManager, previewProfileObj: camera.Profile,
    surfaceId: string): camera.PreviewOutput | undefined {
    let previewOutput: camera.PreviewOutput;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfileObj, surfaceId);
      Logger.info(TAG, `createPreviewOutput success: ${previewOutput}`);
      return previewOutput;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createPreviewOutput failed: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  // [Start create_photo_outputFn]
  /**
   * Creates a photoOutPut output object
   */
  createPhotoOutputFn(cameraManager: camera.CameraManager,
    photoProfileObj: camera.Profile): camera.PhotoOutput | undefined {
    let photoOutput: camera.PhotoOutput;
    try {
      photoOutput = cameraManager.createPhotoOutput(photoProfileObj);
      Logger.info(TAG, `createPhotoOutputFn success: ${photoOutput}`);
      return photoOutput;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createPhotoOutputFn failed: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  // [End create_photo_outputFn]

  /**
   * Creating a videoOutPut Output Object
   */
  createVideoOutputFn(cameraManager: camera.CameraManager, videoProfileObj: camera.VideoProfile,
    surfaceId: string): camera.VideoOutput | undefined {
    let videoOutput: camera.VideoOutput;
    try {
      videoOutput = cameraManager.createVideoOutput(videoProfileObj, surfaceId);
      Logger.info(TAG, `createVideoOutputFn success: ${videoOutput}`);
      return videoOutput;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createVideoOutputFn failed: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  /**
   * Creates a cameraInput output object
   */
  createCameraInputFn(cameraManager: camera.CameraManager,
    cameraDevice: camera.CameraDevice): camera.CameraInput | undefined {
    Logger.info(TAG, 'createCameraInputFn is called.');
    let cameraInput: camera.CameraInput;
    try {
      cameraInput = cameraManager.createCameraInput(cameraDevice);
      Logger.info(TAG, 'createCameraInputFn success');
      return cameraInput;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createCameraInputFn failed: ${JSON.stringify(err)}`);
      return undefined;
    }
  }

  /**
   * Turn on the camera
   */
  async cameraInputOpenFn(cameraInput: camera.CameraInput): Promise<boolean> {
    let isOpenSuccess = false;
    try {
      await cameraInput.open();
      isOpenSuccess = true;
      Logger.info(TAG, 'cameraInput open success');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createCameraInput failed : ${JSON.stringify(err)}`);
    }
    return isOpenSuccess;
  }

  /**
   * Session Process
   */
  async sessionFlowFn(cameraManager: camera.CameraManager, cameraInput: camera.CameraInput,
    previewOutput: camera.PreviewOutput, photoOutput: camera.PhotoOutput | undefined): Promise<void> {
    try {
      // Creating a CaptureSession Instance
      if (this.curSceneMode === camera.SceneMode.NORMAL_PHOTO) {
        this.session = cameraManager.createSession(this.curSceneMode) as camera.PhotoSession;
      } else if (this.curSceneMode === camera.SceneMode.NORMAL_VIDEO) {
        this.session = cameraManager.createSession(this.curSceneMode) as camera.VideoSession;
      }
      if (this.session === undefined) {
        return;
      }
      this.onSessionErrorChange(this.session);
      // Start configuring session
      this.session.beginConfig();
      // Add CameraInput to the session.
      this.session.addInput(cameraInput);
      // Add previewOutput to the session.
      this.session.addOutput(previewOutput);
      if (photoOutput === undefined) {
        return;
      }
      // Photographing and listening events
      this.photoOutputCallBack(photoOutput);
      // Add photoOutPut to the session.
      this.session.addOutput(photoOutput);
      // Submit the configuration information.
      await this.session.commitConfig();
      this.setFocusMode(camera.FocusMode.FOCUS_MODE_AUTO);
      // Start Session Work
      await this.session.start();
      Logger.info(TAG, 'sessionFlowFn success');
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `sessionFlowFn fail : ${JSON.stringify(err)}`);
    }
  }

  /**
   * Listening to photographing events
   */
  photoOutputCallBack(photoOutput: camera.PhotoOutput): void {
    try {
      // Listening and photographing start
      photoOutput.on('captureStartWithInfo', (err: BusinessError, captureStartInfo: camera.CaptureStartInfo): void => {
        if (err) {
          Logger.error(TAG, `captureStartWithInfo err:${err.code}`);
          return;
        }
        Logger.info(TAG, `photoOutputCallBack captureStartWithInfo success: ${JSON.stringify(captureStartInfo)}`);
      });
      // Monitors and captures the output of photographed frames
      photoOutput.on('frameShutter', (err: BusinessError, frameShutterInfo: camera.FrameShutterInfo): void => {
        if (err) {
          Logger.error(TAG, `frameShutter err:${err.code}`);
          return;
        }
        Logger.info(TAG, `photoOutputCallBack frameShutter captureId:
          ${frameShutterInfo.captureId}, timestamp: ${frameShutterInfo.timestamp}`);
      });
      // Listening and photographing are complete
      photoOutput.on('captureEnd', (err: BusinessError, captureEndInfo: camera.CaptureEndInfo): void => {
        if (err) {
          Logger.error(TAG, `captureEnd err:${err.code}`)
          return;
        }
        Logger.info(TAG, `photoOutputCallBack captureEnd captureId:
          ${captureEndInfo.captureId}, frameCount: ${captureEndInfo.frameCount}`);
      });
      // Listening and photographing are abnormal
      photoOutput.on('error', (data: BusinessError): void => {
        Logger.error(TAG, `photoOutPut data: ${JSON.stringify(data)}`);
      });
      if (this.photoMode === Constants.SUBSECTION_MODE) {
        // [Start listen_photo_asset_available]
        photoOutput.on('photoAssetAvailable', (err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset) => {
          Logger.info(TAG, 'photoAssetAvailable begin');
          if (err) {
            Logger.error(TAG, `photoAssetAvailable err:${err.code}`);
            return;
          }
          this.handlePhotoAssetCb(photoAsset);
        });
        // [End listen_photo_asset_available]
      } else if (this.photoMode === Constants.SINGLE_STAGE_MODE) {
        // [Start listen_photo_available]
        photoOutput.on('photoAvailable', (err: BusinessError, photo: camera.Photo) => {
          Logger.info(TAG, 'photoAvailable begin');
          if (err) {
            Logger.error(TAG, `photoAvailable err:${err.code}`);
            return;
          }
          let imageObj: image.Image = photo.main;
          imageObj.getComponent(image.ComponentType.JPEG, (err: BusinessError, component: image.Component) => {
            Logger.info(TAG, `getComponent start`);
            if (err) {
              Logger.error(TAG, `getComponent err:${err.code}`);
              return;
            }
            let buffer: ArrayBuffer = component.byteBuffer;
            let imageSource: image.ImageSource = image.createImageSource(buffer);
            imageSource.createPixelMap((err: BusinessError, pixelMap: image.PixelMap) => {
              if (err) {
                Logger.error(TAG, `createPixelMap err:${err.code}`);
                return;
              }
              this.handlePhotoAssetCb(pixelMap);
            });

          });
        })
        // [End listen_photo_available]
      }
    } catch (err) {
      Logger.error(TAG, 'photoOutputCallBack error');
    }
  }

  /**
   * Listening for preview events
   */
  previewOutputCallBack(previewOutput: camera.PreviewOutput): void {
    Logger.info(TAG, 'previewOutputCallBack is called');
    try {
      previewOutput.on('frameStart', (): void => {
        Logger.debug(TAG, 'Preview frame started');
      });
      previewOutput.on('frameEnd', (): void => {
        Logger.debug(TAG, 'Preview frame ended');
      });
      previewOutput.on('error', (previewOutputError: BusinessError): void => {
        Logger.info(TAG, `Preview output previewOutputError: ${JSON.stringify(previewOutputError)}`);
      });
    } catch (err) {
      Logger.error(TAG, 'previewOutputCallBack error');
    }
  }

  /**
   * Registers the callback function for changing the camera status.
   * @param err - Error information
   * @param cameraStatusInfo - Camera status information
   * @returns No return value
   */
  registerCameraStatusChange(err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo): void {
    if (err) {
      Logger.info(TAG, `registerCameraStatusChange err:${err.code}`)
      return;
    }
    Logger.info(TAG, `cameraId: ${cameraStatusInfo.camera.cameraId},status: ${cameraStatusInfo.status}`);
  }

  /**
   * Monitors camera status changes
   * @param cameraManager - Camera Manager object
   * @returns No return value
   */
  onCameraStatusChange(cameraManager: camera.CameraManager): void {
    Logger.info(TAG, 'onCameraStatusChange is called');
    try {
      cameraManager.on('cameraStatus', this.registerCameraStatusChange);
    } catch (error) {
      Logger.error(TAG, 'onCameraStatusChange error');
    }
  }

  /**
   * Stop listening to camera status changes
   * @returns No return value
   */
  offCameraStatusChange(): void {
    Logger.info(TAG, 'offCameraStatusChange is called');
    this.cameraManager?.off('cameraStatus', this.registerCameraStatusChange);
  }

  /**
   * Listen for camera input changes
   * @param cameraInput - Camera Input Object
   * @param cameraDevice - Camera device object
   * @returns No return value
   */
  onCameraInputChange(cameraInput: camera.CameraInput, cameraDevice: camera.CameraDevice): void {
    Logger.info(TAG, `onCameraInputChange is called`);
    try {
      cameraInput.on('error', cameraDevice, (cameraInputError: BusinessError): void => {
        Logger.info(TAG, `onCameraInputChange cameraInput error code: ${cameraInputError.code}`);
      });
    } catch (error) {
      Logger.error(TAG, 'onCameraInputChange error');
    }
  }

  /**
   * Listening Capture Session Error Change
   * @param session - Camera capture session object
   * @returns No return value
   */
  onSessionErrorChange(session: camera.PhotoSession | camera.VideoSession): void {
    try {
      session.on('error', (captureSessionError: BusinessError): void => {
        Logger.info(TAG,
          'onCaptureSessionErrorChange captureSession fail: ' + JSON.stringify(captureSessionError.code));
      });
    } catch (error) {
      Logger.error(TAG, 'onCaptureSessionErrorChange error');
    }
  }

  /**
   * Focus mode
   */
  setFocusMode(focusMode: camera.FocusMode): void {
    try {
      // Check whether the focus mode is supported
      let isSupported = this.session?.isFocusModeSupported(focusMode);
      Logger.info(TAG, `setFocusMode isSupported: ${isSupported}`);
      // Setting the Focus Mode
      if (!isSupported) {
        return;
      }
      this.session?.setFocusMode(focusMode);
    } catch (error) {
      let err = error as BusinessError;
      Logger.warn('testTag', `isFocusModeSupported or setFocusMode failed, code=${err.code}, message=${err.message}`);
    }
  }
}

export default new CameraService();