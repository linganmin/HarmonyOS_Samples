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

import { trustedAppService } from '@kit.DeviceSecurityKit';

const createProperties: Array<trustedAppService.AttestParam> = [
  {
    tag: trustedAppService.AttestTag.ATTEST_TAG_ALGORITHM,
    value: trustedAppService.AttestKeyAlg.ATTEST_ALG_ECC
  },
  {
    tag: trustedAppService.AttestTag.ATTEST_TAG_KEY_SIZE,
    value: trustedAppService.AttestKeySize.ATTEST_ECC_KEY_SIZE_256
  }
];
const createOptions: trustedAppService.AttestOptions = {
  properties: createProperties
};

export default createOptions;