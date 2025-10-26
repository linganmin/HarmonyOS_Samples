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
import { connection, http, socket } from '@kit.NetworkKit';
import { buffer, taskpool } from '@kit.ArkTS';
import { CommonConst } from '../../common/CommonConst';
import { bindSpecifiedNet } from '../../net/NetBoostManager';
import { XmlUtils } from '../../utils/XmlUtils';
import { extractHttpBody } from '../../utils/HttpParser';
import { getDataBySocket } from '../../net/SocketClient';
import { FileUpChunk, readFileChunkBuffer, splitFile } from '../../utils/FileUtils';

const DOMAIN = 0x0000;
const TAG = 'FilePartsUploadManager';

// [Start init_multi_part_upload]
/**
 * Initializes the upload.
 * @param host Server host.
 * @param port Server port.
 * @param uploadFileName File save path.
 * @returns Returns a 'InitiateMultipartUpload' object if success,otherwise returns undefined.
 */
@Concurrent
async function initMultiPartUpload(host: string, port: number,
  uploadFileName: string): Promise<InitiateMultipartUpload | undefined> {
  const objectKey: string = uploadFileName;
  const path = `/${objectKey}?uploads`;
  const method = http.RequestMethod.POST;
  const date = new Date().toUTCString();

  // build request headers
  const headers = [
    `Host: ${host}`,
    `Date: ${date}`,
    `Content-Length: 0`,
    `Content-Type: application/xml`,
    `Connection: close`
  ];

  // build request info
  const request = `${method} ${path} HTTP/1.1\r\n` + headers.join('\r\n') + CommonConst.HEADER_BODY_DELIMITER;
  // request data by socket
  const value: socket.SocketMessageInfo | undefined = await getDataBySocket(host, port, request);
  // parse result
  if (value) {
    try {
      let responseStr = buffer.from(value.message).toString('utf-8');
      const uploadIdMatch = responseStr.match(/<UploadId>(.*?)<\/UploadId>/);
      if (uploadIdMatch && uploadIdMatch[1]) {
        // start build 'InitiateMultipartUpload' object
        let result = XmlUtils.xmlToObj(extractHttpBody(responseStr), true);
        if (result && result['initiateMultipartUploadResult']) {
          const json: object = result['initiateMultipartUploadResult'];
          if (json) {
            return {
              bucket: json['bucket'],
              key: json['key'],
              uploadId: json['uploadId']
            } as InitiateMultipartUpload;
          }
          return undefined;
        } else {
          hilog.error(0x0000, 'FilePartsUploadManager',
            `[initiateMultipartUploadResult.onResult]: parse xml info error`);
          return undefined;
        }
      } else {
        hilog.error(0x0000, 'FilePartsUploadManager', `[initMultiPartUpload] onMessage ignore`);
        return undefined;
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'FilePartsUploadManager', `[uploadPart] buffer.from error:${err.code},${err.name}`);
      return undefined;
    }
  } else {
    return undefined;
  }
}
// [End init_multi_part_upload]

// [Start upload_segment]
/**
 * Upload file segment.
 * @param host Server host.
 * @param port Server port.
 * @param initResult An 'InitiateMultipartUpload' object.
 * @param fileChunk File info to uploaded.
 * @param netId The ID of the netHandle to bind.
 * @returns Returns a 'UploadPartResult' object if success,otherwise returns undefined
 */
@Concurrent
async function uploadSegment(host: string, port: number, initResult: InitiateMultipartUpload, fileChunk: FileUpChunk,
  netId: number): Promise<UploadPartResult | undefined> {
  const socketInstance: socket.TCPSocket = socket.constructTCPSocketInstance();
  await bindSpecifiedNet(socketInstance, netId, CommonConst.SOCKET_BIND_UP_PORT);

  const path = `/${initResult.key}?partNumber=${fileChunk.chunkNumber}&uploadId=${initResult.uploadId}`;
  const method = http.RequestMethod.PUT;
  const date = new Date().toUTCString();
  // build request header
  const headers = [
    `Host: ${host}`,
    `Date: ${date}`,
    `Content-Length: ${fileChunk.chunkSize}`,
    `Content-Type: application/octet-stream`,
    `Connection: close`
  ];

  const requestHeader = `${method} ${path} HTTP/1.1\r\n` + headers.join('\r\n') + CommonConst.HEADER_BODY_DELIMITER;
  const headerBuffer = buffer.from(requestHeader, 'utf-8').buffer;

  // build request header and body
  const requestBuffer = new Uint8Array(headerBuffer.byteLength + fileChunk.buffer.byteLength);
  requestBuffer.set(new Uint8Array(headerBuffer), 0);
  requestBuffer.set(new Uint8Array(fileChunk.buffer), headerBuffer.byteLength);
  // get value from socket
  const value: socket.SocketMessageInfo | undefined =
    await getDataBySocket(host, port, requestBuffer.buffer, socketInstance);

  // parse value
  if (value) {
    try {
      let responseStr = buffer.from(value.message).toString('utf-8');
      // Get ETag
      const eTagMatch = responseStr.match(/ETag: "([^"]+)"/);
      if (eTagMatch && eTagMatch[1]) {
        return ({
          partNumber: fileChunk.chunkNumber,
          eTag: eTagMatch[1]
        } as UploadPartResult);
      } else {
        hilog.error(0x0000, 'FilePartsUploadManager',
          `[uploadPart] onMessage--> fileChunkId:${fileChunk.chunkNumber} upload Faild`);
        return undefined;
      }
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'FilePartsUploadManager',
        `[uploadPart] buffer.from error:${err.code},${err.name},fileChunkId:${fileChunk.chunkNumber}`);
      return undefined;
    }
  } else {
    return undefined;
  }
}
// [End upload_segment]

