/*
* Copyright (C) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
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
import { FrameNode, window } from '@kit.ArkUI';
import { UIAbility } from '@kit.AbilityKit';
import CallbackManager from '../viewModel/CallBackManager';

export default class EntryAbility extends UIAbility {
  windowClass: window.Window | undefined = undefined;

  onCreate(): void {
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'Ability onDestroy');
  }

  // [Start segment]
  // entry\src\main\ets\entryability\EntryAbility.ets
  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/HomePage', (err) => {
      const uiContext: UIContext = windowStage.getMainWindowSync().getUIContext();
      AppStorage.setOrCreate('uiContext', uiContext);
      let windowClass: window.Window = windowStage.getMainWindowSync();
      windowClass.setWindowLayoutFullScreen(true);
      let naviBarArea: window.AvoidArea =
        windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      let area: window.AvoidArea = windowClass.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      AppStorage.setOrCreate<number>('naviIndicatorHeight', uiContext.px2vp(naviBarArea.bottomRect.height));
      AppStorage.setOrCreate<number>('statusBarHeight', uiContext.px2vp(area.topRect.height));
      // [Start entry_ability]
      // entry\src\main\ets\entryability\EntryAbility.ets
      uiContext.getUIObserver()?.on('willClick', (_event: ClickEvent, node?: FrameNode) => {
        const clickCallback = CallbackManager.getInstance().getClickCallback();
        clickCallback(node, uiContext);
      })
      // [End entry_ability]
      // [Start get_ui_observer]
      // entry\src\main\ets\entryability\EntryAbility.ets
      uiContext.getUIObserver()
        .on('scrollEvent', (info) => CallbackManager.getInstance().getScrollEvent(info))
      // [End get_ui_observer]
      // [Start nav_destination_switch]
      // entry\src\main\ets\entryability\EntryAbility.ets
      uiContext.getUIObserver().on('navDestinationSwitch', (info) => {
        const switchCallback = CallbackManager.getInstance().getSwitchCallback();
        switchCallback(info);
      })
      // [Start nav_destination_switch]
      // [Start router_page_update]
      // entry\src\main\ets\entryability\EntryAbility.ets
      uiContext.getUIObserver().on('routerPageUpdate', (info) => {
        const switchCallback = CallbackManager.getInstance().getSwitchCallback();
        switchCallback(info);
      })
      // [End router_page_update]
      if (err.code) {
        hilog.error(0x0000, 'EntryAbility', '%{public}s', 'Failed to load the content. Cause: %{public}s',
          JSON.stringify(err) ?? '');
        return;
      }
      // [Start on_trigger]
      // entry\src\main\ets\entryability\EntryAbility.ets
      const onTrigger = CallbackManager.getInstance().getOnTrigger();
      hiAppEvent.addWatcher({
        name: 'watcher1',
        appEventFilters: [
          {
            domain: 'test_domain',
            eventTypes: [hiAppEvent.EventType.FAULT, hiAppEvent.EventType.BEHAVIOR]
          }
        ],
        triggerCondition: {
          row: 10,
          size: 1000,
          timeOut: 1
        },
        onTrigger: onTrigger
      })
      hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'Succeeded in loading the content.');
      // [Start on_trigger]
    });
  }
  // [End segment]

  // [Start on_window_stage_destroy]
  // entry\src\main\ets\entryability\EntryAbility.ets
  onWindowStageDestroy(): void {
    const uiContext: UIContext | undefined = AppStorage.get('uiContext');
    uiContext?.getUIObserver().off('willClick');
    uiContext?.getUIObserver().off('scrollEvent');
    uiContext?.getUIObserver().off('navDestinationSwitch');
    uiContext?.getUIObserver().off('routerPageUpdate');
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'Ability onWindowStageDestroy');
  }
  // [End on_window_stage_destroy]

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'ApplicationTrack', '%{public}s', 'Ability onBackground');
  }
}
