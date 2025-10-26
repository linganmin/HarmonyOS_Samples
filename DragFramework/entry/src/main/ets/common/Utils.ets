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

import { Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from './Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { bundleManager } from '@kit.AbilityKit';

const TAG: string = '[Utils]';

let contextCaller: AbilityContext;
let want: Want;

interface Eventhub {
  emit(event: string, ...arg: Object[]): void;
}

interface AbilityContext {
  startAbility(want: Want): void;

  eventHub: Eventhub;
}

class EventData {
  public context: AbilityContext | undefined = undefined;
  public launchWant: Want | undefined = undefined;
}

export function getContextData(context: Context | undefined): Want {
  hilog.info(0x0000, TAG, `UtilPage getContextData start`);
  let data: EventData = new EventData();
  context!.eventHub.emit('getAbilityData', data);
  contextCaller = data.context as AbilityContext;
  want = data.launchWant as Want;
  hilog.info(0x0000, TAG, `%{public}s`, `UtilPage getContextData end`);
  return want;
}

export function startMode(wantParameters: Record<string, string | number>, abilityName: string,
  context: Context | undefined) {
  hilog.info(0x0000, TAG, `%{public}s`, `startMode start`);
  getContextData(context);
  bundleManager.getBundleInfoForSelf(bundleManager.BundleFlag.GET_BUNDLE_INFO_DEFAULT)
    .then((bundleInfo: bundleManager.BundleInfo) => {
      let want: Want = {
        bundleName: bundleInfo.name,
        abilityName: abilityName,
        parameters: wantParameters
      };
      try {
        contextCaller.startAbility(want);
      } catch (error) {
        hilog.error(0x0000, TAG, `error is ${error.message}`);
      }
    })
    .catch((error: BusinessError) => {
      hilog.error(0x0000, TAG, `Get bundleinfo error. Cause: ${error.message}`);
    });
  hilog.info(0x0000, TAG, `%{public}s`, `startMode end`);
}

export class BreakpointType<T> {
  private sm: T;
  private md: T;
  private lg: T;

  constructor(sm: T, md: T, lg: T) {
    this.sm = sm;
    this.md = md;
    this.lg = lg;
  }

  getValue(currentBreakpoint: string): T {
    if (currentBreakpoint === Constants.BREAK_POINT_MD) {
      return this.md;
    }
    if (currentBreakpoint === Constants.BREAK_POINT_LG) {
      return this.lg;
    } else {
      return this.sm;
    }
  }
}