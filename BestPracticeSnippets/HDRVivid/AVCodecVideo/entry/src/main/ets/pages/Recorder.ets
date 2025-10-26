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

import { camera } from '@kit.CameraKit';
import { fileIo } from '@kit.CoreFileKit';
import { display } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import recorder from 'librecorder.so';
import Logger from '../common/utils/Logger';
import { dateTime } from '../common/utils/DateTimeUtils';
import { CommonConstants as Const } from '../common/CommonConstants';
import { CameraDataModel } from '../model/CameraDateModel';
import { previewProfileCameraCheck, videoProfileCheck } from '../common/utils/CameraCheck';
import { colorSpaceManager } from '@kit.ArkGraphics2D';

const TAG: string = Const.RECORDER_TAG;
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const router = uiContext?.getRouter();
const params: CameraDataModel = router?.getParams() as CameraDataModel;

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
  // Stop the Session.
  videoSession.stop()
    .then(() => {
      Logger.info(TAG, `videoSession stop success`);
    })
    .catch((error: BusinessError) => {
      Logger.error(TAG, `videoSession stop. code=${error.code}, message=${error.message}`);
    })
  // Close file fd.
  fileIo.close(params.outputfd)
    .then(() => {
      Logger.info(TAG, `fileIo close success`);
    })
    .catch((error: BusinessError) => {
      Logger.error(TAG, `fileIo close. code=${error.code}, message=${error.message}`);
    })
  // Close camera input stream.
  cameraInput.close()
    .then(() => {
      Logger.info(TAG, `cameraInput close success`);
    })
    .catch((error: BusinessError) => {
      Logger.error(TAG, `cameraInput close. code=${error.code}, message=${error.message}`);
    })
  // Release preview output stream.
  XComponentPreviewOutput.release()
    .then(() => {
      Logger.info(TAG, `XComponentPreviewOutput release success`);
    })
    .catch((error: BusinessError) => {
      Logger.error(TAG, `XComponentPreviewOutput release. code=${error.code}, message=${error.message}`);
    })
  // Release the video output stream.
  encoderVideoOutput.release()
    .then(() => {
      Logger.info(TAG, 'encoderVideoOutput release success');
    })
    .catch((error: BusinessError) => {
      Logger.error(TAG, `encoderVideoOutput release. code=${error.code}, message=${error.message}`);
    })
  // Release session.
  videoSession.release()
    .then(() => {
      Logger.info(TAG, 'videoSession release');
    })
    .catch((error: BusinessError) => {
      Logger.error(TAG, `videoSession release. code=${error.code}, message=${error.message}`);
    })
}

// [Start set_video_color]
function isVideoStabilizationModeSupported(session: camera.VideoSession, mode: camera.VideoStabilizationMode): boolean {
  let isSupported: boolean = false;
  try {
    isSupported = session.isVideoStabilizationModeSupported(mode);
  } catch (error) {
    // If the failure occurs, the error code error.code is returned and processed
    let err = error as BusinessError;
    console.error(`The isVideoStabilizationModeSupported call failed. error code: ${err.code}`);
  }
  return isSupported;
}

function setVideoStabilizationMode(session: camera.VideoSession): boolean {
  let mode: camera.VideoStabilizationMode = camera.VideoStabilizationMode.AUTO;
  // Check whether video anti-shake is supported
  let isSupported: boolean = isVideoStabilizationModeSupported(session, mode);
  if (isSupported) {
    Logger.info(TAG, `setVideoStabilizationMode: ${mode}`);
    try {
      // Setting video anti-shake
      session.setVideoStabilizationMode(mode);
      let activeVideoStabilizationMode = session.getActiveVideoStabilizationMode();
      Logger.info(TAG, `activeVideoStabilizationMode: ${activeVideoStabilizationMode}`);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`fileIo open failed. code=${error.code}, message=${error.message}`);
    }
  } else {
    console.info(`videoStabilizationMode: ${mode} is not support`);
  }
  return isSupported;
}

function getSupportedColorSpaces(session: camera.VideoSession): Array<colorSpaceManager.ColorSpace> {
  let colorSpaces: Array<colorSpaceManager.ColorSpace> = [];
  try {
    colorSpaces = session.getSupportedColorSpaces();
  } catch (error) {
    let err = error as BusinessError;
    console.error(`The getSupportedColorSpaces call failed. error code: ${err.code}`);
  }
  return colorSpaces;
}

