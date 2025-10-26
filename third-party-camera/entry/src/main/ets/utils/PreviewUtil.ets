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

import { display, window } from '@kit.ArkUI';
import { camera } from '@kit.CameraKit';
import { CameraConstants } from '../constants/CameraConstants';

/**
 * Get camera preview size
 * @param isVideo
 * @returns previewSize in Size
 */
export function getPreviewSize(isVideo: boolean) {
  // Use display size to determine preview ratio in current direction
  const displaySize = getCurrentDisplaySize();
  const isWidthLonger = displaySize.width > displaySize.height;

  // Get screen ratio and target ratio, use them to determine preview size
  const windowSize = getCurrentWindowSize();
  const screenRatio =
    isWidthLonger ? (windowSize.width / windowSize.height) : (windowSize.height / windowSize.width);
  const targetRatio = isVideo ? CameraConstants.VIDEO_RATIO : CameraConstants.PHOTO_RATIO;

  let previewSize: Size = { width: 0, height: 0 };
  if (targetRatio >= screenRatio) {
    previewSize.width = isWidthLonger ? windowSize.width : windowSize.height / targetRatio;
    previewSize.height = isWidthLonger ? windowSize.width / targetRatio : windowSize.height;
  } else {
    previewSize.width = isWidthLonger ? windowSize.height * targetRatio : windowSize.width;
    previewSize.height = isWidthLonger ? windowSize.height : windowSize.width * targetRatio;
  }

  return previewSize;
}

/**
 * Get camera preview profile
 * @param targetRatio - preview ratio, the default image ratio is 4 / 3 and the default video ratio is 16 / 9
 * @param previewProfilesArray - available preview profiles provided by camera
 * @returns - target preview profile
 */
export function getTargetPreviewProfile(targetRatio: number, previewProfilesArray: camera.Profile[]) {
  // The width of preview profile is always equal or larger than height, use window size to determine preview profile
  const windowSize = getCurrentWindowSize();
  const isWidthLonger = windowSize.width > windowSize.height;
  const screenRatio =
    isWidthLonger ? (windowSize.width / windowSize.height) : (windowSize.height / windowSize.width);
  let lowLength = isWidthLonger ? windowSize.height : windowSize.width;
  let maxDiff = Number.MAX_VALUE;

  let previewProfile: camera.Profile | undefined = undefined;
  for (let i = 0; i < previewProfilesArray.length; i++) {
    const profileRatio = previewProfilesArray[i].size.width / previewProfilesArray[i].size.height;
    // Find preview profile with target ratio
    if (profileRatio !== targetRatio) {
      continue;
    }

    // Find profile size closest to window size
    if (screenRatio >= profileRatio) {
      const currDiff = Math.abs(previewProfilesArray[i].size.height - lowLength);
      if (currDiff < maxDiff) {
        previewProfile = previewProfilesArray[i];
        maxDiff = currDiff;
      }
    } else {
      const currDiff = Math.abs(previewProfilesArray[i].size.width - lowLength * screenRatio);
      if (currDiff < maxDiff) {
        previewProfile = previewProfilesArray[i];
        maxDiff = currDiff;
      }
    }
  }

  return previewProfile;
}

/**
 * Get current window size
 * @returns window size if window exist, otherwise zero
 */
export function getCurrentWindowSize() {
  const windowClass = AppStorage.get<window.Window>('window');
  let size: Size = { width: 0, height: 0 };
  try {
    const windowSize = windowClass?.getWindowProperties().windowRect;
    size = { width: windowSize?.width ?? 0, height: windowSize?.height ?? 0 }
  } catch (error) {
    console.error(`The getCurrentWindowSize call failed. error: ${JSON.stringify(error)}`);
  }
  return size;
}

/**
 * Get current display size
 * @returns screen display size
 */
export function getCurrentDisplaySize() {
  let size: Size = { width: 0, height: 0 };
  try {
    const displaySize = display.getDefaultDisplaySync();
    size = { width: displaySize.width, height: displaySize.height };
  } catch (error) {
    console.error(`The getCurrentDisplaySize call failed. error: ${JSON.stringify(error)}`);
  } finally {
    return size;
  }
}