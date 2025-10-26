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

import { BusinessError } from '@kit.BasicServicesKit';
import { Constants } from '../common/Constants';
import { camera } from '@kit.CameraKit';
import { image } from '@kit.ImageKit';
import { JSON } from '@kit.ArkTS';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import Logger from './Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG: string = 'CameraService';

class CameraService {
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameras: Array<camera.CameraDevice> | Array<camera.CameraDevice> = [];
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private session: camera.PhotoSession | camera.VideoSession | undefined = undefined;
  handlePhotoAssetCb: (photoAsset: photoAccessHelper.PhotoAsset) => void = () => {
  };
  private curCameraDevice: camera.CameraDevice | undefined = undefined;
  private receiver: image.ImageReceiver | undefined = undefined;
  frameStartFlag: number = 0;
  // One of the recommended preview resolutions
  private previewProfileObj: camera.Profile = {
    format: 1003,
    size: {
      width: Constants.X_COMPONENT_SURFACE_WIDTH,
      height: Constants.X_COMPONENT_SURFACE_HEIGHT
    }
  };
  surfaceId: string = '';

  // [Start Case2_start]
  onImageArrival(receiver: image.ImageReceiver): void {
    receiver.on('imageArrival', () => {
      receiver.readNextImage((err: BusinessError, nextImage: image.Image) => {
        // [StartExclude Case2_start]
        if (err || nextImage === undefined) {
          Logger.error(TAG, `requestPermissionsFromUser call Failed! error: ${err.code}`);
          return;
        }
        // [EndExclude Case2_start]
        if (nextImage) {
          nextImage.getComponent(image.ComponentType.JPEG, async (_err, component: image.Component) => {
            let width: number = 1080; // Application create preview stream resolution corresponding to the width
            let height: number = 1080; // Application create preview stream resolution corresponding to the height
            let stride: number = component.rowStride; // Get stride by using component.rowStride
            Logger.info(TAG, `receiver getComponent width:${width} height:${height} stride:${stride}`);
            // stride and width are equal. Reading buffer by width does not affect the result
            if (stride === width) {
              let pixelMap: image.PixelMap | undefined = await image.createPixelMap(component.byteBuffer, {
                size: { height: height, width: width },
                srcPixelFormat: image.PixelMapFormat.NV21,
              })
              AppStorage.setOrCreate('stridePixel', pixelMap);
            } else {
              let pixelMap: image.PixelMap | undefined = await image.createPixelMap(component.byteBuffer, {
                // Positive example: 1. width transmission stride when creating PixelMap.
                size: { height: height, width: stride },
                srcPixelFormat: 8,
              })
              // 2. then call the cropSync method of PixelMap to crop out the excess pixels.
              try {
                pixelMap.cropSync({
                  size: { width: width, height: height },
                  x: 0,
                  y: 0
                }) // Crop the image according to the size entered, starting with (0,0), crop the area of width*height bytes.
                let pixelBefore: PixelMap | undefined = AppStorage.get('stridePixel');
                await pixelBefore?.release();
                AppStorage.setOrCreate('stridePixel', pixelMap);
              } catch (error) {
                let err: BusinessError = error as BusinessError;
                hilog.warn(0x000, 'testTag', `setColorMode failed, code=${err.code}, message=${err.message}`);
              }
            }
            nextImage.release();
          })
        }
      });
    })
  }

  // [End Case2_start]

  getPreviewProfile(cameraOutputCapability: camera.CameraOutputCapability): camera.Profile | undefined {
    let previewProfiles: Array<camera.Profile> = cameraOutputCapability.previewProfiles;
    if (previewProfiles.length < 1) {
      return undefined;
    }
    let index: number = previewProfiles.findIndex((previewProfile: camera.Profile) => {
      return previewProfile.size.width === this.previewProfileObj.size.width &&
        previewProfile.size.height === this.previewProfileObj.size.height &&
        previewProfile.format === this.previewProfileObj.format;
    });
    if (index === -1) {
      return undefined;
    }
    return previewProfiles[index];
  }

  /**
   * Initializes the camera function
   * @param surfaceId - Surface ID
   * @param cameraDeviceIndex - Camera equipment index
   * @returns No return value
   */
  async initCamera(cameraDeviceIndex: number, uiContext: UIContext): Promise<void> {
    Logger.debug(TAG, `initCamera cameraDeviceIndex: ${cameraDeviceIndex}`);
    try {
      await this.releaseCamera();
      // Get the Camera Manager instance
      this.cameraManager = this.getCameraManagerFn(uiContext);
      if (this.cameraManager === undefined) {
        Logger.error(TAG, 'cameraManager is undefined');
        return;
      }
      this.cameras = this.getSupportedCamerasFn(this.cameraManager);
      this.curCameraDevice = this.cameras[cameraDeviceIndex];
      if (this.curCameraDevice === undefined) {
        Logger.error(TAG, 'Failed to create the camera input.');
        return;
      }
      // Create the cameraInput output object
      this.cameraInput = this.createCameraInputFn(this.cameraManager, this.curCameraDevice);
      if (this.cameraInput === undefined) {
        Logger.error(TAG, 'Failed to create the camera input.');
        return;
      }
      // Turn on the camera
      let isOpenSuccess: boolean = await this.cameraInputOpenFn(this.cameraInput);
      if (!isOpenSuccess) {
        Logger.error(TAG, 'Failed to open the camera.');
        return;
      }

      // Choose a profile with a different stride and width
      let previewProfile: camera.Profile = {
        format: camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP,
        size: {
          width: Constants.X_COMPONENT_SURFACE_WIDTH,
          height: Constants.X_COMPONENT_SURFACE_HEIGHT
        }
      };

      let size: image.Size = {
        width: Constants.X_COMPONENT_SURFACE_WIDTH,
        height: Constants.X_COMPONENT_SURFACE_HEIGHT
      }
      this.receiver = image.createImageReceiver(size, image.ImageFormat.JPEG, 8);
      let surfaceId: string = await this.receiver.getReceivingSurfaceId();
      this.previewOutput = this.createPreviewOutputFn(this.cameraManager, previewProfile, surfaceId);
      this.onImageArrival(this.receiver);

      if (this.previewOutput === undefined) {
        Logger.error(TAG, 'Failed to create the preview stream.');
        return;
      }

      // Session flow
      await this.sessionFlowFn(this.cameraManager, this.cameraInput, this.previewOutput);
    } catch (error) {
      Logger.error(TAG, `initCamera fail: ${JSON.stringify(error)}`);
    }
  }

