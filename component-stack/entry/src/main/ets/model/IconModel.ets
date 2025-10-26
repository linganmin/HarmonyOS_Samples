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

import { IconDataModel, ProductDataModel } from '../viewmodel/IconViewModel';

// Shortcut Icon Data.
export const ICON_DATA1: Array<IconDataModel> = [
  new IconDataModel(0, 2, $r('app.media.ic_device_matebook_filled'), $r('app.string.notebook')),
  new IconDataModel(1, 2, $r('app.media.ic_device_smartscreen_filled'), $r('app.string.smart_display')),
  new IconDataModel(2, 1, $r("app.media.ic_device_sound_x_filled"), $r('app.string.speaker_box')),
  new IconDataModel(3, 1, $r("app.media.ic_device_vr_glass_filled"), $r('app.string.VR_glasses')),
  new IconDataModel(4, 1, $r('app.media.ic_device_watch_filled'), $r('app.string.watch')),
  new IconDataModel(5, 1, $r('app.media.ic_public_devices_phone_filled'), $r('app.string.phone'))
];

// Shortcut Icon Data.
export const ICON_DATA2: Array<IconDataModel> = [
  new IconDataModel(0, 1, $r('app.media.ic_gallery_puzzle'), $r('app.string.saw_puzzle')),
  new IconDataModel(1, 1, $r('app.media.ic_public_car'), $r('app.string.cars')),
  new IconDataModel(2, 1, $r('app.media.ic_public_cards'), $r('app.string.purse')),
  new IconDataModel(3, 1, $r('app.media.ic_public_highlight'), $r('app.string.collect')),
  new IconDataModel(4, 1, $r('app.media.ic_contacts_birthday'), $r('app.string.birthday'))
];

// Offering List Data Source.
export const PRODUCT_DATA: Array<ProductDataModel> = [
  new ProductDataModel(0, $r('app.media.product00'), $r('app.string.product_title00'), $r('app.string.product_price00'), $r('app.string.product_insurance00')),
  new ProductDataModel(1, $r('app.media.product01'), $r('app.string.product_title01'), $r('app.string.product_price01'), $r('app.string.product_insurance01')),
  new ProductDataModel(2, $r('app.media.product02'), $r('app.string.product_title02'), $r('app.string.product_price02'), $r('app.string.product_insurance02')),
  new ProductDataModel(3, $r('app.media.product03'), $r('app.string.product_title03'), $r('app.string.product_price03'), $r('app.string.product_insurance03')),
  new ProductDataModel(4, $r('app.media.product04'), $r('app.string.product_title04'), $r('app.string.product_price04'), $r('app.string.product_insurance04')),
  new ProductDataModel(5, $r("app.media.product03"), $r('app.string.product_title03'), $r('app.string.product_price03'), $r('app.string.product_insurance05'))
];