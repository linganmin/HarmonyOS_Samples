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
import { media } from '@kit.MediaKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { getGravity } from './GravityUtil';
import { getPreviewSize, getTargetPreviewProfile } from './PreviewUtil';
import { CameraConstants } from '../constants/CameraConstants';

// [Start option1]
let file: fileIo.File;
// [End option1]
let previewOutput: camera.PreviewOutput;
let cameraInput: camera.CameraInput;
let avRecorder: media.AVRecorder;
let videoOutput: camera.VideoOutput;
let videoSession: camera.VideoSession;
let uri: string;

export async function videoRecording(isStabilization: boolean, cameraPosition: number, qualityLevel: number,
  surfaceId: string, context: Context, callback?: (previewSize: Size) => void): Promise<number[]> {
  let zoomRatioRange: number[] = [];
  try {
    let cameraManager: camera.CameraManager = camera.getCameraManager(context);
    // [Start camera_array]
    let cameraArray: camera.CameraDevice[] = cameraManager.getSupportedCameras();
    // [End camera_array]
    if (cameraArray.length <= 0) {
      return zoomRatioRange;
    }
    let sceneModes: camera.SceneMode[] = cameraManager.getSupportedSceneModes(cameraArray[0]);
    let isSupportVideoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_VIDEO) >= 0;
    if (!isSupportVideoMode) {
      return zoomRatioRange;
    }
    // [Start out_cap]
    // Obtains the output stream capability supported by the camera.
    let cameraOutputCap: camera.CameraOutputCapability =
      cameraManager.getSupportedOutputCapability(cameraArray[cameraPosition], camera.SceneMode.NORMAL_VIDEO);
    // [End out_cap]
    if (!cameraOutputCap) {
      return zoomRatioRange;
    }
    // [Start pre_pro_file]
    let previewProfilesArray: camera.Profile[] = cameraOutputCap.previewProfiles;
    // [End pre_pro_file]
    if (!previewProfilesArray) {
      return zoomRatioRange;
    }
    // [Start video_profile1]
    let videoProfilesArray: camera.VideoProfile[] = cameraOutputCap.videoProfiles;
    // [End video_profile1]
    if (!videoProfilesArray) {
      return zoomRatioRange;
    }

    let previewProfile = getTargetPreviewProfile(CameraConstants.VIDEO_RATIO, previewProfilesArray);
    // [Start video_profile1]
    let videoProfile: undefined | camera.VideoProfile = videoProfilesArray.find((profile: camera.VideoProfile) => {
      if (previewProfile && cameraPosition === 1) {
        return profile.size.width >= 1080 && profile.size.height >= 1080 &&
          profile.size.height === (previewProfile.size.height / previewProfile.size.width) * profile.size.width &&
          profile.frameRateRange.max === 30;
      }
      if (previewProfile && qualityLevel === 0) {
        return profile.size.width <= 1920 && profile.size.width >= 1080 && profile.size.height >= 1080 &&
          profile.size.height === (previewProfile.size.height / previewProfile.size.width) * profile.size.width &&
          profile.frameRateRange.max === 60;
      }
      if (previewProfile && qualityLevel === 1 && cameraPosition === 0) {
        return profile.size.width <= 4096 && profile.size.width >= 3000 &&
          profile.size.height === (previewProfile.size.height / previewProfile.size.width) * profile.size.width &&
          profile.frameRateRange.max === 60;
      }
      return undefined;
    })
    // [End video_profile1]
    // Set preview window by callback
    callback?.(getPreviewSize(true));
    // Set the parameters based on the actual hardware range.
    let aVRecorderProfile: media.AVRecorderProfile = {
      audioBitrate: 48000,
      audioChannels: 2,
      audioCodec: media.CodecMimeType.AUDIO_AAC,
      audioSampleRate: 48000,
      fileFormat: media.ContainerFormatType.CFT_MPEG_4,
      videoBitrate: 32000000,
      videoCodec: qualityLevel === 1 && cameraPosition === 0 ? media.CodecMimeType.VIDEO_HEVC :
        media.CodecMimeType.VIDEO_AVC,
      videoFrameWidth: videoProfile?.size.width,
      videoFrameHeight: videoProfile?.size.height,
      videoFrameRate: cameraPosition === 0 ? 60 : 30,
    }
    // [Start option1]
    let options: photoAccessHelper.CreateOptions = {
      title: Date.now().toString()
    };
    let accessHelper: photoAccessHelper.PhotoAccessHelper = photoAccessHelper.getPhotoAccessHelper(context);
    let videoUri: string = await accessHelper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', options);
    file = fileIo.openSync(videoUri, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
    let aVRecorderConfig: media.AVRecorderConfig = {
      audioSourceType: media.AudioSourceType.AUDIO_SOURCE_TYPE_MIC,
      videoSourceType: media.VideoSourceType.VIDEO_SOURCE_TYPE_SURFACE_YUV,
      profile: aVRecorderProfile,
      url: `fd://${file.fd.toString()}`,
      rotation: cameraPosition === 0 ? 90 : 270,
      location: { latitude: 30, longitude: 130 }
    };
    // [End option1]
    uri = videoUri;
    avRecorder = await media.createAVRecorder();
    if (avRecorder === undefined) {
      return zoomRatioRange;
    }
    await avRecorder.prepare(aVRecorderConfig);
    let videoSurfaceId: string | undefined = await avRecorder.getInputSurface();
    if (videoSurfaceId === undefined) {
      return zoomRatioRange;
    }
    // [Start video_profile1]
    videoOutput = cameraManager.createVideoOutput(videoProfile, videoSurfaceId);
    // [End video_profile1]
    if (videoOutput === undefined) {
      return zoomRatioRange;
    }
    // [Start video_session1]
    videoSession = cameraManager.createSession(camera.SceneMode.NORMAL_VIDEO) as camera.VideoSession;
    // [End video_session1]
    if (videoSession === undefined) {
      return zoomRatioRange;
    }
    // [Start begin_config]
    videoSession.beginConfig();
    // [End begin_config]
    // [Start open1]
    cameraInput = cameraManager.createCameraInput(cameraArray[cameraPosition]);
    // [StartExclude open1]
    if (cameraInput === undefined) {
      return zoomRatioRange;
    }
    // [EndExclude open1]
    await cameraInput.open();
    // [End open1]
    // [Start begin_config]
    videoSession.addInput(cameraInput);
    // [End begin_config]
    // [Start pre_pro_file]
    // Create previewOutput with target previewProfile from previewProfilesArray
    let previewOutput: camera.PreviewOutput | undefined = cameraManager.createPreviewOutput(previewProfile, surfaceId);
    // [End pre_pro_file]
    if (previewOutput === undefined) {
      return zoomRatioRange;
    }
    // [Start begin_config]
    videoSession.addOutput(previewOutput);
    videoSession.addOutput(videoOutput);
    await videoSession.commitConfig();
    // [StartExclude begin_config]
    if (videoSession.isVideoStabilizationModeSupported(camera.VideoStabilizationMode.MIDDLE)) {
      videoSession.setVideoStabilizationMode(isStabilization ? camera.VideoStabilizationMode.AUTO :
        camera.VideoStabilizationMode.OFF);
    }
    // [EndExclude begin_config]
    await videoSession.start();
    // [End begin_config]

    // Obtains the variable focal length ratio range supported by the camera.
    zoomRatioRange = videoSession.getZoomRatioRange();
  } catch (error) {
    console.error(`The videoRecording call failed. error: ${JSON.stringify(error)}`);
  } finally {
    return zoomRatioRange;
  }
}

