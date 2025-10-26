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
import { videoRecording } from './VideoRecorder';
import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';
import { colorSpaceManager } from '@kit.ArkGraphics2D';
import { getGravity } from './GravityUtil';
import { getPreviewSize, getTargetPreviewProfile } from './PreviewUtil';
import { CameraConstants } from '../constants/CameraConstants';

let previewOutput: camera.PreviewOutput;
let cameraInput: camera.CameraInput;
let photoSession: camera.PhotoSession;
let photoOutPut: camera.PhotoOutput;
let currentContext: Context;
let uri: string;

export async function cameraShooting(isVideo: boolean, cameraPosition: number, surfaceId: string,
  context: Context, callback?: (previewSize: Size) => void): Promise<number[]> {
  if (isVideo) {
    return videoRecording(false, cameraPosition, 0, surfaceId, context, callback);
  }
  let zoomRatioRange: number[] = [];
  currentContext = context;
  isVideo = false;
  releaseCamera();
  // [Start camera_manager]
  try {
    let cameraManager: camera.CameraManager = camera.getCameraManager(context);
    // [End camera_manager]

    // Obtaining the Camera List
    // [Start camera_Array]
    let cameraArray: camera.CameraDevice[] = cameraManager.getSupportedCameras();
    // [End camera_Array]
    if (cameraArray.length <= 0) {
      return zoomRatioRange;
    }
    // [Start camera_Input]
    cameraInput = cameraManager.createCameraInput(cameraArray[cameraPosition]);
    await cameraInput.open();
    // [End camera_Input]
    let sceneModes: camera.SceneMode[] = cameraManager.getSupportedSceneModes(cameraArray[cameraPosition]);
    // [Start camera_OutputCap]
    let cameraOutputCap: camera.CameraOutputCapability =
      cameraManager.getSupportedOutputCapability(cameraArray[cameraPosition], camera.SceneMode.NORMAL_PHOTO);
    // [End camera_OutputCap]
    let isSupportPhotoMode: boolean = sceneModes.indexOf(camera.SceneMode.NORMAL_PHOTO) >= 0;
    if (!isSupportPhotoMode) {
      return zoomRatioRange;
    }
    if (!cameraOutputCap) {
      return zoomRatioRange;
    }
    // [Start preview_ProfilesArray]
    let previewProfilesArray: camera.Profile[] = cameraOutputCap.previewProfiles;
    // [End preview_ProfilesArray]
    // [Start photo_Profiles_Array]
    let photoProfilesArray: camera.Profile[] = cameraOutputCap.photoProfiles.slice().reverse();
    // [End photo_Profiles_Array]

    const previewProfile = getTargetPreviewProfile(CameraConstants.PHOTO_RATIO, previewProfilesArray);
    const rPhotoProfilesArray = photoProfilesArray.slice().reverse();
    let photoProfile: camera.Profile | undefined = undefined;
    if (previewProfile !== undefined) {
      photoProfile = rPhotoProfilesArray.find((profile: camera.Profile) => {
        return profile.size.height * previewProfile!.size.width === previewProfile!.size.height * profile.size.width;
      })
    }
    // Set preview window by callback
    callback?.(getPreviewSize(false));
    // [Start preview_ProfilesArray]
    previewOutput = cameraManager.createPreviewOutput(previewProfile, surfaceId);
    // [End preview_ProfilesArray]
    if (previewOutput === undefined) {
      return [];
    }
    // [Start photo_Profiles_Array]
    photoOutPut = cameraManager.createPhotoOutput(photoProfile);
    // [End photo_Profiles_Array]
    if (photoOutPut === undefined) {
      return [];
    }
    // Save Picture
    setPhotoOutputCb(photoOutPut);
    // [Start photo_Session]
    photoSession = cameraManager.createSession(camera.SceneMode.NORMAL_PHOTO) as camera.PhotoSession;
    // [End photo_Session]
    if (photoSession === undefined) {
      return [];
    }
    // [Start photo_Session1]
    photoSession.beginConfig();
    photoSession.addInput(cameraInput);
    photoSession.addOutput(previewOutput);
    photoSession.addOutput(photoOutPut);
    photoSession.setColorSpace(colorSpaceManager.ColorSpace.DISPLAY_P3);
    await photoSession.commitConfig();
    await photoSession.start();
    // [End photo_Session1]

    // Check whether the device supports the flash.
    let flashStatus: boolean = photoSession.hasFlash();
    if (flashStatus) {
      // [Start setFlash_Mode]
      photoSession.setFlashMode(camera.FlashMode.FLASH_MODE_CLOSE);
      // [End setFlash_Mode]
    }
    // Determine whether the continuous automatic zoom mode is supported.
    let focusModeStatus: boolean = photoSession.isFocusModeSupported(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
    if (focusModeStatus) {
      // Set the continuous auto zoom mode
      // [Start setFocus_Mode]
      photoSession.setFocusMode(camera.FocusMode.FOCUS_MODE_CONTINUOUS_AUTO);
      // [End setFocus_Mode]
    }
    // Obtains the variable focal length ratio range supported by the camera.
    zoomRatioRange = photoSession.getZoomRatioRange();
  } catch (error) {
    console.error(`The cameraShooting call failed. error: ${JSON.stringify(error)}`);
  } finally {
    return zoomRatioRange;
  }
}

export function enableLivePic(isMovingPhoto: boolean): void {
  try {
    // [Start is_support1]
    let isSupported: boolean = photoOutPut.isMovingPhotoSupported();
    // [End is_support1]
    // [Start photo_out_put]
    if (isSupported) {
      photoOutPut.enableMovingPhoto(isMovingPhoto);
    }
    // [End photo_out_put]
  } catch (error) {
    console.error(`The enableLivePic call failed. error: ${JSON.stringify(error)}`);
  }
}

export function setPhotoZoom(zoom: number): void {
  try {
    // [Start setZoom_Ratio]
    photoSession.setZoomRatio(zoom);
    // [End setZoom_Ratio]
  } catch (error) {
    console.error(`The enableLivePic call failed. error: ${JSON.stringify(error)}`);
  }
}

export function getPhotoZoom(): number {
  let zoomRatio = 1;
  try {
    zoomRatio = photoSession.getZoomRatio();
  } catch (error) {
    console.error(`The getPhotoZoom call failed. error: ${JSON.stringify(error)}`);
  } finally {
    return zoomRatio;
  }
}

export function setPhotoSmoothZoom(zoom: number): void {
  photoSession.setSmoothZoom(zoom);
}

export async function capture(isFront: boolean) {
  const curRotation = await getGravity();
  try {
    // [Start PhotoCapture_Setting]
    let settings: camera.PhotoCaptureSetting = {
      quality: camera.QualityLevel.QUALITY_LEVEL_HIGH,
      rotation: curRotation ? getPhotoRotation(photoOutPut, curRotation) : camera.ImageRotation.ROTATION_0,
      mirror: isFront
    };
    photoOutPut.capture(settings);
    // [End PhotoCapture_Setting]
  } catch (error) {
    console.error(`The capture call failed. error: ${error.code}`);
  }
}

export async function burstCapture(isFront: boolean, captureCount: number) {
  await capture(isFront);
  let currCount = 1;
  photoOutPut.on('captureReady', async () => {
    await capture(isFront);
    currCount++;
    if (currCount >= captureCount) {
      emitter.emit('burstCaptureOff');
    }
  });
  emitter.once('burstCaptureOff', () => {
    photoOutPut.off('captureReady');
  });
}

export async function setPhotoFlashMode(flashMode: number): Promise<void> {
  try {
    photoSession.setFlashMode(flashMode);
  } catch (error) {
    console.error(`The setPhotoFlashMode call failed. error: ${error.code}`);
  }
}

export async function releaseCamera(): Promise<void> {
  try {
    if (photoSession) {
      photoSession.stop();
    }
    if (cameraInput) {
      cameraInput.close();
    }
    if (previewOutput) {
      previewOutput.release();
    }
    if (photoSession) {
      photoSession.release();
    }
    if (photoOutPut) {
      emitter.off('burstCaptureOff');
      photoOutPut.off('photoAssetAvailable');
      photoOutPut.off('captureReady');
      photoOutPut.release();
    }
  } catch (error) {
    console.error(`The releaseCamera call failed. error: ${error.code}`);
  }
}

// Sets the callback function after capture
// [Start setPhotoOutput_Cb]
function setPhotoOutputCb(photoOutput: camera.PhotoOutput): void {
  photoOutput.on('photoAssetAvailable',
    async (_err: BusinessError, photoAsset: photoAccessHelper.PhotoAsset): Promise<void> => {
      let accessHelper: photoAccessHelper.PhotoAccessHelper =
        photoAccessHelper.getPhotoAccessHelper(currentContext);
      let assetChangeRequest: photoAccessHelper.MediaAssetChangeRequest =
        new photoAccessHelper.MediaAssetChangeRequest(photoAsset);
      try {
        assetChangeRequest.saveCameraPhoto();
        await accessHelper.applyChanges(assetChangeRequest);
        uri = photoAsset.uri;
        AppStorage.setOrCreate('photoUri', await photoAsset.getThumbnail());
      } catch (error) {
        console.error(`The setPhotoOutputCb call failed. error: ${error.code}`);
      }
    });
}

// [End setPhotoOutput_Cb]
/**
 * Jump to the system application gallery
 * @param context
 */
// [Start preview_Photo]
export function previewPhoto(context: Context): void {
  let photoContext = context as common.UIAbilityContext;
  photoContext.startAbility({
    parameters: { uri: uri },
    action: 'ohos.want.action.viewData',
    bundleName: 'com.huawei.hmos.photos',
    abilityName: 'com.huawei.hmos.photos.MainAbility'
  }, (err: BusinessError) => {
    console.error(`The previewPhoto call failed. error: ${err.code}`);
  })
}

// [End preview_Photo]
/**
 * Get cur photo camera.ImageRotation
 * @param photoOutput
 * @param deviceDegree
 * @returns
 */
function getPhotoRotation(photoOutput: camera.PhotoOutput, deviceDegree: number): camera.ImageRotation {
  let photoRotation: camera.ImageRotation = camera.ImageRotation.ROTATION_0;
  try {
    photoRotation = photoOutput.getPhotoRotation(deviceDegree);
  } catch (error) {
    let err = error as BusinessError;
    console.error(`The photoOutput.getPhotoRotation call failed. error code: ${err.code}`);
  }
  return photoRotation;
}