  getPreviewRotation(): void {
    let previewRotation: camera.ImageRotation | undefined = camera.ImageRotation.ROTATION_0;
    try {
      previewRotation = this.previewOutput?.getPreviewRotation(previewRotation);
      AppStorage.set('previewRotation', previewRotation);
    } catch (error) {
      let err: BusinessError = error as BusinessError;
      hilog.warn(0x000, 'testTag', `setColorMode failed, code=${err.code}, message=${err.message}`);
    }
  }

  /**
   * Release the session and related parameters
   */
  async releaseCamera(): Promise<void> {
    Logger.info(TAG, 'releaseCamera is called');
    try {
      await this.receiver?.release();
    } catch (err) {
      Logger.error(TAG, `imageReceiver release fail: error: ${JSON.stringify(err)}`);
    }
    try {
      await this.previewOutput?.release();
    } catch (err) {
      Logger.error(TAG, `previewOutput release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.previewOutput = undefined;
    }
    try {
      await this.session?.release();
    } catch (err) {
      Logger.error(TAG, `captureSession release fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.session = undefined;
    }
    try {
      await this.cameraInput?.close();
    } catch (err) {
      Logger.error(TAG, `cameraInput close fail: error: ${JSON.stringify(err)}`);
    } finally {
      this.cameraInput = undefined;
    }
    Logger.info(TAG, 'releaseCamera success');
  }

  /**
   * Get the Camera Manager instance
   */
  getCameraManagerFn(uiContext: UIContext): camera.CameraManager | undefined {
    if (this.cameraManager) {
      return this.cameraManager;
    }
    let cameraManager: camera.CameraManager | undefined = undefined;
    try {
      cameraManager = camera.getCameraManager(uiContext.getHostContext());
      Logger.info(TAG, `getCameraManager success: ${cameraManager}`);
    } catch (error) {
      Logger.error(TAG, `getCameraManager failed: ${JSON.stringify(error)}`);
    }
    return cameraManager;
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
      Logger.error(TAG, `getSupportedCameras failed: ${JSON.stringify(error)}`);
    }
    return supportedCameras;
  }

  /**
   * Create the cameraInput output object
   */
  createCameraInputFn(cameraManager: camera.CameraManager,
    cameraDevice: camera.CameraDevice): camera.CameraInput | undefined {
    Logger.info(TAG, 'createCameraInputFn is called.');
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraDevice);
      Logger.info(TAG, 'createCameraInputFn success');
    } catch (error) {
      Logger.error(TAG, `createCameraInputFn failed: ${JSON.stringify(error)}`);
    }
    return cameraInput;
  }

  /**
   * Create the previewOutput output object
   */
  createPreviewOutputFn(cameraManager: camera.CameraManager, previewProfileObj: camera.Profile,
    surfaceId: string): camera.PreviewOutput | undefined {
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = cameraManager.createPreviewOutput(previewProfileObj, surfaceId);
      Logger.info(TAG, `createPreviewOutput success: ${previewOutput}`);
    } catch (error) {
      Logger.error(TAG, `createPreviewOutput failed: ${JSON.stringify(error)}`);
    }
    return previewOutput;
  }

  /**
   * Turn on the camera
   */
  async cameraInputOpenFn(cameraInput: camera.CameraInput): Promise<boolean> {
    let isOpenSuccess: boolean = false;
    try {
      await cameraInput.open();
      isOpenSuccess = true;
      Logger.info(TAG, 'cameraInput open success');
    } catch (error) {
      Logger.error(TAG, `createCameraInput failed : ${JSON.stringify(error)}`);
    }
    return isOpenSuccess;
  }

  /**
   * Session flow
   */
  async sessionFlowFn(cameraManager: camera.CameraManager, cameraInput: camera.CameraInput,
    previewOutput: camera.PreviewOutput | undefined): Promise<void> {
    try {
      // Create CaptureSession instances
      this.session = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
      this.session.beginConfig();
      this.session.addInput(cameraInput);
      this.session.addOutput(previewOutput);
      this.getPreviewRotation();
      await this.session.commitConfig();
      await this.session.start();
      Logger.info(TAG, 'sessionFlowFn success');
    } catch (error) {
      Logger.error(TAG, `sessionFlowFn fail : ${JSON.stringify(error)}`);
    }
  }
}

export default new CameraService();