export async function stopRecordPreview(): Promise<void> {
  try {
    if (videoSession) {
      videoSession.stop();
    }
    if (cameraInput) {
      cameraInput.close();
    }
    if (previewOutput) {
      previewOutput.release();
    }
    if (videoSession) {
      videoSession.release();
    }
    if (videoOutput) {
      videoOutput.release();
    }
  } catch (error) {
    console.error(`The stopRecordPreview call failed. error: ${JSON.stringify(error)}`);
  }
}

export function setVideoZoom(zoom: number): void {
  try {
    videoSession.setZoomRatio(zoom);
  } catch (error) {
    console.error(`The setVideoZoom call failed. error: ${JSON.stringify(error)}`);
  }
}

export function getVideoZoom(): number {
  let zoomRatio = 1;
  try {
    zoomRatio = videoSession.getZoomRatio();
  } catch (error) {
    console.error(`The getVideoZoom call failed. error: ${JSON.stringify(error)}`);
  } finally {
    return zoomRatio;
  }
}

export function setVideoSmoothZoom(zoom: number): void {
  videoSession.setSmoothZoom(zoom, camera.SmoothZoomMode.NORMAL);
}

export async function startRecord(): Promise<void> {
  // Update the rotation angle before starting recording
  const deviceDegree = await getGravity();
  try {
    await avRecorder.updateRotation(getVideoRotation(videoOutput, deviceDegree));
    await videoOutput.start();
    // [Start recorder1]
    await avRecorder.start();
    // [End recorder1]
  } catch (error) {
    console.error(`The startRecord call failed. error: ${JSON.stringify(error)}`);
  }
}

export async function setVideoFlashMode(flashMode: number): Promise<void> {
  try {
    videoSession.setFlashMode(flashMode);
  } catch (error) {
    console.error(`The setVideoFlashMode call failed. error: ${JSON.stringify(error)}`);
  }
}

export async function stopRecord(): Promise<string> {
  try {
    // [Start recorder2]
    await avRecorder.stop();
    // [End recorder2]
    await avRecorder.release();
    fileIo.closeSync(file);
  } catch (error) {
    console.error(`The stopRecord call failed. error: ${JSON.stringify(error)}`);
  } finally {
    return uri;
  }
}

// [Start pre_video1]
export function previewVideo(context: Context, videoUri: string): void {
  let videoContext = context as common.UIAbilityContext;
  videoContext.startAbility({
    parameters: { uri: videoUri },
    action: 'ohos.want.action.viewData',
    bundleName: 'com.huawei.hmos.photos',
    abilityName: 'com.huawei.hmos.photos.MainAbility'
  }, (err: BusinessError) => {
    console.error(`The previewVideo call failed. error: ${err.code}`);
  })
}

// [End pre_video1]
/**
 * Get cur video camera.ImageRotation
 * @param photoOutput
 * @param deviceDegree
 * @returns
 */
function getVideoRotation(videoOutput: camera.VideoOutput, deviceDegree: number): camera.ImageRotation {
  let videoRotation: camera.ImageRotation = camera.ImageRotation.ROTATION_0;
  try {
    videoRotation = videoOutput.getVideoRotation(deviceDegree);
    console.log(`Video rotation is: ${videoRotation}`);
  } catch (error) {
    let err = error as BusinessError;
    console.error(`The videoOutput.getVideoRotation call failed. error code: ${err.code}`);
  }
  return videoRotation;
}