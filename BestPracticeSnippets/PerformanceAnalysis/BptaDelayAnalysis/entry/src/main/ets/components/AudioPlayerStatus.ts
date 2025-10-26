/*
* Copyright (C) 2025 Huawei Device Co., Ltd.
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

// src/components/AudioPlayerStatus.ts

export enum AudioPlayerStatus {
  IDLE = 'idle',

  PREPARING = 'preparing',

  /** prepare ready */
  READY = 'ready',

  PLAYING = 'playing',

  PAUSED = 'paused',

  /** play completed */
  COMPLETED = 'completed',

  ERROR = 'error',

  BUFFERING = 'buffering',

  /** jump to progress */
  SEEKING = 'seeking'
}

// check utils
export class AudioStatusUtils {
  static isPlaying(status: AudioPlayerStatus): boolean {
    return status === AudioPlayerStatus.PLAYING;
  }

  static canResume(status: AudioPlayerStatus): boolean {
    return [
      AudioPlayerStatus.PAUSED,
      AudioPlayerStatus.READY,
      AudioPlayerStatus.COMPLETED
    ].includes(status);
  }

  static isActive(status: AudioPlayerStatus): boolean {
    return ![
      AudioPlayerStatus.IDLE,
      AudioPlayerStatus.ERROR
    ].includes(status);
  }
}