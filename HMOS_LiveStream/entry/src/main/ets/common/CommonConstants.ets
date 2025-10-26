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
import { CommentDataModel } from '../pages/WatchLiveStream';

export class CommonConstants {
  /**
   * Index page Tag.
   */
  static readonly INDEX_TAG: string = 'INDEX';
  /**
   * Recorder page Tag.
   */
  static readonly RECORDER_TAG: string = 'RECORDER';
  /**
   * Default ID.
   */
  static readonly DEFAULT_ID: string = '-1';
  /**
   * Default time.
   */
  static readonly DEFAULT_TIME: string = '00:00';
  /**
   * PX.
   */
  static readonly PX: string = 'px';
  /**
   * Default value.
   */
  static readonly DEFAULT_VALUE: number = 0;
  /**
   * Default profile.
   */
  static readonly DEFAULT_PROFILE: camera.Profile = {
    format: camera.CameraFormat.CAMERA_FORMAT_YUV_420_SP,
    size: {
      width: 1920,
      height: 1080
    }
  };
  /**
   * Video avc mime type.
   */
  static readonly MIME_VIDEO_AVC: string = 'video/avc';
  /**
   * Video hevc mime type.
   */
  static readonly MIME_VIDEO_HEVC: string = 'video/hevc';
  /**
   * Default width.
   */
  static readonly DEFAULT_WIDTH: number = 1920;
  /**
   * Default height.
   */
  static readonly DEFAULT_HEIGHT: number = 1080;
  /**
   * 4K video width.
   */
  static readonly VIDEO_WIDTH_4K: number = 3840;
  /**
   * 4K video height.
   */
  static readonly VIDEO_HEIGHT_4K: number = 2160;
  /**
   * 1080P video width.
   */
  static readonly VIDEO_WIDTH_1080P: number = 1920;
  /**
   * 1080P video height.
   */
  static readonly VIDEO_HEIGHT_1080P: number = 1080;
  /**
   * 720P video width.
   */
  static readonly VIDEO_WIDTH_720P: number = 1280;
  /**
   * 720P video height.
   */
  static readonly VIDEO_HEIGHT_720P: number = 720;
  /**
   * 3M bitrate.
   */
  static readonly BITRATE_VIDEO_3M: number = 3 * 1024 * 1024;
  /**
   * 10M bitrate.
   */
  static readonly BITRATE_VIDEO_10M: number = 1.6 * 1024 * 1024;
  /**
   * 20M bitrate.
   */
  static readonly BITRATE_VIDEO_20M: number = 20 * 1024 * 1024;
  /**
   * 30M bitrate.
   */
  static readonly BITRATE_VIDEO_30M: number = 30 * 1024 * 1024;
  /**
   * 24 FPS.
   */
  static readonly FRAMERATE_VIDEO_24FPS: number = 24;
  /**
   * 30 FPS.
   */
  static readonly FRAMERATE_VIDEO_30FPS: number = 30;
  /**
   * 60 FPS.
   */
  static readonly FRAMERATE_VIDEO_60FPS: number = 60;
  /**
   * Duration.
   */
  static readonly DURATION: number = 2000;
  /**
   * The distance between toast dialog box and the bottom of screen.
   */
  static readonly BOTTOM: number = 80;
  /**
   * Default picker item height.
   */
  static readonly DEFAULT_PICKER_ITEM_HEIGHT: number = 30;
  /**
   * Selected text style font size.
   */
  static readonly SELECTED_TEXT_STYLE_FONT_SIZE: number = 15;
  /**
   * Video mime type.
   */
  static readonly VIDEO_MIMETYPE: string[] = ['HDRVivid', 'SDR'];
  /**
   * Video resolution.
   */
  static readonly VIDEO_RESOLUTION: string[] = ['4K', '1080P'];
  /**
   * Video framerate.
   */
  static readonly VIDEO_FRAMERATE: string[] = ['30Fps', '60Fps'];
  static readonly DYNAMIC_FRAME_SWITCH: string[] = ['动态帧率', '固定帧率'];
  /**
   * Video recorderInfo.
   */
  static readonly RECORDER_INFO: string[][] = [
    CommonConstants.VIDEO_MIMETYPE, CommonConstants.DYNAMIC_FRAME_SWITCH
  ];
  /**
   * The number corresponding to true.
   */
  static readonly TRUE: number = 1;
  /**
   * The number corresponding to false.
   */
  static readonly FALSE: number = 0;
  /**
   * Min range.
   */
  static readonly MIN_RANGE: number = 1;
  /**
   * Max range.
   */
  static readonly MAX_RANGE: number = 30;
  /**
   * Full size.
   */
  static readonly FULL_SIZE: string = '100%';
  /**
   * ROI id
   */
  static readonly ROI_ID: string = 'roi_id';
  /**
   * BGM id
   */
  static readonly BGM_ID: string = 'bgm_id';
  /**
   * Global Var PREFIX
   */
  static readonly GLOBAL_PREFIX: string = 'HMOS_LiveStream';
  /**
   * BGM file
   */
  static readonly BGM_FILENAME: string = 'Delacey_DreamItPossible.mp3';
}


export const COMMENT_LIST: Array<CommentDataModel> = [
  {
    name: $r('app.string.first_one_name'),
    comment: $r('app.string.first_one_comment')
  },
  {
    name: $r('app.string.first_two_name'),
    comment: $r('app.string.first_two_comment')
  },
  {
    name: $r('app.string.first_three_name'),
    comment: $r('app.string.first_three_comment')
  },
  {
    name: $r('app.string.first_four_name'),
    comment: $r('app.string.first_four_comment')
  },
  {
    name: $r('app.string.first_five_name'),
    comment: $r('app.string.first_five_comment')
  },
  {
    name: $r('app.string.first_one_name'),
    comment: $r('app.string.first_five_comment')
  },
  {
    name: $r('app.string.first_two_name'),
    comment: $r('app.string.first_one_comment')
  },
  {
    name: $r('app.string.first_three_name'),
    comment: $r('app.string.first_two_comment')
  },
  {
    name: $r('app.string.first_four_name'),
    comment: $r('app.string.first_three_comment')
  },
  {
    name: $r('app.string.first_five_name'),
    comment: $r('app.string.first_four_comment')
  }
]