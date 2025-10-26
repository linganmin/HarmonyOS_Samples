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
import { camera } from '@kit.CameraKit';
import { media } from '@kit.MediaKit';
import { fileUri } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import Logger from '../utils/Logger';
import { FileUtil } from '../utils/FileUtil';
import { CommonConstants } from '../common/CommonConstants';
import { RouterParams } from '../utils/RouterParams';
import { router } from '@kit.ArkUI';

const TAG: string = 'Record';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const context = uiContext?.getHostContext() as common.UIAbilityContext;
let routerObj = uiContext?.getRouter();

@Entry
@Component
struct Record {
  @State xComponentWidth: number = 0;
  @State xComponentHeight: number = 0;
  @State videoUri: string = '';
  @State recording: boolean = false;
  @State path: string = '';
  @State cameraManager: camera.CameraManager | undefined = undefined;
  @State videoOutput: camera.VideoOutput | undefined = undefined;
  @State captureSession: camera.VideoSession | undefined = undefined;
  @State cameraInput: camera.CameraInput | undefined = undefined;
  @State previewOutput: camera.PreviewOutput | undefined = undefined;
  @State avRecorder: media.AVRecorder | undefined = undefined;
  private mXComponentController: XComponentController = new XComponentController;
  private surfaceId: string = '';
  url: string = '';

  aboutToAppear() {
    this.path = context.filesDir + '/' + 'VIDEO_' + Date.parse(new Date().toString()) + '.mp4';
    let file = FileUtil.createOrOpen(this.path);
    this.url = 'fd://' + file?.fd;
    this.videoUri = fileUri.getUriFromPath(this.path);
  }

  build() {
    Stack({ alignContent: Alignment.Top }) {
      XComponent({
        id: 'componentId',
        type: XComponentType.SURFACE,
        controller: this.mXComponentController,
      })
        .onLoad(async () => {
          this.surfaceId = this.mXComponentController.getXComponentSurfaceId();
          await this.initCamera(uiContext?.getHostContext(), this.surfaceId);
        })
        .height(CommonConstants.SEVENTY_PERCENT)
        .margin({
          top: CommonConstants.FIFTEEN_PERCENT
        })
      Column() {
        Blank()
        Row() {
          Image(this.recording ? $r('app.media.camera_pause_video_4x') : $r('app.media.camera_take_video_4x'))
            .width(uiContext?.px2vp(CommonConstants.IMAGE_SIZE))
            .height(uiContext?.px2vp(CommonConstants.IMAGE_SIZE))
            .onClick(async () => {
              if (this.recording) {
                await this.stopRecord();
                let options: router.RouterOptions = {
                  url: '',
                  params: new RouterParams('Sandbox path', this.path)
                }
                routerObj?.back(options);
              } else {
                this.startRecord();
              }
              this.recording = !this.recording;
            })
        }
        .width(CommonConstants.FULL_PERCENT)
        .height($r('app.float.image_height'))
        .margin({ bottom: $r('app.float.image_margin_bottom') })
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width(CommonConstants.FULL_PERCENT)
      .height(CommonConstants.FULL_PERCENT)
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Start)
    }
    .backgroundColor(Color.Black)
    .width(CommonConstants.FULL_PERCENT)
    .height(CommonConstants.FULL_PERCENT)
  }

  async initCamera(context: common.Context | undefined, surfaceId: string) {
    // this.cameraManager = camera.getCameraManager(context);
    try {
      this.cameraManager = camera.getCameraManager(context)
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getCameraManager failed, code=${err.code}, message=${err.message}`);
    }

    if (!this.cameraManager) {
      Logger.error(TAG, 'camera.getCameraManager error');
      return;
    }

    this.cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      Logger.info(TAG, `camera : ${cameraStatusInfo.camera.cameraId}`);
      Logger.info(TAG, `status:  ${cameraStatusInfo.status}`);
    });

    let cameraArray: Array<camera.CameraDevice> = [];
    try {
      cameraArray = this.cameraManager.getSupportedCameras();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getSupportedCameras call failed. error code: ${err.code}`);
    }

    let cameraOutputCap: camera.CameraOutputCapability =
      this.cameraManager.getSupportedOutputCapability(cameraArray[0], camera.SceneMode.NORMAL_VIDEO);
    if (!cameraOutputCap) {
      Logger.error(TAG, 'cameraManager.getSupportedOutputCapability error');
      return;
    }
    Logger.info(TAG, 'outputCapability: ' + JSON.stringify(cameraOutputCap));

    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    if (!previewProfilesArray) {
      Logger.error(TAG, 'createOutput previewProfilesArray === null || undefined');
    }

    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;
    if (!photoProfilesArray) {
      Logger.error(TAG, 'createOutput photoProfilesArray === null || undefined');
    }

    let videoProfilesArray: Array<camera.VideoProfile> = cameraOutputCap.videoProfiles;
    if (!videoProfilesArray) {
      Logger.error(TAG, 'createOutput videoProfilesArray === null || undefined');
    }

