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

export class FileItem {
  private fileName: string;
  private fileType: string;
  private fileSize: number;
  private fileContent: string;
  private filePath: string;

  constructor(fileName: string, fileType: string, fileSize: number, fileContent: string, filePath: string) {
    this.fileName = fileName;
    this.fileType = fileType;
    this.fileSize = fileSize;
    this.fileContent = fileContent;
    this.filePath = filePath;
  }

  getFileName(): string {
    return this.fileName;
  }

  getFileType(): string {
    return this.fileType;
  }

  getFileSize(): number {
    return this.fileSize;
  }

  getFileContent(): string {
    return this.fileContent;
  }

  getFilePath(): string {
    return this.filePath;
  }
}