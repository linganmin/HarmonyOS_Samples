/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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
import { camera } from '@kit.CameraKit';
import { common } from '@kit.AbilityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import recorder, { Response } from 'librecorder.so';
import { CameraDataModel } from '../model/CameraDateModel';
import Logger from '../common/utils/Logger';


const TAG: string = "[CameraController]";


let cameraInput: camera.CameraInput;
let xComponentPreviewOutput: camera.PreviewOutput;
let xComponentPreviewOutputAlive: boolean = false;
let encoderVideoOutput: camera.VideoOutput;
let videoSession: camera.VideoSession;

export class CameraController {
  private cameraIsRunning: boolean = false;
  private cameraData: CameraDataModel;
  private isReleased: boolean = true;
  private nativeRecorderObj: bigint | undefined;
  private context: common.UIAbilityContext | undefined;
  private isOpenROI: boolean = false;

  constructor(cameraData: CameraDataModel, context: common.UIAbilityContext) {
    this.cameraData = cameraData;
    this.context = context;
  }

  public setIsOpenROI(isOpenROI: boolean){
    this.isOpenROI = isOpenROI;
  }


  public getNativeRecorderObj() {
    return this.nativeRecorderObj;
  }

  public getCameraPosition() {
    return this.cameraData.cameraPosition;
  }

  public setCameraPosition(cameraPosition: camera.CameraPosition) {
    this.cameraData.cameraPosition = cameraPosition;
  }

  public updateImageRotation() {
    try {
      this.cameraData.deviceRotation = display.getDefaultDisplaySync().rotation;
    } catch (error) {
      Logger.error(TAG, `getDefaultDisplaySync fail ${error}`);
    }

    if (xComponentPreviewOutputAlive) {
      try {
        this.cameraData.imageRotation =
          xComponentPreviewOutput.getPreviewRotation(this.cameraData.deviceRotation * camera.ImageRotation.ROTATION_90);
      } catch (error) {
        Logger.error(TAG, `getPreviewRotation fail ${error}`);
      }
      try {
        xComponentPreviewOutput.setPreviewRotation(this.cameraData.imageRotation, this.cameraData.isDisplayLocked);
      } catch (error) {
        Logger.error(TAG, `setPreviewRotation fail ${error}`);
      }
      recorder.UpdateCameraRotation(this.nativeRecorderObj, this.cameraData.imageRotation);
    }
  }

  public async initNative(): Promise<Response> {
    this.nativeRecorderObj = recorder.createRecorder();
    return recorder.initNative(this.nativeRecorderObj, this.cameraData.outputFd, this.cameraData.videoCodecMime,
      this.cameraData.cameraWidth,
      this.cameraData.cameraHeight, this.cameraData.frameRate, this.cameraData.isHDRVivid,
      this.cameraData.bitRate, this.cameraData.isOpenEchoCancel);
  }


