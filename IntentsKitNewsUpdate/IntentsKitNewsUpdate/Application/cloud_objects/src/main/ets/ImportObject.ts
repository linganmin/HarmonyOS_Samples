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

import type { BusinessError } from '@kit.BasicServicesKit';
import { cloudFunction } from '@kit.CloudFoundationKit';

export interface CloudObjectLikely {
  name: string;
}

function mockMethod<T extends CloudObjectLikely>(target: T, version: string,
  prop: string | symbol): (...args: unknown[]) => Promise<unknown> {
  return async (...args: unknown[]) => new Promise((resolve, reject) => {
    cloudFunction.call({
      name: target.name,
      version: version,
      data: {
        method: prop,
        params: args
      }
    }).then((value: cloudFunction.FunctionResult) => {
      resolve(value.result);
    }).catch((err: BusinessError) => {
      reject(err);
    });
  });
}

export function importObject<T extends CloudObjectLikely>(tClass: new () => T, version = '$latest'): T {
  return new Proxy<T>(new tClass(), {
    get(target, prop): (...args: unknown[]) => Promise<unknown> {
      return mockMethod<T>(target, version, prop);
    }
  });
}
