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

import { avSession } from '@kit.AVSessionKit';
import Constants from '../common/constants/Constants';

/**
 * Media resource constant.
 */
export default class MediaData {
  queueItemDescFirst: avSession.AVMediaDescription = {
    assetId: '001',
    title: 'First music',
    subtitle: 'music_sub_name',
    description: 'music_description',
    mediaImage: 'http://www.xxx.com',
    extras: {
      'extras': 'any'
    }
  };
  queueItemFirst: avSession.AVQueueItem = {
    itemId: 0,
    description: this.queueItemDescFirst
  };
  queueItemDescSecond: avSession.AVMediaDescription = {
    assetId: '002',
    title: 'Second music',
    subtitle: 'music_sub_name',
    description: 'music_description',
    mediaImage: 'http://www.xxx.com',
    extras: {
      'extras': 'any'
    }
  };
  queueItemSecond: avSession.AVQueueItem = {
    itemId: 1,
    description: this.queueItemDescSecond
  };
  queueItemDescThird: avSession.AVMediaDescription = {
    assetId: '003',
    title: 'Third music',
    subtitle: 'music_sub_name',
    description: 'music_description',
    mediaImage: 'http://www.xxx.com',
    extras: {
      'extras': 'any'
    }
  };
  queueItemThird: avSession.AVQueueItem = {
    itemId: 2,
    description: this.queueItemDescThird
  };
  avMetadataFirst: avSession.AVMetadata = {
    assetId: '0',
    title: this.queueItemDescFirst.title,
    artist: 'First artist',
    displayTags: avSession.DisplayTag.TAG_AUDIO_VIVID,
    duration: Constants.MUSIC_DURATION,
    avQueueName: Constants.ENTITY_ID_FIRST_PLAY_LIST,
    avQueueId: Constants.ENTITY_ID_FIRST_PLAY_LIST,
    avQueueImage: 'first.png',
    // For video session.
    skipIntervals: avSession.SkipIntervals.SECONDS_30
  };
  avMetadataSecond: avSession.AVMetadata = {
    assetId: '1',
    title: this.queueItemDescSecond.title,
    artist: 'Second artist',
    duration: Constants.MUSIC_DURATION,
    avQueueName: 'SecondPlayList',
    avQueueId: 'SecondPlayList',
    avQueueImage: 'second.png'
  };
  avMetadataThird: avSession.AVMetadata = {
    assetId: '2',
    title: this.queueItemDescThird.title,
    artist: 'Third artist',
    duration: Constants.MUSIC_DURATION,
    avQueueName: 'ThirdPlayList',
    avQueueId: 'ThirdPlayList',
    avQueueImage: 'third.png'
  };
  avMetadataList: Array<avSession.AVMetadata> = [this.avMetadataFirst, this.avMetadataSecond, this.avMetadataThird];
  static loopModeList = [
    $r('app.media.ic_public_order_play'),
    $r('app.media.ic_public_single_cycle'),
    $r('app.media.ic_public_list_cycle'),
    $r('app.media.ic_public_random')
  ];
}