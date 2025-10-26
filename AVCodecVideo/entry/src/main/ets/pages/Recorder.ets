/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
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

import { camera } from '@kit.CameraKit';
import { fileIo } from '@kit.CoreFileKit';
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import { hilog } from '@kit.PerformanceAnalysisKit';
import recorder from 'librecorder.so';
import Logger from '../common/utils/Logger';
import { dateTime } from '../common/utils/DateTimeUtils';
import { CommonConstants as Const } from '../common/CommonConstants';
import { CameraDataModel } from '../model/CameraDateModel';
import { previewProfileCameraCheck, videoProfileCheck } from '../common/utils/CameraCheck';

const TAG: string = Const.RECORDER_TAG;
const context = AppStorage.get('context') as UIContext;
const params: CameraDataModel = context.getRouter().getParams() as CameraDataModel;

let cameraInput: camera.CameraInput;
let XComponentPreviewOutput: camera.PreviewOutput;
let encoderVideoOutput: camera.VideoOutput;
let videoSession: camera.VideoSession;

async function releaseCamera(): Promise<void> {
  // Stop the video output stream
  if (encoderVideoOutput) {
    encoderVideoOutput.stop((err: BusinessError) => {
      if (err) {
        Logger.error(TAG, `Failed to stop the encoder video output. error: ${JSON.stringify(err)}`);
        return;
      }
      Logger.info(TAG, 'Callback invoked to indicate the encoder video output stop success.');
    });
  }

  try {
    // Stop the Session.
    videoSession.stop();
    // Close file fd.
    fileIo.close(params.outputfd);
    // Close camera input stream.
    cameraInput.close();
    // Release preview output stream.
    XComponentPreviewOutput.release();
    // Release the video output stream.
    encoderVideoOutput.release();
    Logger.info(TAG, 'encoderVideoOutput release');
    // Release session.
    videoSession.release();
  } catch (error) {
    hilog.error(0x0000, TAG, `releaseCamera catch error, code: ${error.code}, message: ${error.message}`);
    return;
  }
}

// [Start set_video_color]
function isVideoStabilizationModeSupported(session: camera.VideoSession, mode: camera.VideoStabilizationMode): boolean {
  let isSupported: boolean = false;
  try {
    isSupported = session.isVideoStabilizationModeSupported(mode);
  } catch (error) {
    // Failed to return error code error. code and handle it.
    let err = error as BusinessError;
    Logger.error(TAG, `The isVideoStabilizationModeSupported call failed. error code: ${err.code}`);
  }
  return isSupported;
}

function setVideoStabilizationMode(session: camera.VideoSession): boolean {
  let mode: camera.VideoStabilizationMode = camera.VideoStabilizationMode.AUTO;
  // Check if video stabilization is supported.
  let isSupported: boolean = isVideoStabilizationModeSupported(session, mode);
  if (isSupported) {
    Logger.info(TAG, `setVideoStabilizationMode: ${mode}`);
    try {
      // Setting video anti-shake
      session.setVideoStabilizationMode(mode);
      let activeVideoStabilizationMode = session.getActiveVideoStabilizationMode();
      Logger.info(TAG, `activeVideoStabilizationMode: ${activeVideoStabilizationMode}`);
    } catch (error) {
      hilog.error(0x0000, TAG, `setVideoStabilizationMode catch error, code: ${error.code}, message: ${error.message}`);
    }
  } else {
    Logger.info(TAG, `videoStabilizationMode: ${mode} is not support`);
  }
  return isSupported;
}

function getSupportedColorSpaces(session: camera.VideoSession): Array<colorSpaceManager.ColorSpace> {
  let colorSpaces: Array<colorSpaceManager.ColorSpace> = [];
  try {
    colorSpaces = session.getSupportedColorSpaces();
  } catch (error) {
    let err = error as BusinessError;
    Logger.error(TAG, `The getSupportedColorSpaces call failed. error code: ${err.code}`);
  }
  return colorSpaces;
}

