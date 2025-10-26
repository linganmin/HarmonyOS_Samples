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
import { resourceManager } from '@kit.LocalizationKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { SongItem } from '../../models/SongItem';
import { Logger } from '../Logger';
import { hilog } from '@kit.PerformanceAnalysisKit';

const TAG = 'SongItemBuilder';

export default class SongItemBuilder {
  private context: common.UIAbilityContext | undefined;
  private realUrl?: resourceManager.RawFileDescriptor;
  private songItem: SongItem | null = null;

  constructor(context: common.UIAbilityContext) {
    this.context = context;
  }

  public async build(songItem: SongItem): Promise<SongItem> {
    this.songItem = songItem;
    if (!this.context) {
      return this.songItem;
    }
    let rawfileFd = await this.context.resourceManager.getRawFd(songItem.src)
      .catch((error: BusinessError) => {
        Logger.error(TAG, `build error code: ${error.code} ,message: ${error.message}`);
      })
    if (rawfileFd) {
      this.realUrl = rawfileFd;
    } else {
      Logger.error(TAG, 'build get rawfileFd failed')
    }
    Logger.info(TAG, 'build MediaAssetBuilder build realUrl:' + this.realUrl);
    return this.songItem;
  }

  public getRealUrl(): resourceManager.RawFileDescriptor | undefined {
    Logger.info(TAG, `getRealUrl url :${this.realUrl}`)
    return this.realUrl;
  }

  public async release(): Promise<void> {
    if (this.context && this.context !== null && this.songItem !== null) {
      this.context.resourceManager.closeRawFd(this.songItem.src)
        .catch((err: BusinessError) => {
          hilog.error(0x0000, 'testTag',`closeRawFd failed, Code:${err.code}, message:${err.message}`);
        })
    }
    this.songItem = null;
  }
}