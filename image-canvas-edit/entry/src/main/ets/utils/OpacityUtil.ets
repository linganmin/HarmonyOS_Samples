/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConstants } from '../common/constant/CommonConstants';
import Logger from './LoggerUtil';

const TAG = 'Opacity';

/**
 * Opacity adjust.
 *
 * @param pixelMap.
 * @param value.
 * @return pixelMap.
 */
export async function adjustOpacity(pixelMap: image.PixelMap, value: number) {
  if (!pixelMap) {
    return;
  }
  const newPixelMap = pixelMap;
  await newPixelMap
    .opacity(value / CommonConstants.SLIDER_MAX)
    .then(() => {
      Logger.info(TAG, 'Success in setting opacity.');
    })
    .catch((err: BusinessError) => {
      Logger.error(TAG, `Failed to set opacity: ${JSON.stringify(err.message)}`);
    });

  return newPixelMap;
}
