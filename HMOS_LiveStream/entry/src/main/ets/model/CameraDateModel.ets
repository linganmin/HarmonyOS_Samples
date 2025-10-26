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
import { CommonConstants as Const } from '../common/CommonConstants';

export class CameraDataModel {
  public surfaceId: string = '';
  public cameraWidth: number = Const.DEFAULT_WIDTH;
  public cameraHeight: number = Const.DEFAULT_HEIGHT;
  public isHDRVivid: number = Const.DEFAULT_VALUE;
  public outputFd: number = -1;
  public frameRate: number = Const.FRAMERATE_VIDEO_24FPS;
  public previewProfile: camera.Profile = Const.DEFAULT_PROFILE;
  public videoCodecMime: string | null = Const.MIME_VIDEO_HEVC;
  public bitRate: number = Const.BITRATE_VIDEO_3M;
  public isDynamicFpsEnabled: boolean = false;
  public isOpenEchoCancel: number = Const.DEFAULT_VALUE;
  public deviceRotation: number = 0;
  public imageRotation: number = 270;
  public isDisplayLocked: boolean | undefined = false;
  public range: number[] = [0.49, 20];
  public cameraPosition: camera.CameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT;

  setCodecFormat(isHDR: number, codecMime: string): void {
    this.isHDRVivid = isHDR;
    this.videoCodecMime = codecMime;
  }

  setResolution(width: number, height: number, bit: number): void {
    this.cameraWidth = width;
    this.cameraHeight = height;
    this.bitRate = bit;
  }

  reset(){
    this.surfaceId = '';
    this.cameraWidth = Const.DEFAULT_WIDTH;
    this.cameraHeight = Const.DEFAULT_HEIGHT;
    this.isHDRVivid = Const.DEFAULT_VALUE;
    this.outputFd = -1;
    this.frameRate = Const.FRAMERATE_VIDEO_24FPS;
    this.previewProfile = Const.DEFAULT_PROFILE;
    this.videoCodecMime = Const.MIME_VIDEO_HEVC;
    this.bitRate = Const.BITRATE_VIDEO_3M;
    this.isDynamicFpsEnabled = false;
    this.isOpenEchoCancel = Const.DEFAULT_VALUE;
    this.deviceRotation = 0;
    this.imageRotation = 270;
    this.isDisplayLocked = false;
    this.range = [0.49, 20];
    this.cameraPosition = camera.CameraPosition.CAMERA_POSITION_FRONT;
  }
}