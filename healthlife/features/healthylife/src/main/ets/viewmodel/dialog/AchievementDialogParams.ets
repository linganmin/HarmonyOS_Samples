/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

/**
 * Achievement completion animation custom dialog parameters.
 */
export class AchievementDialogParams {
  uiContext?: UIContext;
  index: number = 3;
  opacityValue: number = 0;
  angle: number = 0;
  scaleValue: number = 0;

  constructor(uiContext: UIContext, index: number, opacityValue: number, angle: number, scaleValue: number) {
    this.uiContext = uiContext;
    this.index = index;
    this.opacityValue = opacityValue;
    this.angle = angle;
    this.scaleValue = scaleValue;
  }
}



