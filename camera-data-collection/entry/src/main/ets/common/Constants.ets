/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export class Constants {
  // aspect ratio: width/height
  static readonly MIN_ASPECT_RATIO = 4 / 3; // 4:MIN_ASPECT_RATIO, 3:MIN_ASPECT_RATIO

  // device type
  static readonly TABLET = 'tablet';
  static readonly DEFAULT = 'default';
  static readonly PHONE = 'phone';

  /**
   * The full percentage of component.
   */
  static readonly FULL_PERCENT: string = '100%';

  /**
   * The seventy percent of the components.
   */
  static readonly SEVENTY_PERCENT: string = '70%';

  /**
   * The fifteen percent of the bottom of the margin.
   */
  static readonly FIFTEEN_PERCENT: string = '15%';

  /**
   * X-axis offset position.
   */
  static readonly PHOTO_X_POSITION: string = '39%';

  /**
   * X-axis offset position.
   */
  static readonly VIDEO_X_POSITION: string = '53%';

  /**
   * Y-axis offset position.
   */
  static readonly Y_POSITION: string = '77%';

  /**
   * Album X-axis offset position.
   */
  static readonly ALBUM_X_POSITION: string = '10%';

  /**
   * Album, photo, video, and camera switch icons Y-axis offset position.
   */
  static readonly ICON_Y_POSITION: string = '85%';

  /**
   * Capture video icon X-axis offset position.
   */
  static readonly CAPTURE_X_POSITION: string = '42%';

  /**
   * Front and rear camera switching X-axis offset position.
   */
  static readonly SWITCH_X_POSITION: string = '73%';

  /**
   * Shooting mode.
   */
  static readonly PHOTO: string = 'photo';

  /**
   * Recording Mode.
   */
  static readonly VIDEO: string = 'video';

  /**
   * Album, photo, video, and camera switch icons size.
   */
  static readonly ICON_SIZE: number = 200;

  /**
   * Event offsetY.
   */
  static readonly EVENT_Y_OFFSET: number = 200;

  /**
   * Event offsetY.
   */
  static readonly EVENT_Y_OFFSET1: number = -200;

  /**
   * FontWeight 400.
   */
  static readonly FONT_WEIGHT_400: number = 400;

  /**
   * Position ± 25.
   */
  static readonly POSITION_25: number = 25;

  /**
   * Position ± 58.
   */
  static readonly POSITION_58: number = 58;

  /**
   * Position ± 30.
   */
  static readonly POSITION_30: number = 30;

  /**
   * Position ± 95.
   */
  static readonly POSITION_95: number = 95;

  /**
   * Position ± 73.
   */
  static readonly POSITION_73: number = 73;

  /**
   * Position ± 40.
   */
  static readonly POSITION_40: number = 40;

  /**
   * Position ± 10.
   */
  static readonly POSITION_10: number = 10;

  /**
   * Audio bit rate and sample rate.
   */
  static readonly AUDIO_BITRATE_SAMPLE_RATE: number = 48000;

  /**
   * Number of audio collection channels.
   */
  static readonly AUDIO_CHANNELS: number = 2;

  /**
   * Video bit rate.
   */
  static readonly VIDEO_BITRATE: number = 512000;

  /**
   * Width of the video frame.
   */
  static readonly VIDEO_FRAME_WIDTH: number = 640;

  /**
   * Height of the video frame.
   */
  static readonly VIDEO_FRAME_HEIGHT: number = 480;

  /**
   *Video frame rate.
   */
  static readonly VIDEO_FRAME_RATE: number = 30;

  /**
   *Geographical longitude.
   */
  static readonly LONGITUDE: number = 77.7500;

  /**
   *Geographical latitude.
   */
  static readonly LATITUDE: number = 12.9698;

  /**
   *Geographical altitude.
   */
  static readonly ALTITUDE: number = 1000;
};

export class SettingDataObj {
  mirrorBol = false; // Mirror Enable -> Off
  videoStabilizationMode = 0; // Video Anti Shake -> Off
  exposureMode = 1; // Exposure mode -> Automatic
  focusMode = 2; // 2:Focus mode -> Automatic
  photoQuality = 1; // Photo quality -> medium
  locationBol = false; // Show Geographic Location -> Off
  photoFormat = 1; // Photo Format -> JPG
  photoOrientation = 0; // Photo direction -> 0
  photoResolution = 0; // Photo resolution -> 1920 * 1080
  videoResolution = 0; // Photo resolution -> 1920 * 1080
  videoFrame = 0; // Recording frame rate -> 15
  referenceLineBol = false; // Divider -> Off
};