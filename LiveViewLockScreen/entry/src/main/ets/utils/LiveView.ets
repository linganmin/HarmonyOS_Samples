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

import { appManager, WantAgent, wantAgent } from '@kit.AbilityKit';
// [Start startContinuousRunningTask]
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
// [StartExclude startContinuousRunningTask]
// [Start pushCommonEvent]
import { BusinessError, commonEventManager } from '@kit.BasicServicesKit';
// [StartExclude pushCommonEvent]
import { hilog } from '@kit.PerformanceAnalysisKit';
import PreferenceModel from '../model/PreferenceModel';
import { RouteData } from '../model/RouteDataModel';
import { LiveViewUtil } from '../utils/LiveViewUtil';
import { getRouteData } from '../viewmodel/RouteDataViewModel';

const TAG: string = '[LiveView]';

export class LiveView {
  // Singleton pattern implementation
  private static instance: LiveView;
  private context: Context;
  private liveViewController: LiveViewUtil;
  private updateInterval: number | undefined;

  // Private constructor for singleton pattern
  private constructor(context: Context) {
    this.context = context;
    this.liveViewController = new LiveViewUtil(context);
  }

  // Singleton accessor method
  public static getInstance(context: Context): LiveView {
    // Lazy initialization of the singleton instance
    if (!LiveView.instance) {
      LiveView.instance = new LiveView(context);
    }
    return LiveView.instance;
  }

  // Main entry point to start live view functionality
  public createLiveView() {
    let routeData = getRouteData();
    let lightTime = PreferenceModel.getPreference(this.context, 'lightTime', 0) as number;
    routeData.laneData.lightTime = lightTime;
    // Initialize live view and start background tasks
    this.liveViewController.startLiveView(routeData).then(() => {
      this.startContinuousRunningTask();
      // [Start getRunningProcessInfo]
      // Set up periodic state checking
      this.updateInterval = setInterval(() => {
        // Monitor application state changes
        appManager.getRunningProcessInformation().then((data: Array<appManager.ProcessInformation>) => {
          hilog.info(0x0000, TAG, '%{public}s', 'Success to getRunningProcessInformation');
          // Handle background state
          if (data[0].state === appManager.ProcessState.STATE_BACKGROUND) {
            // [StartExclude getRunningProcessInfo]
            let routeData = getRouteData();
            let lightTime = PreferenceModel.getPreference(this.context, 'lightTime', 0) as number;
            routeData.laneData.lightTime = lightTime;
            this.liveViewController.updateLiveView(routeData);
            // [EndExclude pushCommonEvent]
            // Prepare common event data
            let options: commonEventManager.CommonEventPublishData = {
              data: 'data',
              bundleName: 'com.example.mapliveviewsample',
              parameters: {
                'laneData': routeData.laneData
              }
            };
            // Publish system event for lock screen updates
            commonEventManager.publish('live_view_lock_screen', options, (error: BusinessError) => {
              if (error) {
                hilog.error(0x0000, TAG, '%{public}s',
                  `Failed to publish commonEvent. code is ${error.code} message is ${error.message}`);
              } else {
                hilog.info(0x0000, TAG, '%{public}s', 'Succeeded in publishing commonEvent.')
              }
            });
            // [End pushCommonEvent]
            // [EndExclude getRunningProcessInfo]
          }
        }).catch((error: BusinessError) => {
          hilog.error(0x0000, TAG, '%{public}s',
            `Failed to getRunningProcessInformation. code is ${error.code} message is ${error.message}`);
        });
      }, 1000)
      // [End getRunningProcessInfo]
    })
  }

  // Cleanup method to stop all live view activities
  public finishLiveView() {
    // [Start clearPeriodicUpdates]
    // Clear periodic updates
    if (this.updateInterval !== undefined) {
      clearInterval(this.updateInterval);
      this.updateInterval = undefined;
      hilog.info(0x0000, TAG, 'Timer has been cleared');
    }
    // [End clearPeriodicUpdates]

    // Shutdown live view components
    this.liveViewController.closeLiveView();

    // [Start stopBackgroundRunning]
    // Stop background tasks
    try {
      if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.ContinuousTask')) {
        backgroundTaskManager.stopBackgroundRunning(this.context).then(() => {
          hilog.info(0x0000, TAG, '%{public}s', 'Operation stopBackgroundRunning succeeded');
        }).catch((error: BusinessError) => {
          hilog.error(0x0000, TAG, '%{public}s',
            `Operation stopBackgroundRunning failed. code is ${error.code} message is ${error.message}`);
        });
      }
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s',
        `Operation stopBackgroundRunning failed. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }
    // [End stopBackgroundRunning]
  }

  // [EndExclude startContinuousRunningTask]
  // Internal method to manage background tasks
  private startContinuousRunningTask() {
    // Configure WantAgent for background operation
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [
        {
          bundleName: 'com.example.mapliveviewsample',
          abilityName: 'EntryAbility'
        }
      ],
      actionType: wantAgent.OperationType.START_ABILITY,
      requestCode: 0,
      actionFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };

    try {
      // Acquire WantAgent for background operations
      wantAgent.getWantAgent(wantAgentInfo).then((wantAgentObj: WantAgent) => {
        try {
          hilog.info(0x0000, TAG, '%{public}s', 'Operation startBackgroundRunning begin.');
          // Required background resource types
          const list: string[] = ['location'];
          // Request background running permission
          if (canIUse('SystemCapability.ResourceSchedule.BackgroundTaskManager.ContinuousTask')) {
            backgroundTaskManager.startBackgroundRunning(this.context, list, wantAgentObj).then(() => {
              hilog.info(0x0000, TAG, '%{public}s', 'Operation startBackgroundRunning succeeded.');
            }).catch((error: BusinessError) => {
              hilog.error(0x0000, TAG, '%{public}s',
                `Failed to Operation startBackgroundRunning. code is ${error.code} message is ${error.message}`);
            });
          }
        } catch (error) {
          hilog.error(0x0000, TAG, '%{public}s',
            `Failed to Operation startBackgroundRunning. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
        }
      });
    } catch (error) {
      hilog.error(0x0000, TAG, '%{public}s',
        `Failed to Operation getWantAgent. code is ${(error as BusinessError).code} message is ${(error as BusinessError).message}`);
    }
  }

  // [End startContinuousRunningTask]
}