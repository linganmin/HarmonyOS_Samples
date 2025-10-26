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

import { wrapperBuilderPriorityTasks } from '../view/PriorityTasks';
import { wrapperBuilderPeriodicTasks } from '../view/PeriodicTasks';
import { wrapperBuilderDelayedTasks } from '../view/DelayedTasks';
import { wrapperBuilderLongTasks } from '../view/LongTasks';
import { wrapperBuilderDependentTasks } from '../view/DependentTasks';
import { wrapperBuilderTaskGroup } from '../view/TaskGroup';
import { wrapperBuilderSequenceRunner } from '../view/SequenceRunner';
import { wrapperBuilderThreadCommunication } from '../view/ThreadCommunication';
import { CommonConstants as Const } from '../common/CommonConstants';

export class GlobalBuilderContext {
  private static instance: GlobalBuilderContext;
  private _objects = new Map<string,Object>();

  public static getContext(): GlobalBuilderContext {
    if(!GlobalBuilderContext.instance) {
      GlobalBuilderContext.instance = new GlobalBuilderContext();
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[0],wrapperBuilderPriorityTasks);
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[1],wrapperBuilderPeriodicTasks);
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[2],wrapperBuilderDelayedTasks);
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[3],wrapperBuilderLongTasks);
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[4],wrapperBuilderDependentTasks);
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[5],wrapperBuilderTaskGroup);
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[6],wrapperBuilderSequenceRunner);
      GlobalBuilderContext.instance.setObject(Const.PAGE_NAMES[7],wrapperBuilderThreadCommunication);
    }
    return GlobalBuilderContext.instance;
  }

  getObject(value:string) : Object|undefined {
    return this._objects.get(value);
  }

  setObject(key:string, objectClass: object): void {
    this._objects.set(key,objectClass);
  }
}