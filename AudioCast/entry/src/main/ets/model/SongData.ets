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

/**
 * Music information entity class.
 */
export class SongItem {
  /**
   * Music name.
   */
  title: string = '';
  /**
   * Music author name.
   */
  singer: string = '';
  /**
   * Music avatar information.
   */
  label: Resource = $r('app.string.EntryAbility_label');
  /**
   * Music file path information.
   */
  src: string = '';
  /**
   * PCM Music file path information now.
   */
  pcmSrc: string = '';
  /**
   * Lyric file path information.
   */
  lyric: string = '';
  /**
   * albumCoverUri information.
   */
  albumCoverUri: string = '';
  /**
   * Tone Quality list information.
   */
  toneQualityList: number[] = [];
}

export enum MusicPlayMode {
  ORDER = 0,
  SINGLE_CYCLE = 1,
  RANDOM = 3
}

export enum ToneQuality {
  SQ = 1,
  SPATIAL_AUDIO = 2,
  MASTER = 3,
}

export interface Controller {
  setPlaying(): void;
  setPause(): void;
  setStop(): void;
  seek(position: number): void;
}




