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

// [Start declare_interface]
import resourceManager from '@kit.LocalizationKit';
export const getFileList: (resmgr: resourceManager.resourceManager.ResourceManager, path: string) => Array<String>;
export const getRawFileContent: (resmgr: resourceManager.resourceManager.ResourceManager, path: string) => Uint8Array;
export const getRawFileDescriptor: (resmgr: resourceManager.resourceManager.ResourceManager, path: string) => resourceManager.resourceManager.RawFileDescriptor;
export const isRawDir: (resmgr: resourceManager.resourceManager.ResourceManager, path: string) => boolean;
// [End declare_interface]