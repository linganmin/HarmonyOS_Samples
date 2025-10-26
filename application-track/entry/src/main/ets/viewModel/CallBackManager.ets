/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the 'License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

import { hiAppEvent, hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { FrameNode, uiObserver } from '@kit.ArkUI';

export default class CallbackManager {
  public static callbackManagerIns: CallbackManager | undefined;

  public static getInstance(): CallbackManager {
    if (!CallbackManager.callbackManagerIns) {
      CallbackManager.callbackManagerIns = new CallbackManager();
    }
    return CallbackManager.callbackManagerIns;
  }

  /**
   * Obtains the AreaChangeCallback callback.
   *
   */
  public getAreaChangeCallback() {
    return (node: FrameNode | null, ratio: number) => {
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s',
        `Node ${node?.getId()}:${node?.getNodeType()} is visibleRatio is ${ratio}`);
      hiAppEvent.write({
        domain: 'test_domain',
        name: 'test_event',
        eventType: hiAppEvent.EventType.FAULT,
        params: {}
      }, (err: BusinessError) => {
        if (err) {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `code: ${err.code}, message: ${err.message}`);
          return;
        }
        hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `getAreaChangeCallback, success to write event`);
      });
    }
  }

  // [Start get_click_callback]
  // entry\src\main\ets\viewModel\CallBackManager.ets
  /**
   * Obtains the ClickCallback callback.
   *
   */
  public getClickCallback() {
    return (node: FrameNode | undefined, uiContext: UIContext) => {
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `FrameNode: ${node}`);
      const uniqueId = node?.getUniqueId();
      const ID = node?.getId();
      const pageInfo = uiContext.getPageInfoByUniqueId(uniqueId);
      const trackData = node?.getCustomProperty(ID);
      let eventParams: Record<string, string | number> = {
        'component_id': ID ?? '',
        'pageInfo': JSON.stringify(pageInfo ?? {}),
        'trackData': JSON.stringify(trackData ?? {})
      };
      // [Start hi_app_event_write]
      hiAppEvent.write({
        domain: 'test_domain',
        name: 'test_event',
        eventType: hiAppEvent.EventType.FAULT,
        params: eventParams
      }, (err: BusinessError) => {
        if (err) {
          hilog.error(0x0000, 'CallBackManager', '%{public}s', `code: ${err.code}, message: ${err.message}`);
          return;
        }
        hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `getClickCallback, success to write event`);
      });
      // [End hi_app_event_write]
    };
  }
  // [End get_click_callback]

  /**
   * Obtains the SwitchCallback callback.
   *
   */
  public getSwitchCallback() {
    return (info: uiObserver.NavDestinationSwitchInfo | uiObserver.RouterPageInfo) => {
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Info: ${JSON.stringify(info)}`);
    }
  }

  public getScrollEvent(info: uiObserver.ScrollEventInfo): void {
    const type = info.scrollEvent;
    if (type === uiObserver.ScrollEventType.SCROLL_START) {
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `Info: ${JSON.stringify(info)}`);
    }
  }

  public getOnTrigger() {
    return (curRow: number, curSize: number, holder: hiAppEvent.AppEventPackageHolder) => {
      if (holder == null) {
        hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'hiAppEvent, holder is null');
        return;
      }
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `curRow: ${curRow}`);
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `curSize: ${curSize}`);
      let eventPkg: hiAppEvent.AppEventPackage | null = null;
      while ((eventPkg = holder.takeNext()) != null) {
        for (const eventInfo of eventPkg.data) {
          hilog.info(0x0000, 'ApplicationTrack', '%{public}s', `hiAppEvent, eventPkg.data: ${eventInfo}`);
        }
      }
    };
  }
}