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

import { socket } from '@kit.NetworkKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { buffer } from '@kit.ArkTS';
import { FileDownChunk, writeFileBuffer } from '../utils/FileUtils';
import { DownloadListenerClass } from '../viewmodel/download/FileDownManager';
import { HttpResponseParser, ParseState } from '../utils/HttpParser';
import { CommonConst } from '../common/CommonConst';

const DOMAIN = 0x0000;
const TAG = 'SocketClient';

/**
 * Connect to the server using a socket.
 * @param socketInstance Socket client.
 * @param address Server address.
 * @param port Server port.
 * @returns Returns true if the connection is successful, otherwise returns false.
 * */
export async function socketConnect(socketInstance: socket.TCPSocket, address: string, port: number): Promise<boolean> {
  return new Promise(async (resolve) => {
    try {
      let ipAddress: socket.NetAddress = {} as socket.NetAddress;
      ipAddress.address = address;
      ipAddress.port = port;

      let tcpConnect: socket.TCPConnectOptions = {} as socket.TCPConnectOptions;
      tcpConnect.address = ipAddress;
      tcpConnect.timeout = CommonConst.SOCKET_TIME_OUT;
      socketInstance.setExtraOptions({
        keepAlive: false,
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `[socketConnect] setExtraOptions error:${err.code},${err.message}`);
      })
      socketInstance.connect(tcpConnect).then(() => {
        hilog.info(DOMAIN, TAG, `[socketConnect] connect success`);
        resolve(true);
      }).catch((err: BusinessError) => {
        hilog.error(DOMAIN, TAG, `[socketConnect.catch1] connect failed:${err.code},${err.message}`);
        resolve(false);
      });
    } catch (err) {
      let error: BusinessError = err as BusinessError;
      hilog.error(DOMAIN, TAG, `[socketConnect.catch2] connect failed:${error.code},${error.message}}`);
      resolve(false);
    }
  });
}


/**
 * Sends data to the server using a socket.
 * @param socketInstance Socket client.
 * @param request Data to be transmitted to the server.
 * @returns Return true if the data is sent successfully, otherwise return false.
 * */
export async function sendRequestToServer(socketInstance: socket.TCPSocket,
  request: string | ArrayBuffer): Promise<boolean> {
  return new Promise(async (resolve) => {
    try {
      let tcpSendOptions: socket.TCPSendOptions = {
        data: request
      };
      await socketInstance.send(tcpSendOptions).then(() => {
        resolve(true);
      }).catch((err: BusinessError) => {
        resolve(false);
        hilog.error(DOMAIN, TAG, `[sendRequestToServer.catch1] send failed:${err.code},${err.name}`);
      });
    } catch (error) {
      resolve(false);
      const err: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, `[sendRequestToServer.catch2] send failed:${err.code},${err.name}`);
    }
  })
}

/**
 * Retrieve data through a socket.
 * @param host Server host.
 * @param port Server port.
 * @param requestData Data to be transmitted to the server.
 * @param socketObj Socket client.
 * @returns Return data if get data success,otherwise return undefined.
 * */
export async function getDataBySocket(host: string, port: number,
  requestData: string | ArrayBuffer, socketObj?: socket.TCPSocket): Promise<socket.SocketMessageInfo | undefined> {
  return new Promise(async (resolve) => {
    const socketInstance: socket.TCPSocket = socketObj ? socketObj : socket.constructTCPSocketInstance();
    socketInstance.on('error', () => {
      resolve(undefined);
    })
    socketInstance.on('message', (value: socket.SocketMessageInfo) => {
      resolve(value);
    });
    // connect server and send data to server
    if (await socketConnect(socketInstance, host, port) && await sendRequestToServer(socketInstance, requestData)) {
    } else {
      resolve(undefined);
    }
  });
}

/**
 * Get "Content-Length" header value by socket.
 * @param host Server host.
 * @param port Server port.
 * @param remotePath Server path.
 * @returns Return "Content-Length" in number if got.
 * */
