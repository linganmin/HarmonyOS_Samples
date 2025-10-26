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

export class CommonConst {
  /**
   * Upload host address.
   * */
  static readonly UP_HOST: string = '';
  /**
   * User authorization id.
   * */
  static readonly SECRET_ID = '';
  /**
   * user authorization key.
   * */
  static readonly SECRET_KEY = '';
  /**
   * DownLoad File Url1.
   * */
  static readonly DOWN_URL1: string = '';
  /**
   * DownLoad File Url2.
   * */
  static readonly DOWN_URL2: string = '';
  /**
   * Min size when select file.
   * */
  static readonly FILE_SELECT_MIN_SIZE: number = 5 * 1024 * 1024;
  /**
   * Max size when select file.
   * */
  static readonly FILE_SELECT_MAX_SIZE: number = 250 * 1024 * 1024;
  /**
   * Max count when split file.
   * */
  static readonly MAX_SLICE_FILE_COUNT: number = 10;
  /**
   * Min file size  when split file.
   * */
  static readonly MIN_SLICE_FILE_SIZE: number = 1024 * 1024;
  /**
   * Min useful net id.
   * */
  static readonly MIN_USEFUL_NET_ID: number = 100;
  /**
   * Socket time out.
   * */
  static readonly SOCKET_TIME_OUT: number = 10000;
  /**
   * The delimiter between the HTTP header and body.
   * */
  static readonly HEADER_BODY_DELIMITER: string = '\r\n\r\n';
  /**
   * The length (in bytes) of the delimiter between the HTTP header and body.
   * */
  static readonly DELIMITER_LENGTH: number = this.HEADER_BODY_DELIMITER.length;
  /**
   * Content-Length Precision.
   * */
  static readonly CONTENT_LENGTH_PRECISION: number = 10;
  /**
   * Socket binding down port.
   * */
  static readonly SOCKET_BIND_DOWN_PORT: number = 5186;
  /**
   * Socket binding up port.
   * */
  static readonly SOCKET_BIND_UP_PORT: number = 5188;
  /**
   * Default Http port.
   * */
  static readonly HTTP_DEFAULT_PORT: number = 80;
}
