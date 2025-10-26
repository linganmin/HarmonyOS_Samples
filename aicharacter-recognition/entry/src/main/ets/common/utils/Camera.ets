/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import { BusinessError } from '@kit.BasicServicesKit';
import { camera } from '@kit.CameraKit';
import { textRecognition } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import Logger from './Logger';
import CommonConstants from '../constants/CommonConstants';

const TAG: string = '[CameraModel]';

export default class Camera {
  private cameraMgr: camera.CameraManager | undefined = undefined;
  private cameraDevice: camera.CameraDevice | undefined = undefined;
  private capability: camera.CameraOutputCapability | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private receiver: image.ImageReceiver | undefined = undefined;
  private photoOutput: camera.PhotoOutput | undefined = undefined;
  public previewOutput: camera.PreviewOutput | undefined = undefined;
  public captureSession: camera.PhotoSession | undefined = undefined;
  public result: string = '';

  async initCamera(surfaceId: string): Promise<void> {
    try {
      const context: common.UIAbilityContext = AppStorage.get('context') as common.UIAbilityContext;
      this.cameraMgr = camera.getCameraManager(context);
      let cameraArray = this.getCameraDevices(this.cameraMgr);
      this.cameraDevice = cameraArray[CommonConstants.INPUT_DEVICE_INDEX];
      this.cameraInput = this.getCameraInput(this.cameraDevice, this.cameraMgr) as camera.CameraInput;
      await this.cameraInput.open();
      this.capability = this.cameraMgr.getSupportedOutputCapability(this.cameraDevice, camera.SceneMode.NORMAL_PHOTO);

      this.previewOutput = this.getPreviewOutput(this.cameraMgr, this.capability, surfaceId) as camera.PreviewOutput;
      this.photoOutput = this.getPhotoOutput(this.cameraMgr, this.capability) as camera.PhotoOutput;

      this.photoOutput.on('photoAvailable', (errCode: BusinessError, photo: camera.Photo): void => {
        let imageObj = photo.main;
        imageObj.getComponent(image.ComponentType.JPEG, async (errCode: BusinessError, component: image.Component) => {
          if (errCode || component === undefined) {
            return;
          }
          let buffer: ArrayBuffer;
          buffer = component.byteBuffer
          this.result = await this.recognizeImage(buffer);
        })
      })

      // Session Init
      this.captureSession = this.getCaptureSession(this.cameraMgr) as camera.PhotoSession;
      this.beginConfig(this.captureSession);
      this.startSession(this.captureSession, this.cameraInput, this.previewOutput, this.photoOutput);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Camera', `initCamera failed. code=${err.code}, message=${err.message}`);
    }
  }

  async takePicture() {
    this.result = '';
    this.photoOutput!.capture().catch((error: BusinessError) => {
      hilog.error(0x0000, 'Camera', `capture failed. code=${error.code}, message=${error.message}`);
    });
  }

  async recognizeImage(buffer: ArrayBuffer): Promise<string> {
    let imageResource = image.createImageSource(buffer);
    let pixelMapInstance = await imageResource.createPixelMap();
    let visionInfo: textRecognition.VisionInfo = {
      pixelMap: pixelMapInstance
    };
    let textConfiguration: textRecognition.TextRecognitionConfiguration = {
      isDirectionDetectionSupported: true
    };
    let recognitionString: string = '';
    const context: common.UIAbilityContext = AppStorage.get('context') as common.UIAbilityContext;
    try {
      if (canIUse('SystemCapability.AI.OCR.TextRecognition')) {
        await textRecognition.recognizeText(visionInfo, textConfiguration).then((TextRecognitionResult) => {
          if (TextRecognitionResult.value === '') {
            recognitionString = context.resourceManager.getStringSync($r('app.string.unrecognizable').id);
          } else {
            recognitionString = TextRecognitionResult.value;
          }
        })
        pixelMapInstance.release();
        imageResource.release();
      } else {
        recognitionString = context.resourceManager.getStringSync($r('app.string.Device_not_support').id);
        Logger.error(TAG, `device not support`);
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'Camera', `recognizeImage failed. code=${err.code}, message=${err.message}`);
    }
    return recognitionString;
  }

