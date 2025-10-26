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

import Logger from './Logger';
import { JSON } from '@kit.ArkTS';

/**
 * Display custom toast
 * @param message
 * @param duration
 */
export function customToast(message: string | Resource, duration: number) {
  const uiContext = AppStorage.get<UIContext>('uiContext');
  if (!uiContext) {
    Logger.error('Invalid uiContext');
    return;
  }
  try {
    uiContext.getPromptAction().showToast({
      message: message,
      duration: duration
    });
  } catch (error) {
    Logger.error(`showToast error: ${JSON.stringify(error)}`);
  }
}