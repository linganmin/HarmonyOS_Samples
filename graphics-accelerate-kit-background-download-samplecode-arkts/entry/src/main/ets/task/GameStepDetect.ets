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
import { hilog } from '@kit.PerformanceAnalysisKit';
import { assetDownloadManager } from '@kit.GraphicsAccelerateKit';
import { GameStepBase } from './GameStepBase';
import { TAG, DOMAINID } from '../common/CommonConstants';
import { AssetSessionStorage, GroupInfo } from '../session/AssetSessionStorage';

export interface StepDetectResult {
  nextStep: number;
  version: string;
}

export interface StepDetectProgress {
  progress: number;
  totalCount: number;
  successCount: number;
}

export class GameStepDetect extends GameStepBase{
    private isFinished: boolean = false;
    private nextStep: number = -1;
    private remoteVersion : string = '';
    private stepDetectProgress : StepDetectProgress = {
      progress: 0,
      totalCount: 0,
      successCount: 0
    }

    constructor(context: common.Context) {
      super(context);
    }

    GetResult(): object {
      let result :StepDetectResult = {
        nextStep: this.nextStep,
        version: this.remoteVersion,
      }
      return result;
    }

    protected GetProgressObject(): object {
      return this.stepDetectProgress;
    }

    protected CheckFinish(): boolean {
      return this.isFinished;
    }

    public Start() {
      setTimeout(async ()=>{
        hilog.info(DOMAINID, TAG, 'GameStepDetect Start()');
        // Get local info.
        let storage : AssetSessionStorage = await AssetSessionStorage.create(this.context_);
        let localGroupInfo : GroupInfo|null = null;
        try {
          localGroupInfo = await storage.queryGroupInfoForLatest();
          this.remoteVersion = localGroupInfo.groupId;
        } catch (error) {
          hilog.error(DOMAINID,
            TAG, `failed to queryGroupInfoForLatest, errCode: ${error.code}, errMessage: ${error.message}`);
          this.nextStep = 1;
          this.stepDetectProgress.progress = 0;
          this.stepDetectProgress.totalCount = 0;
          this.stepDetectProgress.successCount = 0;
          this.triggerProgressCallback();
          this.isFinished = true;
          return;
        }
        try {
          let resourceList = await storage.queryResourceInfoByGroupId(localGroupInfo.groupId);
          let totalCount = resourceList.length;
          let successCount = 0;
          for (let index = 0; index < totalCount; index++) {
            const resource = resourceList[index];
            if (resource.status === assetDownloadManager.State.FINISHED) {
              successCount++;
            }
          }
          this.nextStep = totalCount === successCount ? 2 : 1;
          this.stepDetectProgress.progress = successCount / totalCount * 100;
          this.stepDetectProgress.totalCount = totalCount;
          this.stepDetectProgress.successCount = successCount;
          hilog.info(DOMAINID,
            TAG, `success to queryResourceInfoByGroupId, totalCount: ${totalCount}, successCount: ${successCount}`);
          this.triggerProgressCallback();
          this.isFinished = true;
        } catch (error) {
          hilog.info(DOMAINID,
            TAG, `failed to queryResourceInfoByGroupId, errCode: ${error.code}, errMessage: ${error.message}`);
          this.nextStep = 1;
          this.stepDetectProgress.progress = 0;
          this.stepDetectProgress.totalCount = 0;
          this.stepDetectProgress.successCount = 0;
          this.triggerProgressCallback();
          this.isFinished = true;
          return;
        }
      }, 0)
    }
}

