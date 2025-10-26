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

// src/model/ContinueModel.ts
import { AudioPlayerStatus } from "./AudioPlayerStatus";

export class ContinueModel {
  private static instance: ContinueModel;
  public data: AppData;

  private constructor() {
    this.data = {
      mainTabIndex: 0,
      audioPlaybackInfo: {
        status: AudioPlayerStatus.IDLE,
        currentTrackId: '',
        progress: 0
      },
      userPreferences: {
        darkMode: false,
        playbackSpeed: 1.0
      }
    };

    this.initFromStorage();
  }

  public static getInstance(): ContinueModel {
    if (!ContinueModel.instance) {
      ContinueModel.instance = new ContinueModel();
    }
    return ContinueModel.instance;
  }

  private initFromStorage(): void {
    try {
      const savedTabIndex: number = AppStorage.get('mainTabIndex');
      if (savedTabIndex !== undefined) {
        this.data.mainTabIndex = Number(savedTabIndex);
      }

      const darkMode: boolean = AppStorage.get('darkMode');
      if (darkMode !== undefined) {
        this.data.userPreferences.darkMode = Boolean(darkMode);
      }
    } catch (error) {
      console.error('Failed to init from storage:', error);
    }
  }

  public updateTabIndex(index: number): void {
    this.data.mainTabIndex = index;
    AppStorage.setOrCreate('mainTabIndex', index);
  }

  public updateAudioStatus(status: AudioPlayerStatus, trackId?: string): void {
    this.data.audioPlaybackInfo.status = status;
    if (trackId) {
      this.data.audioPlaybackInfo.currentTrackId = trackId;
    }
    AppStorage.setOrCreate('audioPlayerStatus', status);
  }

  public toggleDarkMode(): void {
    this.data.userPreferences.darkMode = !this.data.userPreferences.darkMode;
    AppStorage.setOrCreate('darkMode', this.data.userPreferences.darkMode);
  }
}

interface AppData {
  mainTabIndex: number;
  audioPlaybackInfo: {
    status: AudioPlayerStatus;
    currentTrackId: string;
    progress: number;
  };
  userPreferences: {
    darkMode: boolean;
    playbackSpeed: number;
  };
}