// Set the color space
function setColorSpaceBeforeCommitConfig(session: camera.VideoSession, isHdr: boolean): void {
  let colorSpace: colorSpaceManager.ColorSpace =
    isHdr ? colorSpaceManager.ColorSpace.BT2020_HLG_LIMIT : colorSpaceManager.ColorSpace.BT709_LIMIT;
  let colorSpaces: Array<colorSpaceManager.ColorSpace> = getSupportedColorSpaces(session);
  let isSupportedColorSpaces = colorSpaces.indexOf(colorSpace) >= 0;
  if (isSupportedColorSpaces) {
    console.info(`setColorSpace: ${colorSpace}`);
    try {
      session.setColorSpace(colorSpace);
      let activeColorSpace: colorSpaceManager.ColorSpace = session.getActiveColorSpace();
      console.info(`activeColorSpace: ${activeColorSpace}`);
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`fileIo open failed. code=${error.code}, message=${error.message}`);
    }
  } else {
    console.info(`colorSpace: ${colorSpace} is not support`);
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
  private display: display.Display | null = null;
  private heightPx: string = '';
  private widthPx: string = '';
  private timer: number = Const.DEFAULT_VALUE;
  private seconds: number = Const.DEFAULT_VALUE;
  private isReleased: boolean = false;
  private isBack: boolean = false;
  private range: number[] = [];

  aboutToAppear(): void {
    try {
      this.display = display.getDefaultDisplaySync();
      this.heightPx = (this.display.width * this.cameraWidth / this.cameraHeight) + Const.PX;
      this.widthPx = this.display.width + Const.PX;
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`getDefaultDisplaySync failed. code=${error.code}, message=${error.message}`);
    }
  }

  onBackPress() {
    this.isBack = true;
  }

  onPageHide() {
    this.release();
    if (!this.isBack) {
      let uiContext = this.getUIContext();
      let router = uiContext.getRouter();
      router.back();
    }
  }

  async release(): Promise<void> {
    if (!this.isReleased) {
      this.isReleased = true;
      clearInterval(this.timer);
      this.seconds = 0;
      this.videoRecorderTimeText = Const.DEFAULT_TIME;

      recorder.stopNative().then(async (data) => {
        if (data.code === 0) {
          await releaseCamera();
          this.playFlag = false;
        }
      });
    }
  }

  getRecordTime(): void {
    this.timer = setInterval(() => {
      this.seconds += 1;
      this.videoRecorderTimeText = dateTime(this.seconds);
    }, 1000);
  }

  async createRecorder(): Promise<void> {
    releaseCamera();
    // Create the CameraManager object.
    let context = this.getUIContext()?.getHostContext();
    try {


      let cameraManager = camera.getCameraManager(context);
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

      // Gets supported mode types
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
      let XComponentPreviewProfile: camera.Profile | undefined = previewProfileCameraCheck(cameraManager, params)
      if (XComponentPreviewProfile === undefined) {
        Logger.error(TAG, 'XComponentPreviewProfile is not found');
        return;
      }
      // [StartExclude camera_conversation]
      // [EndExclude create_video_output3]

      // Create a video output instance
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

      // Start a configuration session
      try {
        videoSession.beginConfig();
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to beginConfig. error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }
      // [StartExclude camera_conversation]
      try {
        videoSession.addInput(cameraInput);
      } catch (error) {
        // DocsDot
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to add cameraInput. error: ${JSON.stringify(err)}`);
        // DocsDot
      }
      // [EndExclude camera_conversation]
      // Add an XComponent preview stream to a session
      try {
        videoSession.addOutput(XComponentPreviewOutput);
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to add XcomponentPreviewOutput. error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }

      try {
        videoSession.addOutput(encoderVideoOutput);
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `Failed to add encoderVideoOutput. error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }

      try {
        await videoSession.commitConfig();
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `videoSession commitConfig error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }

      // Setting video anti-shake
      if (setVideoStabilizationMode(videoSession)) {
        // Set the color space
        setColorSpaceBeforeCommitConfig(videoSession, true);
      }

      try {
        await videoSession.start();
      } catch (error) {
        // [StartExclude camera_conversation]
        let err = error as BusinessError;
        Logger.error(TAG, `videoSession start error: ${JSON.stringify(err)}`);
        // [EndExclude camera_conversation]
      }
    } catch (err) {
      let error = err as BusinessError;
      Logger.error(`error.code=${error.code}, error.message=${error.message}`);
    }
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
    // [End camera_conversation]
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
                try {
                  videoSession.setZoomRatio(currentFov);
                } catch (err) {
                  let error = err as BusinessError;
                  Logger.error(`setZoomRatio failed. code=${error.code}, message=${error.message}`);
                }
              }
            })
            .onActionEnd((event: GestureEvent) => {
              if (videoSession) {
                try {
                  this.fov = videoSession.getZoomRatio();
                } catch (err) {
                  let error = err as BusinessError;
                  Logger.error(`getZoomRatio failed. code=${error.code}, message=${error.message}`);
                }
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
          let uiContext = this.getUIContext();
          let router = uiContext.getRouter();
          router.back();
        })
        .enabled(this.buttonEnabled)
    }
    .width(Const.FULL_SIZE)
    .height(Const.FULL_SIZE)
    .backgroundColor(Color.Black)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}