export async function getContentLength(host: string, port: number, remotePath: string): Promise<number> {
  return new Promise(async (resolve, reject) => {
    const tempSocket = socket.constructTCPSocketInstance();
    // build request
    const request =
      `HEAD ${remotePath} HTTP/1.1\r\nHost: ${host}:${port}\r\nConnection: close${CommonConst.HEADER_BODY_DELIMITER}`;
    // get data by socket
    const value: socket.SocketMessageInfo | undefined = await getDataBySocket(host, port, request);
    // parse value
    if (value) {
      try {
        const responseText = buffer.from(value.message).toString('utf-8');
        // split headers
        const headers = responseText.split('\r\n');
        let totalSize = 0;
        // get "Content-Length" value
        for (const header of headers) {
          if (header.toLowerCase().startsWith('content-length:')) {
            totalSize = parseInt(header.split(':')[1].trim());
            break;
          }
        }
        // close socket
        tempSocket.close().catch((error: BusinessError) => {
          const err: BusinessError = error as BusinessError;
          hilog.error(0x0000, TAG, `[getContentLength] socket close error: ${err.code},${err.name}`);
        });
        if (totalSize > 0) {
          resolve(totalSize);
        } else {
          reject(new Error('Cannot get file size'));
        }
      } catch (error) {
        reject(new Error(`Cannot get file size:${error}`));
      }
    } else {
      reject(new Error('Get file size error,Data empty'));
    }
  });
}


/**
 * Download file part by socket.
 * @param host Server host.
 * @param remotePath Server path.
 * @param port Server port.
 * @param socketInstance Socket client.
 * @param fileChunk File parts to download.
 * @param downProgress Notify download progress.
 * @returns Return true if download success,otherwise return false.
 * */
export async function downloadPart(host: string, remotePath: string, port: number, socketInstance: socket.TCPSocket,
  fileChunk: FileDownChunk, downProgress?: DownloadListenerClass): Promise<boolean> {
  return new Promise(async (resolve, reject) => {
    const rangeHeader = `Range: bytes=${fileChunk.startPosition}-${fileChunk.endPosition}`;
    // build request
    const request =
      `GET ${remotePath} HTTP/1.1\r\nHost: ${host}:${port}\r\n${rangeHeader}\r\nConnection: close${CommonConst.HEADER_BODY_DELIMITER}`;
    socketInstance.on('error', (error) => {
      const err: BusinessError = error as BusinessError;
      hilog.error(DOMAIN, TAG, `[downloadPart error] ${err.code},${err.name}`);
      socketInstance.close().catch((error: BusinessError) => {
        hilog.error(DOMAIN, TAG, `[downloadPart] socket close error:${error.code},${error.name}`);
      });
      reject();
    })

    // create a http data parser
    const parser = new HttpResponseParser();
    let startPosition = fileChunk.startPosition;
    let wroteLength = -1;
    let parsedHeader: boolean = false;

    socketInstance.on('message', (value: socket.SocketMessageInfo) => {
      try {
        // if get headers success,write data buffer to disk directly
        if (parsedHeader) {
          writeFileBuffer(fileChunk.fileFd, startPosition, value.message);
          startPosition += value.message.byteLength;
          wroteLength += value.message.byteLength;
          downProgress?.progressUpdate?.(wroteLength, parser.getContentLength());
          if (wroteLength === parser.getContentLength()) {
            resolve(true);
          }
        } else {
          // parse data until get all headers
          parser.processData(value.message);
          const state = parser.getParseState();
          switch (state) {
            // write body data buffer to disk directly
            case ParseState.BODY:
              hilog.info(DOMAIN, TAG, `Parsed Header`);
              parsedHeader = true;
              const bodyStartIndex = parser.getBodyStartIndex();
              const bodyChunk = value.message.slice(bodyStartIndex);
              writeFileBuffer(fileChunk.fileFd, startPosition, bodyChunk);
              startPosition += bodyChunk.byteLength;
              wroteLength = bodyChunk.byteLength;
              downProgress?.progressUpdate?.(wroteLength, parser.getContentLength());
              break;
            case ParseState.COMPLETE:
              // get all data success,write all body data buffer to disk
              hilog.info(DOMAIN, TAG, `Parsed Header and Body`);
              parsedHeader = true;
              const bodyAll = parser.getBody();
              writeFileBuffer(fileChunk.fileFd, startPosition, bodyAll);
              wroteLength = bodyAll ? bodyAll.byteLength : -1;
              downProgress?.progressUpdate?.(wroteLength, parser.getContentLength());
              socketInstance.close().catch((error: BusinessError) => {
                const err: BusinessError = error as BusinessError;
                hilog.error(0x0000, TAG, `[downloadPart] socket close error: ${err.code},${err.name}`);
              });
              resolve(true);
              break;
            default:
              parsedHeader = false;
              break;
          }
        }
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `[downloadPart]  error:${err.code},${err.name},fileFd:${fileChunk.fileFd}`);
        reject();
      }
    });
    if (await socketConnect(socketInstance, host, port) && await sendRequestToServer(socketInstance, request)) {
      hilog.info(DOMAIN, TAG, `[downloadPart] Connect and send request  success fileFd:${fileChunk.fileFd}`);
    } else {
      hilog.error(DOMAIN, TAG, `[downloadPart] Connect or send request error fileFd: ${fileChunk.fileFd}`);
      reject();
    }
  })
}