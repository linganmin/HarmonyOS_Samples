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

import { BusinessError, emitter } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { connection, socket } from '@kit.NetworkKit';
import { taskpool, util } from '@kit.ArkTS';
import { fileIo } from '@kit.CoreFileKit';
import { deleteFile, FileDownChunk } from '../../utils/FileUtils';
import { getDomainFromUrl } from '../../utils/CommonUtils';
import { downloadPart, getContentLength } from '../../net/SocketClient';
import { bindSpecifiedNet } from '../../net/NetBoostManager';
import { CommonConst } from '../../common/CommonConst';

const DOMAIN = 0x0000;
const TAG = 'FileDownManager';

/**
 * Download the file using specified netHandle.
 * @param remotePath Server path.
 * @param port Server port.
 * @param fileChunk File parts to download.
 * @param netId NetHandle id.
 * @param downProgress Notify download progress.
 * @returns Returns true if the download is successful, otherwise returns false.
 * */
@Concurrent
export async function downloadFileChunkWithNet(remotePath: string, port: number, fileChunk: FileDownChunk,
  netId: number, downProgress?: DownloadListenerClass): Promise<boolean> {
  const socketInstance: socket.TCPSocket = socket.constructTCPSocketInstance();
  await bindSpecifiedNet(socketInstance, netId, CommonConst.SOCKET_BIND_DOWN_PORT);
  hilog.info(0x0000, 'downloadFileChunkWithNet', `start download ${fileChunk.fileFd} with net:${netId}`);

  try {
    return await downloadPart(getDomainFromUrl(remotePath), remotePath, port, socketInstance, fileChunk, downProgress);
  } catch (error) {
    const err: BusinessError = error as BusinessError;
    hilog.error(0x0000, 'downloadFileChunkWithNet', `Download failed:${err.code},${err.name}`);
    return false;
  }
}

/**
 * Get the file size using specified netHandle.
 * @param remotePath Server path.
 * @param port Server port.
 * @param netId NetHandle id.
 * @returns Returns the file size on success, otherwise returns -1.
 * */
@Concurrent
export async function getFileSizeWithNet(remotePath: string, port: number, netId: number): Promise<number> {
  const socketInstance: socket.TCPSocket = socket.constructTCPSocketInstance();
  await bindSpecifiedNet(socketInstance, netId, CommonConst.SOCKET_BIND_DOWN_PORT);
  hilog.info(0x0000, 'GetFileSize', `Start get file size with net:${netId}`);
  try {
    return await getContentLength(getDomainFromUrl(remotePath), port, remotePath);
  } catch (error) {
    return -1;
  }
}

/**
 * An interface for notifying download progress.
 * */
interface DownloadListener {
  onStart?: () => void;
  progressUpdate?: (progress: number, chunkSize: number) => void;
  onFail?: () => void;
}

/**
 * A class containing download information.
 * */
export class DownLoadInfo {
  url: string = '';
  fileName: string = '';
  filePath: string = '';
  emitterName: string = '';

  constructor(url: string, fileName: string, filePath: string) {
    this.url = url;
    this.fileName = fileName;
    this.filePath = filePath;
    this.emitterName = util.getHash(new String(this.url + fileName + filePath)).toString();
  }
}

/**
 * A class for notifying download progress.
 * */
@Sendable
export class DownloadListenerClass implements DownloadListener {
  private name: string = '';

  constructor(name: string) {
    this.name = name;
  }

  progressUpdate(progress: number, chunkSize: number) {
    let eventData: emitter.EventData = {
      data: {
        'progress': progress,
        'chunkSize': chunkSize
      }
    };
    emitter.emit(this.name, eventData);
  }

  onFail() {
    hilog.info(0x0000, `DownloadListenerClass`, `[onFail] Download failed`);
  }
}

/**
 * A class for controlling downloads and notifying progress.
 * */
