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

import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { fileIo, fileUri } from '@kit.CoreFileKit';
import DateTimeUtil from './DateTimeUtils';
import { camera } from '@kit.CameraKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { colorSpaceManager } from '@kit.ArkGraphics2D';

const DATETIME: DateTimeUtil = new DateTimeUtil();
const TAG = '[VideoUtils]';

export async function saveFile(context: Context) {
  let helper = photoAccessHelper.getPhotoAccessHelper(context);
  const srcUri: string = fileUri.getUriFromPath(AppStorage.get('path'));
  // Create album resources
  try {
  const asset = await helper.createAsset(photoAccessHelper.PhotoType.VIDEO, 'mp4', {
    title: `Video_${DATETIME.getDate()}_${DATETIME.getTime()}`
  });
  // Write sandbox file to album
    const srcFd = await fileIo.open(srcUri, fileIo.OpenMode.READ_ONLY);
    const destFd = await fileIo.open(asset, fileIo.OpenMode.WRITE_ONLY);
    await fileIo.copyFile(srcFd.fd, destFd.fd);
    // Key: Proactively releasing resources triggers media library refresh
    await fileIo.close(srcFd);
    await fileIo.close(destFd);
  } catch (error) {
    hilog.error(0x0000, TAG, `file open failed.  code is =${error.code}, message is = ${error.message}`);
  }
}

export function setVideoStabilizationMode(session: camera.VideoSession): boolean {
  let mode: camera.VideoStabilizationMode = camera.VideoStabilizationMode.AUTO;
  // Check if video stabilization is supported.
  let isSupported: boolean = isVideoStabilizationModeSupported(session, mode);
  if (isSupported) {
    hilog.info(0x0000, TAG, `setVideoStabilizationMode: ${mode}`);
    // Setting video anti-shake
    try {
      session.setVideoStabilizationMode(mode);
      let activeVideoStabilizationMode = session.getActiveVideoStabilizationMode();
      hilog.info(0x0000, TAG, `activeVideoStabilizationMode: ${activeVideoStabilizationMode}`);
    } catch (error) {
      hilog.error(0x0000, TAG, `setVideoStabilizationMode failed. code is =${error.code}, message is = ${error.message}`);
    }
  } else {
    hilog.info(0x0000, TAG, `videoStabilizationMode: ${mode} is not support`);
  }
  return isSupported;
}

export function isVideoStabilizationModeSupported(session: camera.VideoSession,
  mode: camera.VideoStabilizationMode): boolean {
  let isSupported: boolean = false;
  try {
    isSupported = session.isVideoStabilizationModeSupported(mode);
  } catch (error) {
    // Failed to return error code error. code and handle it.
    hilog.error(0x0000, TAG, `The isVideoStabilizationModeSupported call failed.  code is =${error.code}, message is = ${error.message}`);
  }
  return isSupported;
}

// Set the color space
export function setColorSpaceBeforeCommitConfig(session: camera.VideoSession, isHdr: number): void {
  let colorSpace: colorSpaceManager.ColorSpace =
    isHdr ? colorSpaceManager.ColorSpace.BT2020_HLG_LIMIT : colorSpaceManager.ColorSpace.BT709_LIMIT;
  let colorSpaces: Array<colorSpaceManager.ColorSpace> = getSupportedColorSpaces(session);
  let isSupportedColorSpaces = colorSpaces.indexOf(colorSpace) >= 0;
  if (isSupportedColorSpaces) {
    try {
      session.setColorSpace(colorSpace);
      let activeColorSpace: colorSpaceManager.ColorSpace = session.getActiveColorSpace();
      hilog.info(0x0000, TAG, `activeColorSpace: ${activeColorSpace}`);
    } catch (error) {
      hilog.error(0x0000, TAG, `setColorSpace failed.  code is =${error.code}, message is = ${error.message}`);
    }
  } else {
    hilog.info(0x0000, TAG, `colorSpace: ${colorSpace} is not support`);
  }
}

export function getSupportedColorSpaces(session: camera.VideoSession): Array<colorSpaceManager.ColorSpace> {
  let colorSpaces: Array<colorSpaceManager.ColorSpace> = [];
  try {
    colorSpaces = session.getSupportedColorSpaces();
  } catch (error) {
    hilog.error(0x0000, TAG, `The getSupportedColorSpaces call failed. code is =${error.code}, message is = ${error.message}`);
  }
  return colorSpaces;
}