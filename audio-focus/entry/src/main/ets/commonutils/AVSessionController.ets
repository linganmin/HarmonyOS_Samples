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

import { wantAgent, common, WantAgent } from '@kit.AbilityKit';
import { avSession } from '@kit.AVSessionKit';
import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import Logger from './Logger';
import { MediaController } from './MediaController'

const TAG = 'AVSessionController logInfo';

export class AVSessionController {
  context: common.UIAbilityContext = AppStorage.get('EntryAbilityContext') as common.UIAbilityContext;
  session?: avSession.AVSession;
  agent?: WantAgent;

  async setWantAgent(abilityName: string) {
    let wantAgentInfo: wantAgent.WantAgentInfo = {
      wants: [{ bundleName: "com.example.audiofocusdemo", abilityName: abilityName }],
      operationType: wantAgent.OperationType.START_ABILITIES,
      requestCode: 0,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    };
    try {
      this.agent = await wantAgent.getWantAgent(wantAgentInfo);
    } catch (error) {
      Logger.error(TAG, `getWantAgent fail. error message is ${error.message}`);
    }
  }

  async startContinuousTask() {
    let backgroundModeList: Array<string> = ["audioRecording", "audioPlayback", "voip"];
    try {
      await backgroundTaskManager.startBackgroundRunning(this.context, backgroundModeList, this.agent);
    } catch (error) {
      Logger.error(TAG, `startContinuousTask fail. error message is ${error.message}`);
    }
    Logger.info(TAG, 'startContinuousTask SUCCESS');
  }

  async stopContinuousTask() {
    try {
      await backgroundTaskManager.stopBackgroundRunning(this.context);
    } catch (error) {
      Logger.error(TAG, `stopBackgroundRunning fail. error message is ${error.message}`);
    }
    Logger.info(TAG, 'stopContinuousTask SUCCESS');
  }

  async createAndActiveSession(
    metadata: avSession.AVMetadata, abilityName: string, sessionType: avSession.AVSessionType) {
    if (this.session) {
      Logger.info(TAG, 'avSession is exist.');
      return;
    }
    // Set the wantAgent
    await this.setWantAgent(abilityName);
    // Create an AVSession instance object
    try {
      this.session = await avSession.createAVSession(this.context, 'AVSessionDemo', sessionType);
      // Set up media data
      await this.session.setAVMetadata(metadata);
      // Set UIAbility to pull up after clicking
      await this.session.setLaunchAbility(this.agent);
      // Sets the initial state of media playback
      let playbackState: avSession.AVPlaybackState = {
        state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
        loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
      };
      await this.session.setAVPlaybackState(playbackState);
      // Activate AVSession
      await this.session.activate();
      Logger.info(TAG, 'createAndActiveSession SUCCESS');
    } catch (error) {
      Logger.error(TAG, `createAVSession fail. error message is ${error.message}`);
    }
  }

  async registerSessionListener(mediaController: MediaController) {
    try {
      if (!this.session) {
        Logger.info(TAG, 'registerSessionListener failed, avSession is null.');
        return;
      }
      this.session.on('play', async () => {
        Logger.info(TAG, `on play, do play task`);
        await mediaController.MediaPlay();
        let playbackState: avSession.AVPlaybackState = {
          state: avSession.PlaybackState.PLAYBACK_STATE_PLAY,
          loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
        };
        await this.session?.setAVPlaybackState(playbackState);
        AppStorage.setOrCreate('audioIsPlaying', true);
      });

      this.session?.on('pause', async () => {
        Logger.info(TAG, `on pause, do pause task`);
        await mediaController.MediaPause();
        let playbackState: avSession.AVPlaybackState = {
          state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
          loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
        };
        await this.session?.setAVPlaybackState(playbackState);
        AppStorage.setOrCreate('audioIsPlaying', false);
      });

      this.session?.on('stop', async () => {
        Logger.info(TAG, `on stop , do stop task`);
        await mediaController.MediaStop();
        let playbackState: avSession.AVPlaybackState = {
          state: avSession.PlaybackState.PLAYBACK_STATE_PAUSE,
          loopMode: avSession.LoopMode.LOOP_MODE_SINGLE
        };
        await this.session?.setAVPlaybackState(playbackState);
        AppStorage.setOrCreate('audioIsPlaying', false);
      });
      Logger.info(TAG, 'registerSessionListener SUCCESS');
    } catch (error) {
      Logger.error(TAG, `registerSessionListener fail. code is ${error.code}, error message is ${error.message}`);
    }
  }

  async avSessionRelease() {
    try {
      if (this.session) {
        this.session.off('play');
        this.session.off('pause');
        this.session.off('stop');
        await this.session.destroy();
      }
      Logger.info(TAG, 'avSessionRelease SUCCESS');
    } catch (error) {
      Logger.error(TAG, `avSessionRelease fail. code is ${error.code}, error message is ${error.message}`);
    }
  }
}