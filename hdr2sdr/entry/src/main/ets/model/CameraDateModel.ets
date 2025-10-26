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
  public isHDRVivid: number = Const.TRUE;
  public outputfd: number = Const.MIN_RANGE;
  public frameRate: number = Const.FRAMERATE_VIDEO_30FPS;
  public previewProfile: camera.Profile = Const.DEFAULT_PROFILE;
  public videoCodecMime: string | null = Const.MIME_VIDEO_HEVC;
  public bitRate: number = Const.BITRATE_VIDEO_10M;
}