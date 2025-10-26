/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

export const ENTRY_ABILITY = 'EntryAbility';

export enum FormCarAction {
  CALL = 'call',
  ROUTER = 'router',
}

export enum FormCardName {
  LYRICS = 'LyricsCard',
  CONTROL_2X2 = 'PlayControlCard2x2',
  CONTROL_2X4 = 'PlayControlCard2x4',
  RECOMMENDED_1X2 = 'RecommendedMusic1x2',
  RECOMMENDED_2X4 = 'RecommendedMusic2x4',
}

export enum PlayActionType {
  PAUSE = '0',
  PLAY = '1',
  PREVIOUS = '2',
  NEXT = '3',
}

export enum RouterType {
  PLAYER = '1',
  LYRICS = '2',
  PLAYLISTS = '3',
  COLLECTED = '4',
}

export enum CallMethod {
  REQUEST_UPDATE_CARD = 'requestUpdatePlayCard',
  PLAY_BY_ACTION = 'playByAction',
  COLLECT_ACTION = 'collectAction',
}

export enum CollectAction {
  COLLECTED = '1',
  UNCOLLECTED = '0',
}
