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

/**
 * Model input height and width constants
 */
export const MODEL_INPUT_HEIGHT = 1024;
export const MODEL_INPUT_WIDTH = 1024;
export const BLACKGROUND_THEADHOLD = 0.88;
export const MODEL_NAME = 'rmbg_fp16.ms';

/**
 * List data constants for all features
 */
export class ListDataConstants {
  /**
   * Service directory list
   */
  static readonly IMG_LIST: Resource[] = [
    $r('app.media.img_001'),
    $r('app.media.img_002'),
    $r('app.media.img_003'),
    $r('app.media.img_004'),
    $r('app.media.img_005'),
    $r('app.media.img_006'),
    $r('app.media.img_007'),
    $r('app.media.img_008'),
    $r('app.media.img_009'),
  ]
}