/**
 * Notifies the server to merge the files.
 * @param host Server host.
 * @param port Server port.
 * @param initResult An 'InitiateMultipartUpload' object.
 * @param parts All file uploaded results.
 * @returns Returns true if success,otherwise returns false.
 */
@Concurrent
async function completeMultiPartUploadRequest(host: string, port: number, initResult: InitiateMultipartUpload,
  parts: UploadPartResult[]): Promise<boolean> {
  const path = `/${initResult.key}?uploadId=${initResult.uploadId}`;
  const method = 'POST';
  const date = new Date().toUTCString();
  // build xml parts info
  const partsXml = parts.map(part =>
  `<Part><PartNumber>${part.partNumber}</PartNumber><ETag>${part.eTag}</ETag></Part>`
  ).join('');
  const requestBody = `<CompleteMultipartUpload>${partsXml}</CompleteMultipartUpload>`;

  // build headers
  const headers = [
    `Host: ${host}`,
    `Date: ${date}`,
    `Content-Length: ${requestBody.length}`,
    `Content-Type: application/xml`,
    `Connection: close`
  ];

  // build request data
  const request = `${method} ${path} HTTP/1.1\r\n` +
  headers.join('\r\n') + CommonConst.HEADER_BODY_DELIMITER + requestBody;

  const value: socket.SocketMessageInfo | undefined = await getDataBySocket(host, port, request);
  // parse value result
  if (value) {
    try {
      let responseStr = buffer.from(value.message).toString('utf-8');
      return responseStr.includes('HTTP/1.1 200 OK');
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(0x0000, 'FilePartsUploadManager',
        `[completeMultiPartUpload] buffer.from error:${err.code},${err.name}`);
      return false;
    }
  } else {
    return false;
  }
}

interface InitiateMultipartUpload {
  bucket?: string;
  key?: string;
  uploadId?: string;
}

interface UploadPartResult {
  partNumber: number;
  eTag: string;
}

/**
 * A class for controlling uploads and notifying progress.
 * */
export class FilePartsUploadManager {
  private fileUri: string;
  private file: fileIo.File | undefined;
  private fileChunks: FileUpChunk[] = [];
  private fileChunksSize: number = -1;
  private initMultipartUpload: InitiateMultipartUpload | undefined;
  private netHandles: connection.NetHandle[] = [];
  private uploadResult: UploadPartResult[] = [];
  private abortUpload: boolean = false;
  onProgress?: (progress: number) => void;
  onSuccess?: () => void;
  onError?: () => void;

