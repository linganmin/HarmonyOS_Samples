/*
 * Copyright (C) 2025 Huawei Device Co., Ltd.
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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { media } from '@kit.MediaKit';
import { FileUtil } from '../common/utils/FileUtil';
import DateTimeUtil from '../common/utils/DateTimeUtils';
import { setVideoStabilizationMode, setColorSpaceBeforeCommitConfig } from '../common/utils/VideoOperationUtils';
import { CameraDataModel } from '../model/CameraDateModel';


const DATETIME: DateTimeUtil = new DateTimeUtil();
const TAG: string = '[RecordController]';

export class RecordController {
  private path: string = '';
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private previewOutput: camera.PreviewOutput | undefined = undefined;
  private videoOutput: camera.VideoOutput | undefined = undefined;
  private cameraData: CameraDataModel = AppStorage.get('cameraData') as CameraDataModel;
  private avRecorder: media.AVRecorder | undefined = undefined;
  private captureSession: camera.VideoSession | undefined = undefined;
  private url: string = '';

  public async initCamera(context: common.Context, surfaceId: string) {
    try {
      this.cameraManager = camera.getCameraManager(context);
    } catch (error) {
      hilog.error(0x0000, TAG, `camera.getCameraManager failed. code is =${error.code}, message is = ${error.message}`);
    }
    if (!this.cameraManager) {
      hilog.error(0x0000, TAG, 'camera.getCameraManager error');
      return;
    }
    this.path = context.filesDir + `/VIDEO_${DATETIME.getDate()}_${DATETIME.getTime()}.mp4`;
    let file = FileUtil.createOrOpen(this.path);
    if (file) {
      this.url = 'fd://' + file.fd;
    }

    let cameraArray: Array<camera.CameraDevice> = [];
    try {
      cameraArray = this.cameraManager.getSupportedCameras();
    } catch (error) {
      hilog.error(0x0000, TAG, `getSupportedCameras call failed. code is =${error.code}, message is = ${error.message}`);
    }

    if (cameraArray.length <= 0) {
      hilog.error(0x0000, TAG, 'cameraManager.getSupportedCameras error');
      return;
    }

    let cameraOutputCap: camera.CameraOutputCapability =
      this.cameraManager.getSupportedOutputCapability(cameraArray[0], camera.SceneMode.NORMAL_VIDEO);
    if (!cameraOutputCap) {
      hilog.error(0x0000, TAG, 'cameraManager.getSupportedOutputCapability error');
      return;
    }

    let previewProfilesArray: Array<camera.Profile> = cameraOutputCap.previewProfiles;
    if (!previewProfilesArray) {
      hilog.error(0x0000, TAG, 'createOutput previewProfilesArray === null || undefined');
    }

    let photoProfilesArray: Array<camera.Profile> = cameraOutputCap.photoProfiles;
    if (!photoProfilesArray) {
      hilog.error(0x0000, TAG, 'createOutput photoProfilesArray === null || undefined');
    }

    // [Start recording_parameters]
    let videoProfilesArray: Array<camera.VideoProfile> = cameraOutputCap.videoProfiles;
    if (!videoProfilesArray) {
      hilog.error(0x0000, TAG, 'createOutput videoProfilesArray === null || undefined');
    }
    // [StartExclude recording_parameters]
    // [Start set_profile]

    // [Start create_video_output]
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      return profile.format === camera.CameraFormat.CAMERA_FORMAT_YCRCB_P010 &&
        profile.size.width === this.cameraData.cameraWidth && profile.size.height === this.cameraData.cameraHeight;
    });
    // [StartExclude create_video_output]
    if (!videoProfile) {
      hilog.error(0x0000, TAG, 'videoProfile is not found');
      return;
    }
    // [EndExclude create_video_output]

    let previewProfile: undefined | camera.Profile = previewProfilesArray.find((profile: camera.Profile) => {
      return profile.format === camera.CameraFormat.CAMERA_FORMAT_YCRCB_P010 &&
        profile.size.width === this.cameraData.cameraWidth && profile.size.height == this.cameraData.cameraHeight;
    });
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
      videoBitrate: this.cameraData.bitRate,
      // [EndExclude set_profile]
      videoCodec: media.CodecMimeType.VIDEO_HEVC,
      // [StartExclude set_profile]
      videoFrameWidth: this.cameraData.cameraWidth,
      videoFrameHeight: this.cameraData.cameraHeight,
      videoFrameRate: this.cameraData.frameRate,
      isHdr: true
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
      hilog.error(0x0000, TAG, `createAVRecorder call failed. code is =${error.code}, message is = ${error.message}`);
    }
    // [End create_av_recorder]

    if (this.avRecorder === undefined) {
      return;
    }
    // [EndExclude create_video_output]

    try {
      await this.avRecorder.prepare(aVRecorderConfig);
    } catch (error) {
      hilog.error(0x0000, TAG, `prepare call failed. code is =${error.code}, message is = ${error.message}`);
    }

    let videoSurfaceId: string | undefined = undefined;
    try {
      videoSurfaceId = await this.avRecorder.getInputSurface();
    } catch (error) {
      hilog.error(0x0000, TAG, `getInputSurface call failed. code is =${error.code}, message is = ${error.message}`);
    }
    if (videoSurfaceId === undefined) {
      return;
    }

    try {
      this.videoOutput = this.cameraManager.createVideoOutput(videoProfile, videoSurfaceId);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to create the videoOutput instance. code is =${error.code}, message is = ${error.message}`);
    }
    // [End create_video_output]

    if (this.videoOutput === undefined) {
      return;
    }
    this.videoOutput.on('frameStart', () => {
      hilog.info(0x0000, TAG, 'Video frame started');
    });

    this.videoOutput.on('error', (error: BusinessError) => {
      hilog.error(0x0000, TAG, `Preview output error code: ${error.code}`);
    });

    // [Start set_session]
    // Create and configure a camera session

    try {
      this.captureSession = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
    } catch (error) {
      // [StartExclude set_session]
      hilog.error(0x0000, TAG, `Failed to create the CaptureSession instance. code is =${error.code}, message is = ${error.message}`);
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
      hilog.error(0x0000, TAG, `Failed to beginConfig. code is =${error.code}, message is = ${error.message}`);
      // [EndExclude set_session]
    }

    // [StartExclude set_session]
    try {
      this.cameraInput = this.cameraManager.createCameraInput(cameraArray[0]);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to createCameraInput. code is =${error.code}, message is = ${error.message}`);
    }
    if (this.cameraInput === undefined) {
      return;
    }

    let cameraDevice: camera.CameraDevice = cameraArray[0];
    this.cameraInput.on('error', cameraDevice, (error: BusinessError) => {
      hilog.info(0x0000, TAG, `Camera input error. code is =${error.code}, message is = ${error.message}`);
    });

    try {
      await this.cameraInput.open();
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to open cameraInput. code is =${error.code}, message is = ${error.message}`);
    }

    try {
      this.captureSession.addInput(this.cameraInput);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to add cameraInput. code is =${error.code}, message is = ${error.message}`);
    }

    // let previewOutput: camera.PreviewOutput | undefined = undefined;
    try {
      this.previewOutput = this.cameraManager.createPreviewOutput(previewProfile, surfaceId);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to create the PreviewOutput instance. code is =${error.code}, message is = ${error.message}`);
    }

    if (this.previewOutput === undefined) {
      return;
    }

    try {
      this.captureSession.addOutput(this.previewOutput);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to add previewOutput. code is =${error.code}, message is = ${error.message}`);
    }

    try {
      this.captureSession.addOutput(this.videoOutput);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to add videoOutput. code is =${error.code}, message is = ${error.message}`);
    }
    // [EndExclude set_session]

    try {
      await this.captureSession.commitConfig();
    } catch (error) {
      // [StartExclude set_session]
      hilog.error(0x0000, TAG, `captureSession commitConfig code is =${error.code}, message is = ${error.message}`);
      // [EndExclude set_session]
    }

    // Set video stabilization.
    if (setVideoStabilizationMode(this.captureSession)) {
      // Set color space.
      setColorSpaceBeforeCommitConfig(this.captureSession, this.cameraData.isHDRVivid);
    }

    try {
      await this.captureSession.start();
    } catch (error) {
      hilog.error(0x0000, TAG, `captureSession start code is =${error.code}, message is = ${error.message}`);
    }
    // [End set_session]

    // [Start start_fn]
    this.videoOutput.start((error: BusinessError) => {
      if (error) {
        hilog.error(0x0000, TAG, `Failed to start the video output. code is =${error.code}, message is = ${error.message}`);
        return;
      }
      hilog.info(0x0000, TAG, 'Callback invoked to indicate the video output start success.');
    });
    // [End start_fn]
  }

  /**
   * @throws
   */
  public async stopRecord() {
    if (this.avRecorder) {
      try {
        if (this.videoOutput) {
          this.videoOutput.stop((error: BusinessError) => {
            if (error) {
              hilog.error(0x0000, TAG, `Failed to stop the video output. code is =${error.code}, message is = ${error.message}`);
              return;
            }
            hilog.info(0x0000, TAG, 'Callback invoked to indicate the video output stop success.');
          });
        }
        try {
          await this.avRecorder.stop();
          await this.avRecorder.release();
        } catch (error) {
          hilog.error(0x0000, TAG, `avRecorder stop code is =${error.code}, message is = ${error.message}`);
        }
      } catch (error) {
        hilog.error(0x0000, TAG, `avRecorder stop code is =${error.code}, message is = ${error.message}`);
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
        hilog.error(0x0000, TAG, `avRecorder stop code is =${error.code}, message is = ${error.message}`);
      }
      AppStorage.set('path', this.path);
    }
  }

  public async startRecord() {
    if (this.avRecorder) {
      try {
        await this.avRecorder.start();
      } catch (error) {
        hilog.error(0x0000, TAG, `avRecorder start code is =${error.code}, message is = ${error.message}`);
      }
    }
  }
}