/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
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

import { ILiveInfoDataModel } from '../model/LiveDataModel';

export const LiveData: Array<ILiveInfoDataModel> = [
  {
    uri: $rawfile('video1.mp4'),
    name: $r('app.string.first_author'),
    peopleNum: '520'
  },
  {
    uri: $rawfile('video2.mp4'),
    name: $r('app.string.two_author'),
    peopleNum: '360'
  },
  {
    uri: $rawfile('video3.mp4'),
    name: $r('app.string.three_author'),
    peopleNum: '777'
  }
];