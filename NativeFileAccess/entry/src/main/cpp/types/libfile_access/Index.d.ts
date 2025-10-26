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
/**
 * 最佳实践：Native侧实现文件访问开发实践
 */
import { resourceManager } from '@kit.LocalizationKit';
// [Start box_path]
export const transferSandboxPath: (path: string, contents: string) => void;
// [End box_path]
// [Start splice1]
export const splicePath: (contents: string) => void;
// [End splice1]
// [Start tran_source_mg]
export const transferResourceMgr: (resMgr: resourceManager.ResourceManager, path: string) => string;
// [End tran_source_mg]
// [Start write_file_pick]
export const writeFileUsingPickerFd: (fd: number, contents: string) => string;
// [End write_file_pick]
// [Start read_fire_fd]
export const readFileUsingPickerFd: (fd: number) => string;
// [End read_fire_fd]