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

export default class CommonConstants {
  /**
   * intent execute event name
   */
  static readonly PLAY_VIDEO_EVENT: string = 'playVideoEvent';
  /**
   * intent execute event name
   */
  static readonly STORAGE_KEY: string = 'entityId';
  /**
   * video info list file name
   */
  static readonly VIDEO_FILE_NAME: string = 'video.json';
  /**
   * share intent list file name
   */
  static readonly INTENT_FILE_NAME: string = 'shareIntent.json';
  /**
   * share intent list en file name
   */
  static readonly INTENT_ENG_FILE_NAME: string = 'shareIntent_en.json';
  /**
   * navDestination name
   */
  static PLAY_PATH_NAME: string = 'PlayPage';
  /**
   * share status text label
   */
  static SHARE_STATUS_TEXT: string = 'share intent status: ';
  /**
   * Eng language
   */
  static ENG_LANGUAGE: string = 'en-Latn-US';
}

export enum ShareStatus {
  SHARING = 'sharing',
  SUCCEEDED = 'succeeded',
  FAILED = 'failed'
}