  constructor(fileUri: string, netHandles: connection.NetHandle[]) {
    this.fileUri = fileUri;
    this.netHandles = netHandles;
    this.abortUpload = false;
    try {
      this.file = fileIo.openSync(this.fileUri, fileIo.OpenMode.READ_ONLY);
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG,
        `[MultiNetworkUploader.constructor] file:${this.fileUri} open failed with err: ${err.code},${err.name}`);
    }
  }

  /**
   * Init upload.
   * @returns Returns true if init success,otherwise returns false.
   */
  async initUpload(): Promise<boolean> {
    if (this.file) {
      try {
        let stat = fileIo.statSync(this.file.fd);
        let uploadFileName = new Date().getTime().toString() + '_' + this.file.name;
        // split a file into file chunks
        this.fileChunks = splitFile(this.file);
        // upload file chunks
        if (this.fileChunks && this.fileChunks.length > 0) {
          this.fileChunksSize = this.fileChunks.length;
          const task =
            new taskpool.Task(initMultiPartUpload, CommonConst.UP_HOST, CommonConst.HTTP_DEFAULT_PORT, uploadFileName);
          const res = await taskpool.execute(task);
          if (res) {
            this.initMultipartUpload = res as InitiateMultipartUpload;
            return true;
          }
        } else {
          hilog.error(DOMAIN, TAG, `[MultiNetworkUploader.initUpload] failed,splitFile Error`);
        }
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `[MultiNetworkUploader.initUpload] Error occurred: ${err.code},${err.name}`);
      }
    } else {
      hilog.error(DOMAIN, TAG, `[MultiNetworkUploader.initUpload] file is null`);
    }
    return false;
  }

  // [Start start_upload]
  /**
   * Start upload file.
   */
  public startUpload() {
    if (!this.netHandles || this.netHandles.length === 0) {
      hilog.error(DOMAIN, TAG, `[MultiNetworkUploader.startUpload] netHandles is empty`);
      return;
    }

    if (!this.fileChunks || this.fileChunks.length === 0) {
      hilog.error(DOMAIN, TAG, `[MultiNetworkUploader.startUpload] fileChunks is empty`);
      return;
    }

    for (let i = 0; i < this.netHandles.length; i++) {
      this.uploadFileChunkWithNet(this.netHandles[i]);
    }
  }
  // [End start_upload]

  public addNetHandle(netHandle: connection.NetHandle) {
    this.netHandles.push(netHandle);
    this.uploadFileChunkWithNet(netHandle);
  }

  // [Start upload_file_with_net]
  /**
   * Upload file segment using assigned net.
   */
  private async uploadFileChunkWithNet(netHandle: connection.NetHandle) {
    if (this.abortUpload) {
      return;
    }
    if (this.fileChunks.length === 0) {
      hilog.info(DOMAIN, TAG, `[MultiNetworkUploader.uploadFileChunkWithNet] fileChunks empty`);
      this.checkUploadSuccess();
      return;
    }

    const fileChunk = this.fileChunks.shift()!;
    let fileChunkWithData = readFileChunkBuffer(this.file!, fileChunk);
    // start upload a file chunk
    if (fileChunkWithData) {
      const task =
        new taskpool.Task(uploadSegment, CommonConst.UP_HOST, CommonConst.HTTP_DEFAULT_PORT, this.initMultipartUpload!,
          fileChunkWithData, netHandle.netId);
      try {
        const uploadPartRes = await taskpool.execute(task);
        // upload success
        if (uploadPartRes) {
          this.uploadResult.push(uploadPartRes as UploadPartResult);
          this.uploadFileChunkWithNet(netHandle);
          this.onProgressUpdate(this.uploadResult.length / this.fileChunksSize);
        } else {
          this.retryUpload(fileChunk, netHandle);
          hilog.error(DOMAIN, TAG, `[uploadFileChunkWithNet] upload failed`);
        }
      } catch (error) {
        this.retryUpload(fileChunk, netHandle);
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `[uploadFileChunkWithNet] taskpool error occurred:${err.code},${err.name}`);
      }
    } else {
      this.retryUpload(fileChunk, netHandle);
      hilog.error(DOMAIN, TAG, `[uploadFileChunkWithNet] readFileChunkBuffer failed`);
    }
  }
  // [End upload_file_with_net]

  private checkUploadSuccess() {
    if (this.fileChunksSize === this.uploadResult.length) {
      hilog.info(DOMAIN, TAG, `[checkUploadSuccess] upload success,start to merge`);
      this.mergeSegmentsOnServer();
    } else {
      hilog.info(DOMAIN, TAG,
        `[checkUploadSuccess] upload not complete,Uploaded:${this.uploadResult.length},Total:${this.fileChunksSize}`);
    }
  }

  private deleteNet(netHandle: connection.NetHandle) {
    let index = this.netHandles.indexOf(netHandle);
    if (index > -1) {
      this.netHandles.splice(index, 1);
    }
  }

  private retryUpload(fileChunk: FileUpChunk, netHandle: connection.NetHandle) {
    // retry with this net
    if (fileChunk.retryTimes < 3) {
      fileChunk.retryTimes++;
      this.fileChunks.unshift(fileChunk);
      this.uploadFileChunkWithNet(netHandle);
    } else {
      hilog.error(DOMAIN, TAG, `[retryUpload] Ignore this net:${netHandle.netId}`);
      this.deleteNet(netHandle);
      if (this.netHandles.length === 0) {
        this.onFailed();
      }
      // retry with other net
      else {
        fileChunk.retryTimes = 0;
        this.fileChunks.unshift(fileChunk);
        this.uploadFileChunkWithNet(this.netHandles[0]);
      }
    }
  }

  // [Start merge_segments]
  /**
   *  Merge all file segments.
   * */
  private async mergeSegmentsOnServer() {
    fileIo.close(this.file?.fd).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, `[mergeSegmentsOnServer] Close file error:${error.code},${error.name}`);
    });
    this.uploadResult.sort((a, b) => a.partNumber - b.partNumber);
    const task = new taskpool.Task(completeMultiPartUploadRequest, CommonConst.UP_HOST, CommonConst.HTTP_DEFAULT_PORT,
      this.initMultipartUpload!,
      this.uploadResult);
    try {
      const res = await taskpool.execute(task);
      if (res) {
        this.onUploadSuccess();
      } else {
        this.onFailed();
      }
    } catch (error) {
      this.onFailed();
    }
  }
  // [End merge_segments]

  public destroyTask() {
    this.abortUpload = true;
    fileIo.close(this.file?.fd).catch((error: BusinessError) => {
      hilog.error(DOMAIN, TAG, `[destroyTask] Close file error:${error.code},${error.name}`);
    })
  }

  private onProgressUpdate(progress: number) {
    this.onProgress?.(progress);
  }

  private onUploadSuccess() {
    this.onSuccess?.();
    this.abortUpload = true;
  }

  private onFailed() {
    this.onError?.();
    this.abortUpload = true;
  }
}