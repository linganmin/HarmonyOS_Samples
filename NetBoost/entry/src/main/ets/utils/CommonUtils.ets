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

import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { uri } from '@kit.ArkTS';

const DOMAIN = 0x0000;
const TAG = 'CommonUtils';

/**
 * Show a toast info.
 * @param message The message to show.
 */
export function showToast(message: string | Resource) {
  (AppStorage.get('uiContext') as UIContext)?.getPromptAction().openToast({
    message: message
  }).catch((err: BusinessError) => {
    hilog.error(DOMAIN, TAG, `openToast error:${err.code},${err.message}`);
  })
}

/**
 * Get host from the url.
 * @param urlString Target url.
 * @returns The host in the url.
 */
export function getDomainFromUrl(urlString: string): string {
  const uriObj = new uri.URI(urlString);
  return uriObj.host;
}