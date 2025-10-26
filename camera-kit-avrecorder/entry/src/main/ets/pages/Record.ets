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
import { router } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import Logger from '../utils/Logger';
import { FileUtil } from '../utils/FileUtil';
import { CommonConstants } from '../common/CommonConstants';
import { RouterParams } from '../utils/RouterParams';

const TAG: string = 'Record';
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.UIAbilityContext;

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
  @State captureSession: camera.Session | undefined = undefined;
  @State cameraInput: camera.CameraInput | undefined = undefined;
  @State previewOutput: camera.PreviewOutput | undefined = undefined;
  @State avRecorder: media.AVRecorder | undefined = undefined;
  private mXComponentController: XComponentController = new XComponentController;
  private surfaceId: string = '';
  url: string = '';

  aboutToAppear() {
    this.path = context.filesDir + '/' + 'VIDEO_' + Date.parse(new Date().toString()) + '.mp4';
    let file = FileUtil.createOrOpen(this.path);
    if (file) {
      this.url = 'fd://' + file.fd;
      this.videoUri = fileUri.getUriFromPath(this.path);
    } else {
      Logger.error(TAG, 'open file failed.');
    }
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
          this.mXComponentController.setXComponentSurfaceRect({
            surfaceWidth: 1080,
            surfaceHeight: 1920
          })
          await this.initCamera(this.getUIContext().getHostContext()!, this.surfaceId);
        })
        .height(CommonConstants.SEVENTY_PERCENT)
        .margin({
          top: CommonConstants.FIFTEEN_PERCENT
        })
      Column() {
        Blank()
        Row() {
          Image(this.recording ? $r('app.media.camera_pause_video_4x') : $r('app.media.camera_take_video_4x'))
            .width(this.getUIContext().px2vp(CommonConstants.IMAGE_SIZE))
            .height(this.getUIContext().px2vp(CommonConstants.IMAGE_SIZE))
            .onClick(async () => {
              if (this.recording) {
                await this.stopRecord();
                let options: router.RouterOptions = {
                  url: '',
                  params: new RouterParams('Sandbox path', this.path)
                }
                this.getUIContext().getRouter().back(options);
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

  async initCamera(context: common.Context, surfaceId: string) {
    try {
      this.cameraManager = camera.getCameraManager(context);
    } catch (error) {
      Logger.error(TAG, `camera.getCameraManager failed. error is: ${JSON.stringify(error)}`);
    }

    if (!this.cameraManager) {
      Logger.error(TAG, 'camera.getCameraManager error');
      return;
    }

    this.cameraManager.on('cameraStatus', (err: BusinessError, cameraStatusInfo: camera.CameraStatusInfo) => {
      if (err) {
        Logger.error(TAG, `cameraStatus call failed. error code: ${err.code}`);
      }
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

    if (cameraArray.length <= 0) {
      Logger.error(TAG, 'cameraManager.getSupportedCameras error');
      return;
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

    // [Start recording_parameters]
    let videoProfilesArray: Array<camera.VideoProfile> = cameraOutputCap.videoProfiles;
    if (!videoProfilesArray) {
      Logger.error(TAG, 'createOutput videoProfilesArray === null || undefined');
    }
    // [StartExclude recording_parameters]
    // [Start set_profile]
    let videoSize: camera.Size = {
      width: 1920,
      height: 1080
    }

    // [Start create_video_output]
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      return profile.size.width === videoSize.width && profile.size.height === videoSize.height;
    });
    // [StartExclude create_video_output]
    if (!videoProfile) {
      Logger.error(TAG, 'videoProfile is not found');
      return;
    }
    // [EndExclude create_video_output]
    // [EndExclude recording_parameters]

    let aVRecorderProfile: media.AVRecorderProfile = {
      // [StartExclude set_profile]
      // [StartExclude recording_parameters]
      audioBitrate: 48000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
      // [EndExclude recording_parameters]
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: 2000000,
      // [EndExclude set_profile]
      videoCodec: media.CodecMimeType.VIDEO_AVC,
      // [StartExclude set_profile]
      videoFrameWidth: videoSize.width,
      videoFrameHeight: videoSize.height,
      videoFrameRate: 30
      // [EndExclude set_profile]
    };
    // [End set_profile]

    // [StartExclude create_video_output]
    let aVRecorderConfig: media.AVRecorderConfig = {
      // [StartExclude recording_parameters]
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      // [EndExclude recording_parameters]
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: aVRecorderProfile,
      url: this.url,
      rotation: 90,
      // [StartExclude recording_parameters]
      location: {
        latitude: 30,
        longitude: 130
      }
      // [EndExclude recording_parameters]
    };
    // [End recording_parameters]

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
      await this.avRecorder.prepare(aVRecorderConfig);
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
      ;
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
      previewOutput = this.cameraManager.createPreviewOutput(videoProfile, surfaceId);
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
      try {
        if (this.captureSession) {
          this.captureSession.stop();
        }
        if (this.cameraInput) {
          this.cameraInput.close();
        }
        if (this.previewOutput) {
          this.previewOutput.release();
        }
        if (this.videoOutput) {
          this.videoOutput.release();
        }
        if (this.captureSession) {
          this.captureSession.release();
        }
        if (this.captureSession) {
          this.captureSession = undefined;
        }
      } catch (error) {
        let err = error as BusinessError;
        Logger.error(TAG, `avRecorder stop error: ${JSON.stringify(err)}`);
      }
    }
  }
}