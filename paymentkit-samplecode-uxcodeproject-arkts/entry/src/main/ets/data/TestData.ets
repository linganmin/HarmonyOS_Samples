/*
 * Copyright (c) 2025 Huawei Device Co., Ltd.
 * Licensed under the Apache License,Version 2.0 (the "License");
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

import { PaymentType } from "./PaymentType";

export const paymentTypeList: PaymentType[] = [
  {
    payTypeSerialNo: '1',
    payTypeDesc: 'xx银行储蓄卡 (0606)',
    isAvailable: true,
    custPayType: 'BankFastPayment',
  },
  {
    payTypeSerialNo: '2',
    payTypeDesc: 'xx银行储蓄卡 (0909)',
    isAvailable: true,
    custPayType: 'BankFastPayment',
  }
];

export const paymentTypes3PayShow: PaymentType[] = [
  {
    payTypeSerialNo: '3',
    payTypeDesc: '云闪付',
    isAvailable: true,
    custPayType: 'CloudFlashPayment',
  },
  {
    payTypeSerialNo: '4',
    payTypeDesc: '微信支付',
    isAvailable: true,
    custPayType: 'WECHAT_MICROPAY',
  }
]