  public async createRecorder(): Promise<void> {
    this.isReleased = false;
    if (this.cameraIsRunning) {
      this.releaseCamera();
    }

    let cameraManager: camera.CameraManager;
    try {
      cameraManager = camera.getCameraManager(this.context);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `get CamaraManager failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      return;
    }

    if (!cameraManager) {
      Logger.error(TAG, 'camera.getCameraManager error');
      return;
    }

    // Get supported camera devices.
    let cameraDevices: Array<camera.CameraDevice> = cameraManager.getSupportedCameras();
    if (cameraDevices !== undefined && cameraDevices.length <= 0) {
      Logger.error(TAG, 'cameraManager.getSupportedCameras error!');
      return;
    }

    // front or back
    const deviceCur =
      cameraDevices?.find(device => device.cameraPosition === this.cameraData.cameraPosition) || cameraDevices[0];
    if (!deviceCur) {
      Logger.error(TAG, `Failed to get camera device. cameraPosition: ${this.cameraData.cameraPosition}}`);
      return;
    }
    this.cameraData.cameraPosition = deviceCur.cameraPosition;
    recorder.updateInfoForCamera(this.nativeRecorderObj,
      this.cameraData.cameraPosition === camera.CameraPosition.CAMERA_POSITION_FRONT);


    let profiles: camera.CameraOutputCapability =
      cameraManager.getSupportedOutputCapability(deviceCur, camera.SceneMode.NORMAL_VIDEO);
    if (!profiles) {
      Logger.error(TAG, 'cameraManager.getSupportedOutputCapability error!');
      return;
    }

    let XComponentPreviewProfile: undefined | camera.Profile =
      profiles.previewProfiles.find((profile: camera.Profile) => {
        let resolutionSupport: boolean = profile.size.width === this.cameraData.cameraWidth &&
          profile.size.height === this.cameraData.cameraHeight;
        if (this.cameraData.isHDRVivid) {
          return resolutionSupport &&
            profile.format === camera.CameraFormat.CAMERA_FORMAT_YCBCR_P010;
        } else {
          return resolutionSupport &&
            profile.format === camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP;
        }
      });

    if (XComponentPreviewProfile === undefined) {
      Logger.error(TAG, 'videoProfile is not found!');
      return;
    }
    // Create a preview stream output object
    try {
      xComponentPreviewOutput = cameraManager.createPreviewOutput(XComponentPreviewProfile, this.cameraData.surfaceId);
    } catch (error) {
      Logger.error(TAG, `createPreviewOutput fail ${error}}`);
    }
    if (xComponentPreviewOutput === undefined) {
      Logger.error(TAG, 'XComponentPreviewOutput is undefined');
      return;
    }

    // metadata
    let metadataOutput: camera.MetadataOutput | undefined =
      this.getMetadataOutput(cameraManager, profiles)
    if (metadataOutput === undefined) {
      Logger.warn(TAG, 'no metadataOutput');
    }
    // Create the cameraInput object.
    try {
      cameraInput = cameraManager.createCameraInput(deviceCur);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to createCameraInput. error: ${JSON.stringify(err)}`);
    }
    if (cameraInput === undefined) {
      Logger.error(TAG, 'cameraInput is undefined');
      return;
    }

    // Turn on the camera.
    try {
      await cameraInput.open();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to open cameraInput. error: ${JSON.stringify(err)}`);
    }
    // Create a session flow
    try {
      videoSession = cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to create the session instance. error: ${JSON.stringify(err)}`);
    }
    if (videoSession === undefined) {
      Logger.error(TAG, 'videoSession is undefined');
      return;
    }

    // Start Configuring the session.
    try {
      videoSession.beginConfig();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to beginConfig. error: ${JSON.stringify(err)}`);
    }

    // Add CameraInput to the session.
    try {
      videoSession.addInput(cameraInput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add cameraInput. error: ${JSON.stringify(err)}`);
    }
    // Add the XComponent preview stream to the session.
    try {
      videoSession.addOutput(xComponentPreviewOutput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add XcomponentPreviewOutput. error: ${JSON.stringify(err)}`);
    }
    // Add the metadataOutput stream to the session.
    try {
      videoSession.addOutput(metadataOutput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add metadataOutput. error: ${JSON.stringify(err)}`);
    }

    this.onMetadataObjectsAvailable(metadataOutput);
    this.onMetadataError(metadataOutput);

    // Submit configuration information.
    try {
      await videoSession.commitConfig();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `videoSession commitConfig error: ${JSON.stringify(err)}`);
    }

    // Enable autofocus
    this.setFocusMode(videoSession);

    if (this.cameraData.isDynamicFpsEnabled) {
      this.setDynamicFrameRate(xComponentPreviewOutput, encoderVideoOutput);
    } else {
      const isFrameRateSetSuccess = this.handleFrameRateSetting(this.cameraData.frameRate, xComponentPreviewOutput);
      if (!isFrameRateSetSuccess) {
        Logger.error(TAG, "Frame rate setting failed");
        return;
      }
    }

    // Set color space
    this.setColorSpaceBeforeCommitConfig(videoSession, this.cameraData.isHDRVivid);

    xComponentPreviewOutputAlive = true;
    try {
      this.cameraData.deviceRotation = display.getDefaultDisplaySync().rotation;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getDefaultDisplaySync fail ${JSON.stringify(err)}`)
    }
    if (xComponentPreviewOutputAlive) {
      try {
        this.cameraData.imageRotation =
          xComponentPreviewOutput.getPreviewRotation(this.cameraData.deviceRotation * camera.ImageRotation.ROTATION_90);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `getPreviewRotation fail ${JSON.stringify(err)}`);
      }
      try {
        xComponentPreviewOutput.setPreviewRotation(this.cameraData.imageRotation, this.cameraData.isDisplayLocked);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `getPreviewRotation fail ${JSON.stringify(err)}`);
      }
      recorder.UpdateCameraRotation(this.nativeRecorderObj, this.cameraData.imageRotation);

    }

    // Update camera zoom ratio range
    try {
      let zoomRatios = videoSession.getZoomRatioRange();
      this.cameraData.range[0] = zoomRatios[0];
      this.cameraData.range[1] = zoomRatios[1];
      Logger.debug(TAG, `update zoomRatio Range min=${zoomRatios[0]} max=${zoomRatios[1]}`)
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getPreviewRotation fail ${JSON.stringify(err)}`);
    }

    // Session start.
    try {
      await videoSession.start();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `videoSession start error: ${JSON.stringify(err)}`);
    }
    this.cameraIsRunning = true;

    try {
      this.registerSystemPressureLevelChangeCallback(videoSession);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `register system pressure level changeCallback error: ${JSON.stringify(err)}`);
    }
  }

  public async releaseCamera(): Promise<void> {
    if (this.cameraIsRunning === false) {
      return;
    }
    this.cameraIsRunning = false;
    try {
      this.unregisterSystemPressureLevelChangeCallback(videoSession);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `unregister system pressure level changeCallback error: ${JSON.stringify(err)}`);
    }
    // Stop the Session.
    xComponentPreviewOutputAlive = false
    videoSession.stop().catch((error: BusinessError) => {
      Logger.error(TAG, `videoSession stop  fail ${error}`);
    });

    // Close camera input stream.
    cameraInput.close().catch((error: BusinessError) => {
      Logger.error(TAG, `videoSession stop  fail ${error}`);
    });
    // Release preview output stream.
    xComponentPreviewOutput.release().catch((error: BusinessError) => {
      Logger.error(TAG, `release  fail ${error}`);
    });
    // Release the video output stream.
    // Release session.
    videoSession.release().catch((error: BusinessError) => {
      Logger.error(TAG, `videoSession release  fail ${error}`);
    });
  }

  unregisterSystemPressureLevelChangeCallback(videoSession: camera.VideoSession): void {
    if (deviceInfo.sdkApiVersion >= 20) {
      videoSession.off('systemPressureLevelChange');
    }
  }


  onMetadataObjectsAvailable(metadataOutput: camera.MetadataOutput | undefined): void {
    metadataOutput?.on('metadataObjectsAvailable',
      (err: BusinessError, metadataObjectArr: Array<camera.MetadataObject>) => {
        if (err !== undefined && err.code !== 0) {
          return;
        }
        // Iterate through the array to find an object with type equal to 0
        for (const metadataObject of metadataObjectArr) {
          if (metadataObject.type === 0) {
            Logger.info(TAG,
              `find the metadataObject whose type is 0, timestamp: ${metadataObject.timestamp}, ${metadataObject.boundingBox.topLeftX}, ${metadataObject.boundingBox.topLeftY}, ${metadataObject.boundingBox.width}, ${metadataObject.boundingBox.height}.`);
            Logger.debug(TAG, `UpdateFaceInfoFromCamera isOpenROI=${this.isOpenROI}`)
            recorder.UpdateFaceInfoFromCamera(
              this.nativeRecorderObj,
              this.isOpenROI,
              metadataObject.timestamp,
              metadataObject.boundingBox.topLeftX,
              metadataObject.boundingBox.topLeftY,
              metadataObject.boundingBox.width,
              metadataObject.boundingBox.height)
            break;
          }
        }
        Logger.info(TAG, `metadata output metadataObjectsAvailable.`);
      });
  }


  onMetadataError(metadataOutput: camera.MetadataOutput | undefined): void {
    metadataOutput?.on('error', (metadataOutputError: BusinessError) => {
      Logger.error(TAG, `Metadata output error code: ${metadataOutputError.code}`);
    });
  }

  getMetadataOutput(cameraManager: camera.CameraManager,
    cameraOutputCapability: camera.CameraOutputCapability): camera.MetadataOutput | undefined {
    let metadataObjectTypes: Array<camera.MetadataObjectType> = cameraOutputCapability.supportedMetadataObjectTypes;
    let metadataOutput: camera.MetadataOutput | undefined = undefined;
    try {
      metadataOutput = cameraManager.createMetadataOutput(metadataObjectTypes);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to createMetadataOutput, error code: ${err.code}`);
    }
    return metadataOutput;
  }

  setFocusMode(videoSession: camera.VideoSession): void {
    const focusPoint: camera.Point = { x: 1, y: 1 };
    try {
      // Set autofocus mode
      videoSession.setFocusMode(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
      // Set focus point
      videoSession.setFocusPoint(focusPoint);
    } catch (error) {
      // On failure, return the error code error.code and handle it
      let err = error as BusinessError;
      Logger.error(TAG, `The setFocusMode and setFocusPoint call failed. error code: ${err.code}`);
    }
  }

  setDynamicFrameRate(XComponentPreviewOutput: camera.PreviewOutput, encoderVideoOutput: camera.VideoOutput) {
    Logger.error('[czztest]begin');
    let supportFrameRateArray: Array<camera.FrameRateRange> = this.getSupportedFrameRange(XComponentPreviewOutput);
    let supportVideoFrameRateArray: Array<camera.FrameRateRange> = this.getVideoSupportedFrameRange(encoderVideoOutput);
    // Frame rate can be set before start
    if (supportFrameRateArray.length !== 0 && supportVideoFrameRateArray.length !== 0) {
      // Set the frame rate to the maximum value of the first frame rate range.
      // Currently, the video stream must be configured first; otherwise, settings for the preview stream will not take effect.
      // If the video stream is configured first, its frame rate will be set to the default, and the two streams will enforce strict mutual validation.
      // Specifically, if the video stream is configured first, the default rules will be based on the video stream—for example, if it's set to 10–24 fps, the preview stream can only be set to 24 fps or a multiple of 24.
      // Conversely, if the preview stream is configured first, it will default to 30 fps, which may conflict with the video stream during strict validation, causing the configuration to fail.
      this.setVideoFrameRate(encoderVideoOutput, 10, 24);
      this.setFrameRate(XComponentPreviewOutput, 10, 24);
    }

    let activeFrameRateArray: camera.FrameRateRange = this.getActiveFrameRange(XComponentPreviewOutput);
    let activeVideoFrameRateArray: camera.FrameRateRange = this.getVideoActiveFrameRange(encoderVideoOutput);
    Logger.info(TAG,
      `[czztest]current effective frame rate for this previewOutput: ${JSON.stringify(activeFrameRateArray)}, current effective frame rate for this encoderVideoOutputc: ${JSON.stringify(activeVideoFrameRateArray)}`);

    Logger.error(TAG, '[czztest]end')
  }


  handleFrameRateSetting(
    targetFrameRate: number,
    previewOutput: camera.PreviewOutput
  ): boolean {
    // Get the currently supported frame rate ranges
    const supportFrameRateArray: Array<camera.FrameRateRange> = previewOutput.getSupportedFrameRates();
    Logger.info(TAG, `frame rate supported by previewOutput: ${JSON.stringify(supportFrameRateArray)}`);

    // Check if the target frame rate is supported
    let isFpsSupported = false;
    for (const frameRateRange of supportFrameRateArray) {
      if (targetFrameRate >= frameRateRange.min && targetFrameRate <= frameRateRange.max) {
        isFpsSupported = true;
        break; // Exit the loop early once a supported range is found
      }
    }

    // If supported, attempt to set the frame rate
    if (isFpsSupported) {
      try {
        previewOutput.setFrameRate(targetFrameRate, targetFrameRate);
      } catch (error) {
        const err = error as BusinessError;
        Logger.error(TAG, `Failed to setFrameRate for previewOutput. error: ${JSON.stringify(err)}`);
        return false; // Failed to set
      }
    } else {
      Logger.error(TAG, `Target frame rate ${targetFrameRate} is not supported`);
      return false; // Target frame rate is not supported
    }

    // Verify the currently active frame rate
    const activeFrameRate: camera.FrameRateRange = previewOutput.getActiveFrameRate();
    if (activeFrameRate.min !== targetFrameRate || activeFrameRate.max !== targetFrameRate) {
      Logger.error(TAG,
        `Current effective frame rate: ${JSON.stringify(activeFrameRate)} but wanted ${targetFrameRate}`);
      return false; // Frame rate mismatch
    } else {
      Logger.info(TAG,
        `Current effective frame rate: ${JSON.stringify(activeFrameRate)} and wanted ${targetFrameRate}`);
    }

    return true; // Frame rate successfully set and verified
  }


  // [Start Set_color_space]
  // Set the color space
  setColorSpaceBeforeCommitConfig(session: camera.VideoSession, isHdr: number): void {
    let colorSpace: colorSpaceManager.ColorSpace =
      isHdr ? colorSpaceManager.ColorSpace.BT2020_HLG_LIMIT : colorSpaceManager.ColorSpace.BT709_LIMIT;
    let colorSpaces: Array<colorSpaceManager.ColorSpace> = this.getSupportedColorSpaces(session);
    let isSupportedColorSpaces = colorSpaces.indexOf(colorSpace) >= 0;
    if (isSupportedColorSpaces) {
      Logger.info(TAG, `setColorSpace: ${colorSpace}`);
      try {
        session.setColorSpace(colorSpace);
      } catch (error) {
        Logger.error(TAG, `setColorSpace fail ${error}`)
      }
      let activeColorSpace: colorSpaceManager.ColorSpace;
      try {
        activeColorSpace = session.getActiveColorSpace();
        if (activeColorSpace != colorSpace) {
          Logger.error(TAG, `activeColorSpace: ${activeColorSpace}, but wait: ${colorSpace}`);
        }
        Logger.info(TAG, `activeColorSpace: ${activeColorSpace}`);
      } catch (error) {
        Logger.error(TAG, `getActiveColorSpace fail ${error}`);
      }
    } else {
      Logger.info(TAG, `colorSpace: ${colorSpace} is not support`);
    }
  }
  // [End Set_color_space]

  // [Start System_pressure_level]
  systemPressureLevelChangeCallback(err: BusinessError, systemPressureLevel: camera.SystemPressureLevel): void {
    if (err !== undefined && err.code !== 0) {
      Logger.error(TAG, `Callback Error, errorCode: ${err.code}`);
      return;
    }
    Logger.info(TAG, `systemPressureLevel: ${systemPressureLevel}`);
  }


  registerSystemPressureLevelChangeCallback(videoSession: camera.VideoSession): void {
    if (deviceInfo.sdkApiVersion >= 20) {
      videoSession.on('systemPressureLevelChange', this.systemPressureLevelChangeCallback);
    }
  }
  // [End System_pressure_level]

  setVideoFrameRate(videoOutput: camera.VideoOutput, minFps: number, maxFps: number): void {
    try {
      videoOutput.setFrameRate(minFps, maxFps);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to setFrameRate for previewOutput. error: ${JSON.stringify(err)}`);
    }
  }

  setFrameRate(previewOutput: camera.PreviewOutput, minFps: number, maxFps: number): void {
    try {
      previewOutput.setFrameRate(minFps, maxFps);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to setFrameRate for previewOutput. error: ${JSON.stringify(err)}`);
    }
  }

  getActiveFrameRange(previewOutput: camera.PreviewOutput): camera.FrameRateRange {
    return previewOutput.getActiveFrameRate();
  }

  getSupportedFrameRange(previewOutput: camera.PreviewOutput): Array<camera.FrameRateRange> {
    // Get the supported frame rate ranges; different hardware platforms may provide different frame rate ranges.
    return previewOutput.getSupportedFrameRates();
  }

  getVideoActiveFrameRange(videoOutput: camera.VideoOutput): camera.FrameRateRange {
    return videoOutput.getActiveFrameRate();
  }

  getVideoSupportedFrameRange(videoOutput: camera.VideoOutput): Array<camera.FrameRateRange> {
    // Get the supported frame rate ranges; different hardware platforms may provide different frame rate ranges.
    return videoOutput.getSupportedFrameRates();
  }


  getSupportedColorSpaces(session: camera.VideoSession): Array<colorSpaceManager.ColorSpace> {
    let colorSpaces: Array<colorSpaceManager.ColorSpace> = [];
    try {
      colorSpaces = session.getSupportedColorSpaces();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `The getSupportedColorSpaces call failed. error code: ${err.code}`);
    }
    return colorSpaces;
  }

  public onDisplayCallback() {
    try {
      display.on(`foldStatusChange`, this.callbackFoldStatus);
    } catch (error) {
      Logger.error(TAG, `set on foldStatusChange fail ${error}`);
    }
    display.on(`change`, this.displayChangeCallback);
  }

  public offDisplayCallback() {
    try {
      display.off(`foldStatusChange`, this.callbackFoldStatus);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `offDisplayCallback failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    display.off(`change`, this.displayChangeCallback);
  }

  public doGestureUpdate(fov: number, event: GestureEvent) {
    if (videoSession) {
      let currentFov = fov * event.scale;
      if (currentFov > this.cameraData.range[1]) {
        currentFov = this.cameraData.range[1];
      }
      if (currentFov < this.cameraData.range[0]) {
        currentFov = this.cameraData.range[0];
      }
      try {
        videoSession.setZoomRatio(currentFov);
      } catch (error) {
        Logger.error(TAG, `setZoomRatio fail ${error}`);
      }
    }
  }

  public getCurrentZoomRatio() {
    if (videoSession) {
      try {
        return videoSession.getZoomRatio();
      } catch (error) {
        Logger.error(TAG, `getZoomRatio fail ${error}`);
      }
    }
    return;
  }

  async release(): Promise<void> {
    if (!this.isReleased) {
      this.isReleased = true;
      recorder.stopNative(this.nativeRecorderObj).then(async (data) => {
        if (data.code === 0) {
          await this.releaseCamera();
        }
      });
    }
  }

  public startNative(xComponentSurfaceId: string) {
    recorder.startNative(this.nativeRecorderObj, xComponentSurfaceId);
  }

  public UpdateCameraRotation(imageRotation: number) {
    recorder.UpdateCameraRotation(this.nativeRecorderObj, imageRotation);
  }

  public releaseNative() {
    if (this.nativeRecorderObj) {
      recorder.releaseRecorder(this.nativeRecorderObj);
      this.nativeRecorderObj = 0n;
    }
  }

  private displayChangeCallback: Callback<number> = (_: number): void => {
    try {
      this.cameraData.deviceRotation = display.getDefaultDisplaySync().rotation;
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `get rotation failed, errCode = ${err.code}, errMessage = ${err.message}.`);
    }
    if (xComponentPreviewOutputAlive) {
      try {
        this.cameraData.imageRotation =
          xComponentPreviewOutput.getPreviewRotation(this.cameraData.deviceRotation * camera.ImageRotation.ROTATION_90);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `get getPreviewRotation failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
      try {
        xComponentPreviewOutput.setPreviewRotation(this.cameraData.imageRotation, this.cameraData.isDisplayLocked);
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `get getPreviewRotation failed, errCode = ${err.code}, errMessage = ${err.message}.`);
      }
      recorder.UpdateCameraRotation(this.nativeRecorderObj, this.cameraData.imageRotation);
    }
    Logger.info(TAG, `ArkTSrotation, change rotation: ${this.cameraData.deviceRotation}.`);
  }
  private callbackFoldStatus: Callback<display.FoldStatus> = (data: display.FoldStatus) => {
    Logger.info(TAG, `arkTsrotation: change fold ${data}`)
    if (data === display.FoldStatus.FOLD_STATUS_EXPANDED ||
      data === display.FoldStatus.FOLD_STATUS_FOLDED) {
      this.releaseCamera();
      this.createRecorder();
    }
  }
}