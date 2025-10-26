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

export class CommonConstants {
  /**
   * Limit picker num
   */
  public static readonly LIMIT_PICKER_NUM = 18;
  /**
   * Camera preview width
   */
  public static readonly PREVIEW_WIDTH: number = 1920;
  /**
   * Camera preview height
   */
  public static readonly PREVIEW_HEIGHT: number = 1080;
  /**
   * Camera photo profile
   */
  public static readonly CAMERA_SIZE: camera.Size[] = [{ width: 1920, height: 1080 }, {
    width: 1440,
    height: 1080
  }];
  /**
   * Grid num two
   */
  public static readonly GRID_NUM_TWO = '1fr 1fr';
  /**
   * Grid num four
   */
  public static readonly GRID_NUM_FOUR = '1fr 1fr 1fr 1fr';
  /**
   * White color
   */
  public static readonly WHITE_COLOR = '#FFFFFF';
  /**
   * Black color
   */
  public static readonly BLACK_COLOR = '#000000';
  /**
   * Gray color
   */
  public static readonly GRAY_COLOR = '#F1F3F5';
  /**
   * Breakpoint sm
   */
  public static readonly BREAKPOINT_SM: string = 'sm';
  /**
   * Breakpoint md
   */
  public static readonly BREAKPOINT_MD: string = 'md';
  /**
   * Breakpoint lg
   */
  public static readonly BREAKPOINT_LG: string = 'lg';
  /**
   * Breakpoint range sm
   */
  public static readonly RANGE_SM: string = '(320vp<=width<600vp)';
  /**
   * Breakpoint range md
   */
  public static readonly RANGE_MD: string = '(600vp<=width<840vp)';
  /**
   * Breakpoint range lg
   */
  public static readonly RANGE_LG: string = '(840vp<=width)';
  /**
   * Breakpoint value sm/md/lg
   */
  public static readonly BREAKPOINT_VALUE: string[] = ['320vp', '600vp', '840vp'];
  /**
   * Window status
   */
  public static readonly WINDOW_STATUS: string = 'status';
  /**
   * Window navigation
   */
  public static readonly WINDOW_NAVIGATION: string = 'navigation';
  /**
   * AppStorage key breakpoint
   */
  public static readonly BREAKPOINT_NAME: string = 'breakpoint';
  /**
   * AppStorage key title
   */
  public static readonly KEY_TITLE: string = 'title';
  /**
   * AppStorage key description
   */
  public static readonly KEY_DESCRIPTION: string = 'description';
  /**
   * AppStorage key cloud image info
   */
  public static readonly KEY_IMAGE_INFO: string = 'imageInfo';
  /**
   * AppStorage key cloud picture path
   */
  public static readonly KEY_RESTORE_IMAGE_INFO: string = 'restoreImageInfo';
  /**
   * AppStorage key moving picture
   */
  public static readonly KEY_MOVING_DATA: string = 'moving_data';
  /**
   * AppStorage key photo asset
   */
  public static readonly KEY_PHOTO_ASSET: string = 'photo_asset'
  /**
   * Params key uri
   */
  public static readonly KEY_PARAMS_URI: string = 'uri';
  /**
   * Params key data
   */
  public static readonly KEY_PARAMS_DATA: string = 'data';
  /**
   * Collaboration insert bufferType
   */
  public static readonly BUFFER_TYPE: string = 'general.image';
  /**
   * AppStorage key page change
   */
  public static readonly KEY_POST_CONTENT: string = 'postContent';
  /**
   * File buffer size
   */
  public static readonly FILE_BUFFER_SIZE: number = 4096;
}