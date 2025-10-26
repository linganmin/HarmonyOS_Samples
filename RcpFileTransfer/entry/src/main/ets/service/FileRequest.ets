/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 ("the License");
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
 * 最佳实践：基于RCP的文件上传与下载
 */
import { rcp } from '@kit.RemoteCommunicationKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { BASE_URL } from './Env';
import { File, FileListResponse } from './Model';
import { fileListFormatter } from './Formatter';
import { StatusCodeInterceptor } from './Interceptor';
import { getChunkRanges } from '../utils/CommonUtil';
import { getSandboxPath } from '../utils/LocalFileUtil';
import { imageExtensions, videoExtensions } from '../constants/Constants';
import { Logger } from '../utils/Logger';

const TAG = 'FileRequest';

// [Start config]
function genSessionConfig(httpEventsHandler?: rcp.HttpEventsHandler) {
  const config: rcp.SessionConfiguration = {
    baseAddress: BASE_URL,
    interceptors: [new StatusCodeInterceptor()],
    requestConfiguration: {
      tracing: { httpEventsHandler },
      transfer: {
        timeout: {
          connectMs: 1000 * 60 * 20,
          transferMs: 1000 * 60 * 20
        }
      }
    }
  };
  return config;
}

// [End config]

export function getFileList(): Promise<File[]> {
  try {
    const session = rcp.createSession(genSessionConfig());
    return session.get('~/api/get_file_list').then((res: rcp.Response) => {
      const fileListRes: FileListResponse = res.toJSON() as FileListResponse;
      const fileList: File[] = fileListFormatter(fileListRes);
      return fileList.filter(file => {
        const extension = file.name.split('.').pop() || '';
        return imageExtensions.includes(extension) || videoExtensions.includes(extension);
      });
    }).finally(() => {
      session.close();
    });
  } catch (exception) {
    Logger.error(TAG, `getFileList failed. Code:${exception.code}, message:${exception.message}`);
    return Promise.resolve([]);
  }
}

// [Start get_file]
export function getFileSize(fileName: string): Promise<number> {
  try {
    const session = rcp.createSession(genSessionConfig());
    return session.head(`/${fileName}`).then(res => {
      const contentLength = res.headers['content-length'];
      return contentLength ? Number(contentLength) : 0;
    }).finally(() => {
      session.close();
    });
  } catch (exception) {
    Logger.error(TAG, `getFileSize failed. Code:${exception.code}, message:${exception.message}`);
    return Promise.resolve(0);
  }
}

// [End get_file]

// [Start download]
export function download(fileName: string, httpEventsHandler: rcp.HttpEventsHandler) {
  try {
    const destPath = getSandboxPath(fileName);
    const rcpSession = rcp.createSession(genSessionConfig(httpEventsHandler));
    const downloadTo: rcp.DownloadToFile = {
      kind: 'file',
      file: destPath
    };
    return rcpSession.downloadToFile(`/${fileName}`, downloadTo)
      .then(() => destPath)
      .finally(() => {
        rcpSession.close();
      });
  } catch (exception) {
    Logger.error(TAG, `download failed. Code:${exception.code}, message:${exception.message}`);
    return Promise.resolve('');
  }
}

// [End download]

// [Start upload_rcp]
export function upload(srcPath: string, httpEventsHandler: rcp.HttpEventsHandler) {
  try {
    const session = rcp.createSession(genSessionConfig(httpEventsHandler));
    const formData = new rcp.MultipartForm({
      file: {
        contentOrPath: srcPath
      }
    });
    return session.post('/', formData).catch((err: BusinessError) => {
      Logger.error(TAG, `post failed: code: ${err.code}, message: ${err.message}`);
    }).finally(() => {
      session.close();
    });
  } catch (exception) {
    Logger.error(TAG, `upload failed. Code:${exception.code}, message:${exception.message}`);
    return;
  }
}

// [End upload_rcp]

export async function chunkedDownload(
  fileName: string,
  onProgress: rcp.OnDownloadProgress,
  chunkSize: number = 1024 * 60
) {
  const filePath = getSandboxPath(fileName);
  try {
    const file = fileIo.openSync(filePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
    const totalSize = await getFileSize(fileName);
    const session = rcp.createSession(genSessionConfig());
    let downloaded: number = 0;
    for (const range of getChunkRanges(totalSize, chunkSize)) {
      const request = new rcp.Request(`/${fileName}`);
      const from = range[0];
      const to = range[1];
      request.transferRange = { from, to };
      const response = await session.fetch(request);
      fileIo.writeSync(file.fd, response.body, { offset: from });
      downloaded += (to - from + 1);
      onProgress(totalSize, downloaded);
    }
  } catch (exception) {
    Logger.error(TAG, `closeSync failed: code: ${exception.code}, message: ${exception.message}`);
  }
  return filePath;
}

export class ResumableDownloadManager {
  session: rcp.Session = rcp.createSession(genSessionConfig());
  url: string;
  file: fileIo.File;
  onProgress: rcp.OnDownloadProgress;
  currentRequest: rcp.Request | null = null;
  downloadedSize: number = 0;
  totalSize: number = 0;

  constructor(url: string, filePath: string, onProgress: rcp.OnDownloadProgress,) {
    this.url = url;
    this.file = fileIo.openSync(filePath, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE);
    this.onProgress = onProgress;
  }

  // [Start start]
  async start() {
    this.totalSize = this.totalSize || await getFileSize(this.url)
    const request = new rcp.Request(this.url);
    const writeSync: (buffer: ArrayBuffer) => void = buffer => {
      fileIo.writeSync(this.file.fd, buffer, { offset: this.downloadedSize })
      this.downloadedSize = fileIo.statSync(this.file.fd).size;
      this.onProgress(this.totalSize, this.downloadedSize);
    }
    request.destination = {
      kind: 'stream',
      stream: { writeSync }
    };
    request.transferRange = { from: this.downloadedSize };
    this.currentRequest = request;
    return this.session.fetch(request).then(() => {
      this.session.close();
      fileIo.close(this.file);
    }).catch((err: BusinessError) => {
      Logger.error(TAG,
        `fetch failed. Code:${err.code}, message:${err.message}`);
    });
  }

  // [End start]

  // [Start pause]
  pause() {
    this.session.cancel(this.currentRequest);
  }

  // [End pause]
}