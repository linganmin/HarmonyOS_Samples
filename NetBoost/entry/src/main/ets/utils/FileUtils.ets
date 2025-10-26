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

import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommonConst } from '../common/CommonConst';

const DOMAIN = 0x0000;
const TAG = 'FileUtils';

// [Start file_up_chunk]
/**
 * File upload chunk info.
 * */
export class FileUpChunk {
  chunkNumber: number = 1;
  startPosition: number = 0;
  chunkSize: number = 0;
  buffer: ArrayBuffer = new ArrayBuffer(0);
  retryTimes: number = 0;
}
// [End file_up_chunk]

/**
 * A class containing download chunk info.
 * */
export class FileDownChunk {
  // randomFileFd,used to write file data
  fileFd: number = -1;
  startPosition: number = 0;
  endPosition: number = 0;
  retryTimes: number = 0;
}


/**
 * Delete the file.
 * @param fileAbsPath The file path which will be delete.
 */
export function deleteFile(fileAbsPath: string) {
  try {
    if (fileIo.accessSync(fileAbsPath)) {
      fileIo.unlinkSync(fileAbsPath);
    }
  } catch (err) {
    const error: BusinessError = err as BusinessError;
    hilog.error(DOMAIN, TAG, `Delete file failed:${error.code},${error.name}`);
  }
}

/**
 * Return the formatted size based on the magnitude.
 * @param bytes Size in bytes.
 * @returns Formatted size.
 */
export function formatFileSize(bytes: number): string {
  if (bytes < 0) {
    return '0 bytes';
  }
  if (bytes < 1024) {
    return `${bytes} Bytes`;
  }
  const units = ['KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'];
  let unitIndex = -1;
  let size = bytes;

  do {
    size /= 1024;
    unitIndex++;
  } while (size >= 1024 && unitIndex < units.length - 1);

  const formattedSize = (Math.round(size * 10) / 10).toFixed(1);
  return `${formattedSize}${units[unitIndex]}`;
}

/**
 * Retrieve the buffer data from the specified start to end position in the file.
 * @param file The file to read.
 * @param fileChunkNoData  An interface for a range object with start and end properties.
 * @returns An interface for a range object with start、end、buffer data etc properties.
 */
export function readFileChunkBuffer(file: fileIo.File, fileChunkNoData: FileUpChunk): FileUpChunk | undefined {
  try {
    const fileStat = fileIo.statSync(file.fd);
    const fileSize = fileStat.size;

    if (fileSize <= fileChunkNoData.startPosition) {
      hilog.error(DOMAIN, TAG, `[readFileChunkBuffer] error:fileSize <= startPosition`);
      return;
    }
    if (fileSize < fileChunkNoData.startPosition + fileChunkNoData.chunkSize) {
      hilog.error(DOMAIN, TAG, `[readFileChunkBuffer] error:fileSize < startPosition + chunkSize`);
      return;
    }

    const fileChunk: FileUpChunk = new FileUpChunk();
    fileChunk.chunkNumber = fileChunkNoData.chunkNumber;
    fileChunk.startPosition = fileChunkNoData.startPosition;
    fileChunk.chunkSize = Math.min(fileChunkNoData.chunkSize, fileSize - fileChunkNoData.startPosition);

    let buffer = new ArrayBuffer(fileChunk.chunkSize);
    fileIo.readSync(file.fd, buffer);
    fileChunk.buffer = buffer;
    hilog.info(DOMAIN, TAG, `[readFileChunkBuffer] success`);
    return fileChunk;
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    hilog.error(DOMAIN, TAG, `[readFileChunkBuffer] errror:${err.code},${err.name}`);
    return undefined;
  }
}


/**
 * Writes ArrayBuffer data to a file.
 * @param fileFd A file to write.
 * @param startPosition Start position to write.
 * @param buffer ArrayBuffer data to write.
 * @returns Return true if write success,otherwise return false
 */
export function writeFileBuffer(fileFd: number, startPosition: number, buffer: ArrayBuffer | null): boolean {
  if (!buffer || fileFd < 0) {
    hilog.error(DOMAIN, TAG, `[writeFileBuffer] errror:File is not enable`);
    return false;
  }
  try {
    fileIo.writeSync(fileFd, buffer, {
      offset: startPosition
    })
    return true;
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    hilog.error(DOMAIN, TAG, `[writeFileBuffer] errror:${err.code},${err.name}`);
    return false;
  }
}

// [Start split_file]
/**
 * Splits the file into segments.
 * @param file An opened file
 * @returns Returns all segments of the file.
 */
export function splitFile(file: fileIo.File): FileUpChunk[] {
  try {
    const fileStat = fileIo.statSync(file.fd);
    const fileSize = fileStat.size;
    const chunks: FileUpChunk[] = [];
    let chunkNumber = 1;
    const splitChunkSize = Math.floor(fileStat.size / getChunkSize(fileSize));
    for (let start = 0; start < fileSize; start += splitChunkSize) {
      const chunkSize = Math.min(splitChunkSize, fileSize - start);
      const chunk = new FileUpChunk();
      chunk.chunkNumber = chunkNumber++;
      chunk.startPosition = start;
      chunk.chunkSize = chunkSize;
      chunks.push(chunk);
    }
    hilog.info(DOMAIN, TAG, `[splitFile] success`);
    return chunks;
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    hilog.error(DOMAIN, TAG, `[splitFile] errror:${err.code},${err.name}`);
    return [];
  }
}
// [End split_file]

// [Start get_chunk_size]
function getChunkSize(fileSize: number): number {
  const MB = CommonConst.MIN_SLICE_FILE_SIZE;
  const fullMBs = Math.floor(fileSize / MB);
  let res = Math.max(1, Math.min(CommonConst.MAX_SLICE_FILE_COUNT, fullMBs));
  hilog.info(DOMAIN, TAG, `[getChunkSize] FileSize:${fileSize},ChunkSize:${res}`);
  return res;
}
// [End get_chunk_size]