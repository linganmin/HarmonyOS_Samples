/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
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

import { FunctionType } from '@ohos/commons/Index';

export class FormViewData {
  static readonly FUNCTIONS: Array<FunctionType> = [
    {
      id: 1,
      icon: $r('app.media.icon_drive'),
      desc: $r('app.string.drive_form')
    },
    {
      id: 2,
      icon: $r('app.media.icon_Metro'),
      desc: $r('app.string.metro_form')
    },
    {
      id: 3,
      icon: $r('app.media.icon_taxi'),
      desc: $r('app.string.taxi_form')
    },
    {
      id: 4,
      icon: $r('app.media.icon_bus'),
      desc: $r('app.string.bus_form')
    },
    {
      id: 5,
      icon: $r('app.media.icon_hotel'),
      desc: $r('app.string.hotel_form')
    }
  ];
}