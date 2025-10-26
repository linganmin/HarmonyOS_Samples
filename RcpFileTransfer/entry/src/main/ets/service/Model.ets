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
 * Represents a file or folder response from the server.
 * @interface
 */
interface FileResponse {
  /** The name of the file or folder. */
  n: string,

  /** The upload time of the file or folder. */
  m: string,

  /** The size for the file. */
  s?: number
}

export interface FileListResponse {
  'can_archive': boolean
  'can_upload': boolean
  'can_delete': boolean
  'can_overwrite': boolean
  'can_comment': boolean
  list: FileResponse[]
}

export interface File {
  id: string
  name: string
}