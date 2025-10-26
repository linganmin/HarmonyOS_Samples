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

import downloadAbilityTest from './ability/DownloadTest.test';
import uploadAbilityTest from './ability/UploadTest.test';
import tlsTest from './ability/TLSTest.test';
import downloadApiTimeTest from './apiTime/DownloadApiTimeTest.test';
import uploadApiTimeTest from './apiTime/UploadApiTimeTest.test';

export default function testsuite() {
  downloadAbilityTest();
  uploadAbilityTest();
  tlsTest();
  downloadApiTimeTest();
  uploadApiTimeTest();
}