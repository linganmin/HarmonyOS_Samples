/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the 'License');
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an 'AS IS' BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

let uiContext: UIContext;
let uri: string;

export class ContextStorageManager {
  private static instance: ContextStorageManager;

  private constructor() {
  }

  public static getInstance() {
    if (!ContextStorageManager.instance) {
      ContextStorageManager.instance = new ContextStorageManager();
    }
    return ContextStorageManager.instance;
  }

  public init(UIContext: UIContext) {
    uiContext = UIContext;
  }

  public getContext() {
    return uiContext;
  }

  public initUri(Uri: string) {
    uri = Uri;
  }

  public getUriUtil() {
    return uri;
  }
}