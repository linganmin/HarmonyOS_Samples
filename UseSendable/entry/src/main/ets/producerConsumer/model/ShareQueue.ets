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

import { BusinessError } from '@kit.BasicServicesKit';
import { ArkTSUtils } from '@kit.ArkTS';
import utils from '@arkts.utils';
import { ShareNode } from './ShareNode';
import Logger from '../../utils/Logger';

@Sendable
export class ShareQueue<E> {
  private head: ShareNode<E> | null = null;
  private tail: ShareNode<E> | null = null;
  private size: number = 0;

  public async poll(): Promise<E | null> {
    Logger.info('poll');
    let lock: utils.locks.AsyncLock = utils.locks.AsyncLock.request('ShareQueue');
    return lock.lockAsync(() => {
      let pointer: ShareNode<E> | null = this.head;
      if (pointer !== null) {
        let item: E | null = pointer.item;
        this.head = pointer.next;
        if (this.head === null) {
          this.tail = null;
        }
        this.size--;
        return item;
      } else {
        return null;
      }
    }, ArkTSUtils.locks.AsyncLockMode.SHARED).catch((err: BusinessError) => {
      Logger.error(`LockAsync failed. Cause code: ${err.code}, message: ${err.message}`);
      return null;
    });
  }

  public async offer(e: E): Promise<boolean> {
    Logger.info('offer');
    let lock: utils.locks.AsyncLock = utils.locks.AsyncLock.request('ShareQueue');
    return lock.lockAsync(() => {
      let node = new ShareNode<E>();
      node.item = e;
      if (this.tail !== null) {
        this.tail.next = node;
        this.tail = node;
        this.size++;
        return true;
      } else {
        this.size++;
        this.head = node;
        this.tail = node;
        return true;
      }
    }, ArkTSUtils.locks.AsyncLockMode.EXCLUSIVE).catch((err: BusinessError) => {
      Logger.error(`LockAsync failed. Cause code: ${err.code}, message: ${err.message}`);
      return false;
    });
  }

  public async getSize(): Promise<number> {
    let lock: utils.locks.AsyncLock = utils.locks.AsyncLock.request('ShareQueue');
    return lock.lockAsync(() => {
      return this.size;
    }, ArkTSUtils.locks.AsyncLockMode.EXCLUSIVE).catch((err: BusinessError) => {
      Logger.error(`LockAsync failed. Cause code: ${err.code}, message: ${err.message}`);
      return 0;
    });
  }
}