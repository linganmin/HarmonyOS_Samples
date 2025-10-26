/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { wrappedBuilderShowCursor } from '../pages/TextBoxShowCursor';
import { wrappedBuilderBottomWithBar } from '../pages/BottomWithBar';
import { wrappedBuilderColorChange } from '../pages/BackgroundColorChange';
import { wrappedBuilderVerificationCode } from '../pages/SelectVerificationCode';
import { wrappedBuilderSliderVerification } from '../pages/SliderVerificationCode';

export class GlobalBuilderContext {
  private static instance: GlobalBuilderContext;
  private _objects = new Map<string, Object>();

  public static getContext(): GlobalBuilderContext {
    if (!GlobalBuilderContext.instance) {
      GlobalBuilderContext.instance = new GlobalBuilderContext();
      GlobalBuilderContext.instance.setObject('TextBoxShowCursor', wrappedBuilderShowCursor);
      GlobalBuilderContext.instance.setObject('BottomWithBar', wrappedBuilderBottomWithBar);
      GlobalBuilderContext.instance.setObject('BackgroundColorChange', wrappedBuilderColorChange);
      GlobalBuilderContext.instance.setObject('VerificationCode', wrappedBuilderVerificationCode);
      GlobalBuilderContext.instance.setObject('SliderVerification', wrappedBuilderSliderVerification);
    }
    return GlobalBuilderContext.instance;
  }

  getObject(value: string): Object | undefined {
    return this._objects.get(value);
  }

  setObject(key: string, objectClass: Object): void {
    this._objects.set(key, objectClass);
  }
}