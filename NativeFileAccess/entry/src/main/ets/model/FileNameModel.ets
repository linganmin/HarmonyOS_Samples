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

import { i18n } from '@kit.LocalizationKit';

let systemLanguage: string = i18n.System.getSystemLanguage();
let rawfileName: string = 'TransferResourceMgr_en.txt';
if (systemLanguage === 'zh-Hans') {
  rawfileName = 'TransferResourceMgr_zh.txt';
}

export const FileNameList: Array<string> = [
  'TransferSandboxPath.txt',
  'SplicePath.txt',
  rawfileName,
  'UsePicker.txt'
]