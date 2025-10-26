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

export class FileItem {
  constructor(fileKey: number, fileName: string, urlOrPath: string, concurrency?: number) {
    this.fileKey = fileKey;
    this.fileName = fileName;
    this.urlOrPath = urlOrPath;
    if (concurrency) {
      this.concurrency = concurrency;
    }
  }

  public fileKey: number = 0;
  public fileName: string = '';
  public urlOrPath: string = '';
  public concurrency: number = 1;
}