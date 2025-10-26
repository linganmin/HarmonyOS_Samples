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

import { common } from '@kit.AbilityKit';

export type ProgressCallback = (progress: object) => void;

export abstract class GameStepBase {
  protected context_ : common.Context;
  protected progressCallbacks: ProgressCallback[] = [];
  constructor(context: common.Context) {
    this.context_ = context;
  }
  public addProgressListener(callback : ProgressCallback): void {
    this.progressCallbacks.push(callback);
  }

  public abstract Start()

  protected abstract GetProgressObject() : object

  protected abstract CheckFinish() : boolean

  protected triggerProgressCallback() {
    this.progressCallbacks.forEach(callback => {
      let object = this.GetProgressObject();
      callback(object);
    });
  }

  abstract GetResult() : object

  protected Sleep(ms: number):Promise<void> {
    return new Promise((resolve) => {
      setTimeout(resolve, ms);
    })
  }

  public WaitProgressEnd(): Promise<object> {
    return new Promise((resolve) => {
      const interval = 1000;
      const updateInterval = setInterval(() => {
        this.triggerProgressCallback();
        if (this.CheckFinish()) {
          clearInterval(updateInterval);
          resolve(this.GetResult());
        }
      }, interval);
    })
  }
}