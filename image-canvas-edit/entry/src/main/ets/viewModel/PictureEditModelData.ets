/*
 *  Copyright (c) 2025 Huawei Device Co., Ltd.
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

import { TranslateListType } from './PictureEditModel';

export const cropListData: TranslateListType[] = [
  {
    icon: 'aspect_ratio',
    title: $r('app.string.none'),
    color: '#FFF',
    selectColor: '#FF000000'
  },
  {
    icon: 'rectangle_ratio_1_to_1',
    title: '1:1',
    color: '#FFF',
    selectColor: '#FF000000'
  },
  {
    icon: 'rectangle_ratio_4_to_3',
    title: '4:3',
    color: '#FFF',
    selectColor: '#FF000000'
  },
  {
    icon: 'rectangle_ratio_16_to_9',
    title: '16:9',
    color: '#FFF',
    selectColor: '#FF000000'
  }
];

export const translateListData: TranslateListType[] = [
  {
    icon: 'sys.symbol.camera_panopor_horizontal',
    title: $r('app.string.horizontal'),
    color: '#FFF',
    selectColor: '#FF000000'
  },
  {
    icon: 'sys.symbol.camera_panover_vertical',
    title: $r('app.string.vertical'),
    color: '#FFF',
    selectColor: '#FF000000'
  },
];