// Set the color space
function setColorSpaceBeforeCommitConfig(session: camera.VideoSession, isHdr: number): void {
  try {
    let colorSpace: colorSpaceManager.ColorSpace =
      isHdr ? colorSpaceManager.ColorSpace.BT2020_HLG_LIMIT : colorSpaceManager.ColorSpace.BT709_LIMIT;
    let colorSpaces: Array<colorSpaceManager.ColorSpace> = getSupportedColorSpaces(session);
    let isSupportedColorSpaces = colorSpaces.indexOf(colorSpace) >= 0;
    if (isSupportedColorSpaces) {
      Logger.info(TAG, `setColorSpace: ${colorSpace}`);
      session.setColorSpace(colorSpace);
      let activeColorSpace: colorSpaceManager.ColorSpace = session.getActiveColorSpace();
      Logger.info(TAG, `activeColorSpace: ${activeColorSpace}`);
    } else {
      Logger.info(TAG, `colorSpace: ${colorSpace} is not support`);
    }
  } catch (error) {
    hilog.error(0x0000, TAG, `setColorSpace catch error, code: ${error.code}, message: ${error.message}`);
  }
}
// [End set_video_color]

@Entry
@Component
struct Recorder {
  @State isRecorderTimeTextHide: boolean = true;
  @State playFlag: boolean = false;
  @State buttonEnabled: boolean = true;
  @State videoRecorderTimeText: string = Const.DEFAULT_TIME;
  @State fov: number = 1;
  private XComponentSurfaceId: string = Const.DEFAULT_ID;
  private cameraWidth: number = Const.DEFAULT_WIDTH;
  private cameraHeight: number = Const.DEFAULT_HEIGHT;
  private XComponentController: XComponentController = new XComponentController();
  private display = display.getDefaultDisplaySync();
  private heightPx = (this.display.width * this.cameraWidth / this.cameraHeight) + Const.PX;
  private widthPx = this.display.width + Const.PX;
  private timer: number = Const.DEFAULT_VALUE;
  private seconds: number = Const.DEFAULT_VALUE;
  private isReleased: boolean = false;
  private isBack: boolean = false;
  private range: number[] = [];

  onBackPress() {
    this.isBack = true;
  }

  onPageHide() {
    this.release();
    if (!this.isBack) {
      this.getUIContext().getRouter().back();
    }
  }

  async release(): Promise<void> {
    if (!this.isReleased) {
      this.isReleased = true;
      clearInterval(this.timer);
      this.seconds = 0;
      this.videoRecorderTimeText = Const.DEFAULT_TIME;

      recorder.stopNative();
      await releaseCamera();
      this.playFlag = false;
    }
  }

  getRecordTime(): void {
    this.timer = setInterval(() => {
      this.seconds += 1;
      this.videoRecorderTimeText = dateTime(this.seconds);
    }, 1000);
  }