  async releaseCamera(): Promise<void> {
    try {
      if (this.cameraInput) {
        await this.cameraInput.close();
        Logger.info(TAG, 'cameraInput release');
      }
      if (this.previewOutput) {
        await this.previewOutput.release();
        Logger.info(TAG, 'previewOutput release');
      }
      if (this.receiver) {
        await this.receiver.release();
        Logger.info(TAG, 'receiver release');
      }
      if (this.photoOutput) {
        await this.photoOutput.release();
        Logger.info(TAG, 'photoOutput release');
      }
      if (this.captureSession) {
        await this.captureSession.release();
        Logger.info(TAG, 'captureSession release');
        this.captureSession = undefined;
      }
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `releaseCamera failed. code=${err.code}, message=${err.message}`);
    }
  }

  getCameraDevices(cameraManager: camera.CameraManager): Array<camera.CameraDevice> {
    let cameraArray: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    if (cameraArray != undefined && cameraArray.length > 0) {
      return cameraArray;
    } else {
      Logger.error(TAG, `getSupportedCameras faild`);
      return [];
    }
  }

  getCameraInput(cameraDevice: camera.CameraDevice,
    cameraManager: camera.CameraManager): camera.CameraInput | undefined {
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = cameraManager.createCameraInput(cameraDevice);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `createCameraInput failed. code=${err.code}, message=${err.message}`);
    }
    return cameraInput;
  }

  getPreviewOutput(cameraManager: camera.CameraManager, cameraOutputCapability: camera.CameraOutputCapability,
    surfaceId: string): camera.PreviewOutput | undefined {
    let previewProfilesArray: Array<camera.Profile> = cameraOutputCapability.previewProfiles;
    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput =
        cameraManager.createPreviewOutput(previewProfilesArray[CommonConstants.OUTPUT_DEVICE_INDEX], surfaceId);
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `createPreviewOutput failed. code=${err.code}, message=${err.message}`);
    }
    return previewOutput;
  }

  async getImageReceiverSurfaceId(receiver: image.ImageReceiver): Promise<string | undefined> {
    let photoSurfaceId: string | undefined = undefined;
    if (receiver !== undefined) {
      photoSurfaceId = await receiver.getReceivingSurfaceId();
      Logger.info(TAG, `getReceivingSurfaceId success`);
    }
    return photoSurfaceId;
  }

  getPhotoOutput(cameraManager: camera.CameraManager,
    cameraOutputCapability: camera.CameraOutputCapability): camera.PhotoOutput | undefined {
    let photoProfilesArray: Array<camera.Profile> = cameraOutputCapability.photoProfiles;
    Logger.info(TAG, JSON.stringify(photoProfilesArray));
    if (!photoProfilesArray) {
      Logger.info(TAG, `createOutput photoProfilesArray == null || undefined`);
    }
    let photoOutput: camera.PhotoOutput | undefined = undefined;
    try {
      photoOutput = cameraManager.createPhotoOutput(photoProfilesArray[CommonConstants.OUTPUT_DEVICE_INDEX]);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to createPhotoOutput. code: ${err.code}, message=${err.message}`);
    }
    return photoOutput;
  }

  getCaptureSession(cameraManager: camera.CameraManager): camera.PhotoSession | undefined {
    let captureSession: camera.PhotoSession | undefined = undefined;
    try {
      captureSession = cameraManager.createSession(1) as camera.PhotoSession;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to create the CaptureSession instance. code: ${err.code}, message=$err.message}`);
    }
    return captureSession;
  }

  beginConfig(captureSession: camera.PhotoSession): void {
    try {
      captureSession.beginConfig();
      Logger.info(TAG, 'captureSession beginConfig')
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to beginConfig. code: ${err.code}, message=${err.message}`);
    }
  }

  async startSession(captureSession: camera.PhotoSession, cameraInput: camera.CameraInput, previewOutput:
    camera.PreviewOutput, photoOutput: camera.PhotoOutput): Promise<void> {
    try {
      captureSession.addInput(cameraInput);
      captureSession.addOutput(previewOutput);
      captureSession.addOutput(photoOutput);
      await captureSession.commitConfig();
      await captureSession.start();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to startSession. code: ${err.code}, message=${err.message}`);
    }
  }
}