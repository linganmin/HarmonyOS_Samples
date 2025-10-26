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
  static readonly NODE_CONTAINER_ID: string = 'root';
  static readonly FULL_SCREEN: string = '100%';
  static readonly THIRTY_PERCENT: string = '30%';
  static readonly FOLD_CONDITION: string = '(600<=width<=800vp)';
  static readonly FOLD_DRAW_AREA_HEIGHT: string = 'calc(50% - 30vp)';
  static readonly ROW_SPACE: number = 12;
  static readonly BORDER_RADIUS: number = 1000;
  static readonly TOAST_DURATION: number = 2000;
  static readonly IMAGE_QUALITY: number = 100;
}