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
import { FileUtil } from '../common/utils/FileUtil';
import DateTimeUtil from '../common/utils/DateTimeUtils';
import { CameraDataModel } from '../model/CameraDateModel';
import recorder from 'librecorder.so';
import { setVideoStabilizationMode, setColorSpaceBeforeCommitConfig } from '../common/utils/VideoOperationUtils';
import { fileIo } from '@kit.CoreFileKit';

const DATETIME: DateTimeUtil = new DateTimeUtil();
const TAG: string = '[AVCodecController]';

export class AVCodecController {
  private path: string = '';
  private cameraManager: camera.CameraManager | undefined = undefined;
  private cameraInput: camera.CameraInput | undefined = undefined;
  private videoSession: camera.VideoSession | undefined = undefined;
  private cameraData: CameraDataModel = AppStorage.get('cameraData') as CameraDataModel;
  private encoderVideoOutput: camera.VideoOutput | undefined = undefined;
  private XComponentPreviewOutput: camera.PreviewOutput | undefined = undefined;

  public async createRecorder(context: common.Context, XComponentSurfaceId: string): Promise<void> {
    this.releaseCamera().catch((error:BusinessError) => {
      hilog.error(0x0000, TAG, `releaseCamera fail.  code is =${error.code}, message is = ${error.message}`);
    });
    // Create the CameraManager object.
    try {
      this.cameraManager = camera.getCameraManager(context);
    } catch (error) {
      hilog.error(0x0000, TAG, `error code is =${error.code}, getCameraManager fail, message is = ${error.message}`);
    }
    if (!this.cameraManager) {
      hilog.error(0x0000, TAG, 'camera.getCameraManager error');
      return;
    }

    this.path = context.filesDir + `/VIDEO_${DATETIME.getDate()}_${DATETIME.getTime()}.mp4`;
    let file = FileUtil.createOrOpen(this.path);
    if (file) {
      this.cameraData.outputfd = file.fd;
    }

    if (this.cameraData.outputfd !== -1) {
      await recorder.initNative(this.cameraData.outputfd, this.cameraData.videoCodecMime, this.cameraData.cameraWidth,
        this.cameraData.cameraHeight, this.cameraData.frameRate, this.cameraData.isHDRVivid,
        this.cameraData.bitRate).then((data) => {
        if (data.surfaceId !== null) {
          this.cameraData.surfaceId = data.surfaceId;
        }
      })
    }

    // Get supported camera devices.
    let cameraArray: Array<camera.CameraDevice> = this.cameraManager.getSupportedCameras();
    if (cameraArray !== undefined && cameraArray.length <= 0) {
      hilog.error(0x0000, TAG, 'cameraManager.getSupportedCameras error!');
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

    let videoProfilesArray: Array<camera.VideoProfile> = cameraOutputCap.videoProfiles;
    if (!videoProfilesArray) {
      hilog.error(0x0000, TAG, 'createOutput videoProfilesArray === null || undefined');
    }

    // [Start create_video_output3]
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      return profile.format === camera.CameraFormat.CAMERA_FORMAT_YCBCR_P010 &&
        profile.size.width === this.cameraData.cameraWidth && profile.size.height === this.cameraData.cameraHeight;
    });

    if (!videoProfile) {
      hilog.error(0x0000, TAG, 'videoProfile is not found!');
      return;
    }

    let XComponentPreviewProfile: camera.Profile | undefined = previewProfilesArray.find((profile: camera.Profile) => {
      return profile.format === camera.CameraFormat.CAMERA_FORMAT_YCRCB_P010 &&
        profile.size.width === this.cameraData.cameraWidth && profile.size.height === this.cameraData.cameraHeight;
    })
    // Create the encoder output object
    try {
      this.encoderVideoOutput = this.cameraManager.createVideoOutput(videoProfile, this.cameraData.surfaceId);
    } catch (error) {
      hilog.error(0x0000, TAG, `error code is =${error.code}, createVideoOutput fail, message is = ${error.message}`);
    }

    if (this.encoderVideoOutput === undefined) {
      hilog.error(0x0000, TAG, 'encoderVideoOutput is undefined');
      return;
    }
    // [End create_video_output3]
    // Create a preview stream output object
    try {
      this.XComponentPreviewOutput =
        this.cameraManager.createPreviewOutput(XComponentPreviewProfile, XComponentSurfaceId);
    } catch (error) {
      hilog.error(0x0000, TAG, `error code is =${error.code}, createPreviewOutput fail, message is = ${error.message}`);
    }

    if (this.XComponentPreviewOutput === undefined) {
      hilog.error(0x0000, TAG, 'XComponentPreviewOutput is undefined');
      return;
    }

