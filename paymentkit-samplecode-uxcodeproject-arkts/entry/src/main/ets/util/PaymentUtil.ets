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

import { CustPayType } from "../data/CustPayType";
import { PaymentType } from "../data/PaymentType";

/**
 * Is the payment type a new card
 * @param paymentType payment type
 * @returns Is the payment type a new card
 */
export const isNewCardPaymentType = (paymentType: PaymentType): boolean => {
  if (!paymentType) {
    return false;
  }
  return paymentType.custPayType === CustPayType.NewBankCard;
};

/**
 * Get the icon's rounded corner value
 * @param length Corner Radius
 * @returns Icon corner radius value
 */
export const getBorderRadius = (length: number): number => {
  // The rounded corner value for the square icon is: 14 / 54 * Icon side length
  return 7 / 27 * length;
}