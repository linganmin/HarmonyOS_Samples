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

import { buffer } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { CommonConst } from '../common/CommonConst';

const DOMAIN = 0x0000;
const TAG = 'HttpParser';

/**
 * Http message parse state.
 * */
export enum ParseState {
  STATUS_LINE,
  HEADERS,
  BODY,
  COMPLETE
}

/**
 * Extract the body from the HTTP message.
 * @param response Http message.
 * @returns Http body.
 * */
export function extractHttpBody(response: string): string {
  const match = response.match(/\r\n\r\n(.*)/s);
  return match ? match[1] : response;
}


/**
 * HTTP Message Parser.
 * */
export class HttpResponseParser {
  private buffer: ArrayBuffer = new ArrayBuffer(0);
  private state: ParseState = ParseState.STATUS_LINE;
  private headers: Map<string, string> = new Map();
  private contentLength: number = -1;
  private body: ArrayBuffer | null = null;
  private bodyStartIndex: number = 0;

  /**
   * Gets the parsing status of the current HTTP message.
   * @returns Returns the parsing status of the current HTTP message.
   * */
  public getParseState(): ParseState {
    return this.state;
  }

  /**
   * Gets the start position of the body in the HTTP message.
   * @returns Returns the start position of the body in the HTTP message.
   * */
  public getBodyStartIndex(): number {
    return this.bodyStartIndex;
  }

  /**
   * Gets the Content-Length value of the HTTP message.
   * @returns Returns the Content-Length value of the HTTP message.
   * */
  public getContentLength(): number {
    return this.contentLength;
  }


  /**
   * Appends data and parses the HTTP message.
   * @param data Appended data.
   * @returns Returns true if parsed,otherwise return false.
   * */
  public processData(data: ArrayBuffer): boolean {
    this.appendToBuffer(data);
    switch (this.state) {
      case ParseState.STATUS_LINE:
      case ParseState.HEADERS:
        return this.tryParseHeaders();
      case ParseState.BODY:
        return this.tryParseBody();
      case ParseState.COMPLETE:
        return true;
      default:
        return false;
    }
  }

  /**
   * Gets the body of the HTTP message.
   * @returns Returns the body of the HTTP message.
   * */
  public getBody(): ArrayBuffer | null {
    return this.body;
  }

  /**
   * Gets the headers of the HTTP message.
   * @returns Returns the headers of the HTTP message.
   * */
  public getHeader(): Map<string, string> {
    return this.headers;
  }

  /**
   * Reset parser
   * */
  public reset(): void {
    this.buffer = new ArrayBuffer(0);
    this.state = ParseState.STATUS_LINE;
    this.headers = new Map();
    this.contentLength = -1;
    this.body = null;
    this.bodyStartIndex = 0;
  }

  private appendToBuffer(appendData: ArrayBuffer): void {
    const originalView = new Uint8Array(this.buffer);
    const toAppendView = new Uint8Array(appendData);
    const newBuffer = new ArrayBuffer(originalView.byteLength + toAppendView.byteLength);
    const newView = new Uint8Array(newBuffer);
    newView.set(originalView, 0);
    newView.set(toAppendView, originalView.byteLength);
    this.buffer = newBuffer;
  }

  private tryParseHeaders(): boolean {
    try {
      const bufferText = buffer.from(this.buffer).toString('utf-8');
      const headerEndIndex = bufferText.indexOf(CommonConst.HEADER_BODY_DELIMITER);
      if (headerEndIndex === -1) {
        return false;
      }
      const headersText = bufferText.substring(0, headerEndIndex);
      this.parseHeadersText(headersText);
      this.bodyStartIndex = headerEndIndex + CommonConst.DELIMITER_LENGTH;
      const contentLengthStr = this.headers.get('content-length');
      if (contentLengthStr) {
        this.contentLength = parseInt(contentLengthStr, CommonConst.CONTENT_LENGTH_PRECISION);
        this.state = ParseState.BODY;
        return this.tryParseBody();
      } else {
        hilog.warn(DOMAIN, TAG, `No Content-Length header found`);
        this.state = ParseState.COMPLETE;
        return true;
      }
    } catch (error) {
      return false;
    }
  }

  private parseHeadersText(headersText: string): void {
    const lines = headersText.split('\r\n');
    for (let i = 1; i < lines.length; i++) {
      const line = lines[i];
      const colonIndex = line.indexOf(':');
      if (colonIndex > 0) {
        const key = line.substring(0, colonIndex).trim().toLowerCase();
        const value = line.substring(colonIndex + 1).trim();
        this.headers.set(key, value);
      }
    }
  }

  private tryParseBody(): boolean {
    const receivedBodyLength = this.buffer.byteLength - this.bodyStartIndex;
    if (receivedBodyLength >= this.contentLength) {
      this.body = this.buffer.slice(
        this.bodyStartIndex,
        this.bodyStartIndex + this.contentLength
      );
      hilog.info(DOMAIN, TAG, `Body completed! Total length: ${this.body.byteLength} bytes`);
      this.state = ParseState.COMPLETE;
      this.processBody();
      return true;
    }
    return false;
  }

  private processBody(): void {
    if (!this.body) {
      return;
    }
    const contentType = this.headers.get('content-type') || '';
    if (contentType.includes('application/json') || contentType.includes('text/')) {
      try {
        const bodyText = buffer.from(this.body).toString('utf-8');
        hilog.info(DOMAIN, TAG, `Text Body:${JSON.stringify(bodyText)}`);
      } catch (error) {
        const err: BusinessError = error as BusinessError;
        hilog.error(DOMAIN, TAG, `Text Body error:${err.code},${err.name}`);
      }
    } else {
      hilog.info(DOMAIN, TAG, `Binary body, length:${this.body.byteLength}`);
    }
  }
}