    // Create the cameraInput object.
    try {
      this.cameraInput = this.cameraManager.createCameraInput(cameraArray[0]);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to createCameraInput. code is =${error.code}, message is = ${error.message}`);
    }
    if (this.cameraInput === undefined) {
      hilog.error(0x0000, TAG, 'cameraInput is undefined');
      return;
    }

    // Turn on the camera.
    try {
      await this.cameraInput.open();
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to open cameraInput. code is =${error.code}, message is = ${error.message}`);

    }
    // [EndExclude camera_conversation]

    // Create a session flow
    try {
      this.videoSession = this.cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to create the session instance. code is =${error.code}, message is = ${error.message}`);
    }
    // [StartExclude camera_conversation]
    if (this.videoSession === undefined) {
      hilog.error(0x0000, TAG, 'videoSession is undefined');
      return;
    }
    // [EndExclude camera_conversation]

    // Start Configuring the session.
    try {
      this.videoSession.beginConfig();
    } catch (error) {
      // [StartExclude camera_conversation]
      hilog.error(0x0000, TAG, `Failed to beginConfig. code is =${error.code}, message is = ${error.message}`);
      // [EndExclude camera_conversation]
    }
    // [StartExclude camera_conversation]

    // Add CameraInput to the session.
    try {
      this.videoSession.addInput(this.cameraInput);
    } catch (error) {
      hilog.error(0x0000, TAG, `Failed to add cameraInput. code is =${error.code}, message is = ${error.message}`);
    }
    // [EndExclude camera_conversation]
    // Add the XComponent preview stream to the session.
    try {
      this.videoSession.addOutput(this.XComponentPreviewOutput);
    } catch (error) {
      // [StartExclude camera_conversation]
      hilog.error(0x0000, TAG, `Failed to add XcomponentPreviewOutput. code is =${error.code}, message is = ${error.message}`);
      // [EndExclude camera_conversation]
    }

    // Add the encoder video stream to the session.
    try {
      this.videoSession.addOutput(this.encoderVideoOutput);
    } catch (error) {
      // [StartExclude camera_conversation]
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `Failed to add encoderVideoOutput. code is =${error.code}, message is = ${error.message}`);
      // [EndExclude camera_conversation]
    }

    // Submit configuration information.
    try {
      await this.videoSession.commitConfig();
    } catch (error) {
      // [StartExclude camera_conversation]
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `videoSession commitConfig code is =${error.code}, message is = ${error.message}`);
      // [EndExclude camera_conversation]
    }

    // Set video stabilization.
    if (setVideoStabilizationMode(this.videoSession)) {
      // Set color space.
      setColorSpaceBeforeCommitConfig(this.videoSession, this.cameraData.isHDRVivid);
    }

    // Session start.
    try {
      await this.videoSession.start();
    } catch (error) {
      // [StartExclude camera_conversation]
      let err = error as BusinessError;
      hilog.error(0x0000, TAG, `videoSession start. code is =${error.code}, message is = ${error.message}`);
      // [EndExclude camera_conversation]
    }

    // Start the video output stream
    this.encoderVideoOutput.start((error: BusinessError) => {
      // [StartExclude camera_conversation]
      if (error) {
        hilog.error(0x0000, TAG, `Failed to start the encoder video output. code is =${error.code}, message is = ${error.message}`);
        return;
      }
      hilog.info(0x0000, TAG, 'Callback invoked to indicate the encoder video output start success.');
      // [EndExclude camera_conversation]
    });
    // [End camera_conversation]
  }

  /**
   * @throws
   */
  public async releaseCamera(): Promise<void> {
    // Stop the video output stream
    if (this.encoderVideoOutput) {
      this.encoderVideoOutput.stop((error: BusinessError) => {
        if (error) {
          hilog.error(0x0000, TAG, `Failed to stop the encoder video output. code is =${error.code}, message is = ${error.message}`);
          return;
        }
        hilog.info(0x0000, TAG, 'Callback invoked to indicate the encoder video output stop success.');
      });
    }
    try {
      // Stop the Session.
      this.videoSession?.stop();
      // Close camera input stream.
      this.cameraInput?.close();
      // Close file fd.
      fileIo?.close(this.cameraData.outputfd).catch(() => {
        hilog.error(0x0000, TAG, 'Failed close file');
      });
      // Release preview output stream.
      this.XComponentPreviewOutput?.release();
      // Release the video output stream.
      this.encoderVideoOutput?.release();
      hilog.info(0x0000, TAG, 'encoderVideoOutput release');
      // Release session.
      this.videoSession?.release();
    } catch (error) {
      hilog.error(0x0000, TAG,
        `error code is =${error.code}, release camera fail, message is = ${error.message}`);
    }
  }

  public startRecord(): void {
    recorder.startNative()
  }

  public async stopRecord(): Promise<void> {
    recorder.stopNative();
    AppStorage.set('path', this.path);
  }
}