    // [Start set_profile]
    let videoSize: camera.Size = {
      width: 1280,
      height: 720
    }
    // Set the variables isHdr and videoCodec in the configuration parameter AVRecorderProfile.
    let avRecorderProfile: media.AVRecorderProfile = {
      // [StartExclude set_profile]
      audioBitrate: 48000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: 2000000,
      // [EndExclude set_profile]
      videoCodec: media.CodecMimeType.VIDEO_HEVC,
      // [StartExclude set_profile]
      videoFrameWidth: videoSize.width,
      videoFrameHeight: videoSize.height,
      videoFrameRate: 30,
      // [EndExclude set_profile]
      isHdr: true
    };
    // [End set_profile]

    // [Start create_video_output]
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      return profile.size.width === videoSize.width && profile.size.height === videoSize.height &&
        profile.format === camera.CameraFormat.CAMERA_FORMAT_YCRCB_P010;
    });

    let previewProfile: undefined | camera.Profile = previewProfilesArray.find((profile: camera.Profile) => {
      return profile.format === camera.CameraFormat.CAMERA_FORMAT_YCRCB_P010 &&
        profile.size.width === videoSize.width && profile.size.height == videoSize.height
    });

    // [StartExclude create_video_output]
    if (!videoProfile) {
      Logger.error(TAG, 'videoProfile is not found');
      return;
    }
    // [EndExclude create_video_output]

    // [StartExclude create_video_output]
    let avRecorderConfig: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: avRecorderProfile,
      url: this.url,
      rotation: 0,
      location: {
        latitude: 30,
        longitude: 130
      }
    };

    // [Start create_av_recorder]
    // Creating an AVRecorder Instance
    try {
      this.avRecorder = await media.createAVRecorder();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `createAVRecorder call failed. error code: ${err.code}`);
    }
    // [End create_av_recorder]

    if (this.avRecorder === undefined) {
      return;
    }
    // [EndExclude create_video_output]

    try {
      await this.avRecorder.prepare(avRecorderConfig);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `prepare call failed. error code: ${err.code}`);
    }

    let videoSurfaceId: string | undefined = undefined;
    try {
      videoSurfaceId = await this.avRecorder.getInputSurface();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `getInputSurface call failed. error code: ${err.code}`);
    }
    if (videoSurfaceId === undefined) {
      return;
    }

    try {
      this.videoOutput = this.cameraManager.createVideoOutput(videoProfile, videoSurfaceId);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to create the videoOutput instance. error: ${JSON.stringify(err)}`);
    }
    // [End create_video_output]

    if (this.videoOutput === undefined) {
      return;
    }
    this.videoOutput.on('frameStart', () => {
      Logger.info(TAG, 'Video frame started');
    });

    this.videoOutput.on('error', (error: BusinessError) => {
      Logger.info(TAG, `Preview output error code: ${error.code}`);
    });

    // [Start set_session]
    // Create and configure a camera session
    try {
      this.captureSession = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
    } catch (error) {
      // [StartExclude set_session]
      let err = error as BusinessError;
      Logger.error(TAG, 'Failed to create the CaptureSession instance. errorCode = ' + err.code);
      // [EndExclude set_session]
    }
    // [StartExclude set_session]
    if (this.captureSession === undefined) {
      return;
    }
    // [EndExclude set_session]

    try {
      this.captureSession.beginConfig();
    } catch (error) {
      // [StartExclude set_session]
      let err = error as BusinessError;
      Logger.error(TAG, 'Failed to beginConfig. errorCode = ' + err.code);
      // [EndExclude set_session]
    }

    // [StartExclude set_session]
    let cameraInput: camera.CameraInput | undefined = undefined;
    try {
      cameraInput = this.cameraManager.createCameraInput(cameraArray[0]);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to createCameraInput. error: ${JSON.stringify(err)}`);
    }
    if (cameraInput === undefined) {
      return;
    }

    let cameraDevice: camera.CameraDevice = cameraArray[0];
    cameraInput.on('error', cameraDevice, (error: BusinessError) => {
      Logger.info(TAG, `Camera input error code: ${error.code}`);
    });

    try {
      await cameraInput.open();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to open cameraInput. error: ${JSON.stringify(err)}`);
    }

    try {
      this.captureSession.addInput(cameraInput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add cameraInput. error: ${JSON.stringify(err)}`);
    }

    let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      previewOutput = this.cameraManager.createPreviewOutput(previewProfile, surfaceId);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to create the PreviewOutput instance. error: ${JSON.stringify(err)}`);
    }

    if (previewOutput === undefined) {
      return;
    }

    try {
      this.captureSession.addOutput(previewOutput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add previewOutput. error: ${JSON.stringify(err)}`);
    }

    try {
      this.captureSession.addOutput(this.videoOutput);
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `Failed to add videoOutput. error: ${JSON.stringify(err)}`);
    }
    // [EndExclude set_session]

    try {
      await this.captureSession.commitConfig();
    } catch (error) {
      // [StartExclude set_session]
      let err = error as BusinessError;
      Logger.error(TAG, `captureSession commitConfig error: ${JSON.stringify(err)}`);
      // [EndExclude set_session]
    }

    let mode: camera.VideoStabilizationMode = camera.VideoStabilizationMode.AUTO;
    // Check whether video anti-shake is supported
    let isSupported: boolean = false;
    try {
      isSupported = this.captureSession.isVideoStabilizationModeSupported(mode);
      Logger.info(TAG, `isVideoStabilizationModeSupported: ${JSON.stringify(isSupported)}`);
    } catch (error) {
      // If the failure occurs, the error code error.code is returned and processed
      let err = error as BusinessError;
      Logger.error(`The isVideoStabilizationModeSupported call failed. error code: ${err.code}`);
    }
    if (isSupported) {
      try {
        // Setting video anti-shake
        this.captureSession.setVideoStabilizationMode(mode);
        let activeVideoStabilizationMode = this.captureSession.getActiveVideoStabilizationMode();
        Logger.info(`activeVideoStabilizationMode: ${activeVideoStabilizationMode}`);
      } catch (error) {
        let err = error as BusinessError;
        Logger.warn(TAG,
          `setVideoStabilizationMode or getActiveVideoStabilizationMode failed, code=${err.code}, message=${err.message}`);
      }
    } else {
      Logger.error(`videoStabilizationMode: ${mode} is not support`);
    }

    // Set the color space of the camera session to BT2020_HLG_LIMIT
    if (isSupported) {
      let colorSpace: colorSpaceManager.ColorSpace = colorSpaceManager.ColorSpace.BT2020_HLG_LIMIT;
      let colorSpaces: Array<colorSpaceManager.ColorSpace> = [];
      try {
        colorSpaces = this.captureSession.getSupportedColorSpaces();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(`The getSupportedColorSpaces call failed. error code: ${err.code}`);
      }
      let isSupportedColorSpaces = colorSpaces.indexOf(colorSpace) >= 0;
      if (isSupportedColorSpaces) {
        Logger.info(`setColorSpace: ${colorSpace}`);
        try {
          this.captureSession.setColorSpace(colorSpace);
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(`The setColorSpace call failed, error code: ${err.code}`);
        }
        try {
          let activeColorSpace: colorSpaceManager.ColorSpace = this.captureSession.getActiveColorSpace();
          Logger.info(`activeColorSpace: ${activeColorSpace}`);
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(`getActiveColorSpace failed, code=${err.code}, message=${err.message}`);
        }
      } else {
        Logger.error(`colorSpace: ${colorSpace} is not support`);
      }
    }

    try {
      await this.captureSession.start();
    } catch (error) {
      let err = error as BusinessError;
      Logger.error(TAG, `captureSession start error: ${JSON.stringify(err)}`);
    }
    // [End set_session]

    // [Start start_fn]
    this.videoOutput.start((err: BusinessError) => {
      if (err) {
        Logger.error(TAG, `Failed to start the video output. error: ${JSON.stringify(err)}`);
        return;
      }
      Logger.info(TAG, 'Callback invoked to indicate the video output start success.');
    });
    // [End start_fn]
  }

  // [Start start_record]
  async startRecord() {
    if (this.avRecorder) {
      try {
        await this.avRecorder.start();
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avRecorder start error: ${JSON.stringify(err)}`);
      }
    }
  }

  // [End start_record]

  async stopRecord() {
    if (this.avRecorder) {
      try {
        if (this.videoOutput) {
          this.videoOutput.stop((err: BusinessError) => {
            if (err) {
              Logger.error(TAG, `Failed to stop the video output. error: ${JSON.stringify(err)}`);
              return;
            }
            Logger.info(TAG, 'Callback invoked to indicate the video output stop success.');
          });
        }
        try {
          await this.avRecorder.stop();
          await this.avRecorder.release();
        } catch (error) {
          let err = error as BusinessError;
          Logger.error(TAG, `avRecorder stop error: ${JSON.stringify(err)}`);
        }
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avRecorder stop error: ${JSON.stringify(err)}`);
      }
      if (this.captureSession) {
        this.captureSession.stop()
          .catch((err: BusinessError) => {
            Logger.error(`avRecorder stop failed, code=${err.code}, message=${err.message}`)
          })
      }
      if (this.cameraInput) {
        this.cameraInput.close()
          .catch((err: BusinessError) => {
            Logger.error(`avRecorder close failed, code=${err.code}, message=${err.message}`)
          })
      }
      if (this.previewOutput) {
        this.previewOutput.release()
          .catch((err: BusinessError) => {
            Logger.error(`avRecorder release failed, code=${err.code}, message=${err.message}`)
          })
      }
      if (this.videoOutput) {
        this.videoOutput.release()
          .catch((err: BusinessError) => {
            Logger.error(`avRecorder release failed, code=${err.code}, message=${err.message}`)
          })
      }
      if (this.captureSession) {
        this.captureSession.release()
          .catch((err: BusinessError) => {
            Logger.error(`avRecorder release failed, code=${err.code}, message=${err.message}`)
          })
      }
      if (this.captureSession) {
        this.captureSession = undefined;
      }
    }
  }
}