  async createRecorder(): Promise<void> {
    try {
      releaseCamera();
      // Create the CameraManager object.
      let cameraManager = camera.getCameraManager(this.getUIContext().getHostContext());
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

      // Get supported modes.
      let sceneModes: Array<camera.SceneMode> = cameraManager.getSupportedSceneModes(cameraDevices[0]);
      let isSupportVideoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_VIDEO) >= 0;
      if (!isSupportVideoMode) {
        Logger.error('video mode not support');
        return;
      }

      // [Start create_video_output3]
      let videoProfile: undefined | camera.VideoProfile = videoProfileCheck(cameraManager, params);
      if (!videoProfile) {
        Logger.error(TAG, 'videoProfile is not found!');
        return;
      }

      // [StartExclude create_video_output3]
      //The preview stream of XComponent.
      // [Start camera_conversation]
      let XComponentPreviewProfile: camera.Profile | undefined = previewProfileCameraCheck(cameraManager, params);
      if (XComponentPreviewProfile === undefined) {
        Logger.error(TAG, 'XComponentPreviewProfile is not found');
        return;
      }
      // [StartExclude camera_conversation]
      // [EndExclude create_video_output3]

      // Create the encoder output object
      encoderVideoOutput = cameraManager.createVideoOutput(videoProfile, params.surfaceId);
      if (encoderVideoOutput === undefined) {
        Logger.error(TAG, 'encoderVideoOutput is undefined');
        return;
      }
      Logger.info(TAG, 'encoderVideoOutput  success');
      // [End create_video_output3]

      // Create a preview stream output object
      XComponentPreviewOutput = cameraManager.createPreviewOutput(XComponentPreviewProfile, this.XComponentSurfaceId);
      if (XComponentPreviewOutput === undefined) {
        Logger.error(TAG, 'XComponentPreviewOutput is undefined');
        return;
      }

      // Create the cameraInput object.
      try {
        cameraInput = cameraManager.createCameraInput(cameraDevices[0]);
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
      // [EndExclude camera_conversation]

      // Create a session flow
      try {
        videoSession = cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to create the session instance. error: ${JSON.stringify(err)}`);
      }
      // [StartExclude camera_conversation]
      if (videoSession === undefined) {
        Logger.error(TAG, 'videoSession is undefined');
        return;
      }
      // [EndExclude camera_conversation]

      // Start Configuring the session.
      try {
        videoSession.beginConfig();
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to beginConfig. error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }
      // [StartExclude camera_conversation]

      // Add CameraInput to the session.
      try {
        videoSession.addInput(cameraInput);
      } catch (error) {
        // DocsDot
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to add cameraInput. error: ${JSON.stringify(err)}`);
        // DocsDot
      }
      // [EndExclude camera_conversation]
      // Add the XComponent preview stream to the session.
      try {
        videoSession.addOutput(XComponentPreviewOutput);
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to add XcomponentPreviewOutput. error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }

      // [Start add_output]
      // Add the encoder video stream to the session.
      try {
        videoSession.addOutput(encoderVideoOutput);
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to add encoderVideoOutput. error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }
      // [End add_output]

      // Submit configuration information.
      try {
        await videoSession.commitConfig();
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `videoSession commitConfig error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }

      // Set video stabilization.
      if (setVideoStabilizationMode(videoSession)) {
        // Set color space.
        setColorSpaceBeforeCommitConfig(videoSession, params.isHDRVivid);
      }

      // Session start.
      try {
        await videoSession.start();
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `videoSession start error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }

      // [Start start_video_output]
      // Start the video output stream
      encoderVideoOutput.start((err: BusinessError) => {
        // [StartExclude camera_conversation]
        if (err) {
          Logger.error(TAG, `Failed to start the encoder video output. error: ${JSON.stringify(err)}`);
          return;
        }
        Logger.info(TAG, 'Callback invoked to indicate the encoder video output start success.');
        // [EndExclude camera_conversation]
      });
      // [Start start_video_output]
      // [End camera_conversation]
    } catch (error) {
      hilog.error(0x0000, TAG, `createRecorder catch error, code: ${error.code}, message: ${error.message}`);
      return;
    }
  }

  build() {
    Stack() {
      XComponent({
        id: 'recorderXComponent',
        type: XComponentType.SURFACE,
        controller: this.XComponentController
      })
        .onLoad(() => {
          this.XComponentSurfaceId = this.XComponentController.getXComponentSurfaceId();
          this.createRecorder();
          this.playFlag = true;
          recorder.startNative();
          this.isRecorderTimeTextHide = false;
          this.getRecordTime();
        })
        .width(this.widthPx)
        .height(this.heightPx)
        .gesture(
          PinchGesture()
            .onActionUpdate((event: GestureEvent) => {
              if (videoSession) {
                let currentFov = this.fov * event.scale;
                if (currentFov > this.range[1]) {
                  currentFov = this.range[1];
                }
                if (currentFov < this.range[0]) {
                  currentFov = this.range[0];
                }
                videoSession.setZoomRatio(currentFov);
              }
            })
            .onActionEnd((event: GestureEvent) => {
              if (videoSession) {
                this.fov = videoSession.getZoomRatio();
              }
            })
        )

      if (!this.isRecorderTimeTextHide) {
        Text(this.videoRecorderTimeText)
          .fontFamily('HarmonyHeilTi-Light')
          .fontSize(27)
          .fontColor(Color.White)
          .align(Alignment.Bottom)
          .margin({ bottom: $r('app.float.recorder_time_margin_bottom') })
      }

      Image($r('app.media.camera_pause_video_4x'))
        .width($r('app.float.recorder_image_width'))
        .height($r('app.float.recorder_image_height'))
        .margin({ top: $r('app.float.recorder_image_margin_top') })
        .onClick(() => {
          this.buttonEnabled = false;
          this.release();
          this.isBack = true;
          this.getUIContext().getRouter().back();
        })
        .enabled(this.buttonEnabled)
    }
    .width(Const.FULL_SIZE)
    .height(Const.FULL_SIZE)
    .backgroundColor(Color.Black)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}