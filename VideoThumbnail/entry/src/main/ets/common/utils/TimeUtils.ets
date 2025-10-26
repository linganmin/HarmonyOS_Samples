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

const TIME_ONE = 60000;
const TIME_TWO = 1000;
const TIME_THREE = 10;

/**
 * Convert time into a universal format.
 * @param time Millisecond format time.
 * @returns: Universal format time string.
 */
export function timeConvert(time: number): string {
  let min: number = Math.floor(time / TIME_ONE);
  let second: number = Math.floor((time % TIME_ONE) / TIME_TWO);
  return `${min}:${(((time % TIME_ONE) / TIME_TWO) < TIME_THREE ? '0' : '') + second}`;
}