export class FileDownloadManager {
  private netHandle?: connection.NetHandle;
  private downUrls: string = '';
  private retryTimes: number = 0;
  private downListener: DownloadListenerClass;
  private info: DownLoadInfo;
  private fileChunk: FileDownChunk = new FileDownChunk();
  private isFileDownloading: boolean = false;
  onStart?: (fileBytesSize: number) => void;
  onProgress?: (downloaded: number, fileSize: number, progress: number) => void;
  onSuccess?: () => void;
  onError?: () => void;

  private initDownload() {
    const fileAbsPath = this.info.filePath + '/' + this.info.fileName;
    deleteFile(fileAbsPath);
    try {
      const randomAccessFile =
        fileIo.createRandomAccessFileSync(fileAbsPath, fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE);
      this.fileChunk.fileFd = randomAccessFile.fd;
      this.fileChunk.startPosition = 0;
    } catch (error) {
      const err: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, `[initDownload] error occurred:${err.code},${err.name}`);
    }

    emitter.on(this.info.emitterName, (eventData: emitter.EventData) => {
      let data = eventData?.data;
      if (data && data.progress && data.chunkSize) {
        const downloaded = data.progress as number;
        const fileSize = data.chunkSize as number;
        this.onProgressUpdate(downloaded, fileSize, downloaded / fileSize);
      }
    });
  }

  constructor(info: DownLoadInfo, netHandle: connection.NetHandle) {
    this.info = info;
    this.downUrls = this.info.url;
    this.netHandle = netHandle;
    this.downListener = new DownloadListenerClass(this.info.emitterName);
    this.initDownload();
  }

  // [Start start_download]
  /**
   * Start download file.
   * */
  public async startDownload() {
    if (this.downUrls) {
      this.isFileDownloading = true;
      const netId = this.netHandle ? this.netHandle.netId : -1;
      const task = new taskpool.Task(getFileSizeWithNet, this.downUrls, CommonConst.HTTP_DEFAULT_PORT, netId);
      try {
        const fileSize = await taskpool.execute(task) as number;
        if (fileSize > 0) {
          // notify download start
          this.onDownStart(fileSize);
          this.fileChunk.endPosition = fileSize;
          // start download the file using taskpool
          const downTask =
            new taskpool.Task(downloadFileChunkWithNet, this.downUrls, CommonConst.HTTP_DEFAULT_PORT, this.fileChunk,
              netId, this.downListener);
          const downRes = await taskpool.execute(downTask);
          if (downRes) {
            // notify download success
            this.onDownSuccess();
          } else {
            // download failed,retry again
            this.retryDownload();
          }
        } else {
          // download failed,retry again
          this.retryDownload();
          hilog.error(DOMAIN, TAG, `[startDownload] upload failed`);
        }
      } catch (error) {
        // download failed,retry again
        this.retryDownload();
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `[startDownload] taskpool error occurred:${err.code},${err.name}`);
      }
    } else {
      hilog.warn(DOMAIN, TAG, `[startDownload] Url is null`);
      // download failed,retry again
      this.onDownFailed();
    }
  }
  // [End start_download]

  private retryDownload() {
    this.retryTimes++;
    if (this.retryTimes < 3) {
      this.startDownload();
    } else {
      this.onDownFailed();
    }
  }

  private onDownStart(fileBytesSize: number) {
    this.onStart?.(fileBytesSize);
    this.isFileDownloading = true;
  }

  private onProgressUpdate(downloaded: number, fileSize: number, progress: number) {
    this.onProgress?.(downloaded, fileSize, progress);
  }

  private onDownSuccess() {
    this.onSuccess?.();
    this.isFileDownloading = false;
  }

  private onDownFailed() {
    this.onError?.();
    this.isFileDownloading = false;
  }

  /**
   * Get the file downloading status.
   * @returns Returns true if the file is downloading,otherwise returns false.
   * */
  public isDownloading(): boolean {
    return this.isFileDownloading;
  }

  /**
   * Clear data.
   * */
  public clean() {
    this.isFileDownloading = false;
    fileIo.close(this.fileChunk.fileFd).catch((err: BusinessError) => {
      hilog.error(DOMAIN, TAG, `[clean] Close file error:${err.code},${err.message}`);
    })
    emitter.off(this.info.emitterName);
  }
}