/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { util } from '@kit.ArkTS';
import CommentModel from '../model/CommentModel';
import { i18n } from '@kit.LocalizationKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

export default class CommentViewModel implements IDataSource {
  private comments: Array<CommentModel> = [];
  private listeners: DataChangeListener[] = [];
  private itemId: number = 0;

  totalCount(): number {
    return this.comments.length;
  }

  getData(index: number): CommentModel {
    if (index === this.comments.length - 1) {
      this.getCommentRawFile();
    }
    return this.comments[index];
  }

  pushData(data: CommentModel): void {
    this.comments.push(data);
    this.notifyDataAdd(this.comments.length - 1);
  }

  /**
   * Read dirty data from JSON file
   *
   * @returns Video comment data
   */
  public async getCommentRawFile(): Promise<void> {
    const res =
      await this.getRawFileContent();
    const textDecoder = util.TextDecoder.create();
    const commentArray = (JSON.parse(textDecoder.decodeToString(res)) as CommentViewModel).comments;

    commentArray.forEach(item => {
      item.id = `${this.itemId}`;
      this.itemId++;
      this.pushData(item);
    })
  }

  private getRawFileContent(): Promise<Uint8Array> | undefined {
    try {
      const context = AppStorage.get("context") as UIContext;
      const resourceManager = context.getHostContext()?.resourceManager;
      return resourceManager?.getRawFileContent(i18n.System.getSystemLanguage() === 'zh-Hans' ? 'mockCommentData.json' :
        'mockCommentData.en.json');
    } catch (error) {
      let err = error as BusinessError;
      hilog.error(0x0000, 'CommentViewModel', `ResourceToString failed. code=${err.code}, message=${err.message}`);
    }
    return undefined;
  }

  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos > 0) {
      this.listeners.splice(pos, 1);
    }
  }

  notifyDataAdd(index: number): void {
    this.listeners.forEach((listener: DataChangeListener) => {
      listener.onDataAdd(index);
    })
  }
}