/*
 *
 *  * Copyright (c) 2025 Huawei Device Co., Ltd.
 *  * Licensed under the Apache License, Version 2.0 (the "License");
 *  * you may not use this file except in compliance with the License.
 *  * You may obtain a copy of the License at
 *  *
 *  *     http://www.apache.org/licenses/LICENSE-2.0
 *  *
 *  * Unless required by applicable law or agreed to in writing, software
 *  * distributed under the License is distributed on an "AS IS" BASIS,
 *  * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  * See the License for the specific language governing permissions and
 *  * limitations under the License.
 *
 */

/**
 * achievement default information.
 */
export interface AchievementItem {
  level: number;
  name: string;
  iconOn: Resource;
  iconOff: Resource;
}

export const AchievementList: AchievementItem[] = [
  {
    level: 3,
    name: '3',
    iconOn: $r('app.media.ic_badge_3_on'),
    iconOff: $r('app.media.ic_badge_3_off')
  },
  {
    level: 7,
    name: '7',
    iconOn: $r('app.media.ic_badge_7_on'),
    iconOff: $r('app.media.ic_badge_7_off')
  },
  {
    level: 30,
    name: '30',
    iconOn: $r('app.media.ic_badge_30_on'),
    iconOff: $r('app.media.ic_badge_30_off')
  },
  {
    level: 50,
    name: '50',
    iconOn: $r('app.media.ic_badge_50_on'),
    iconOff: $r('app.media.ic_badge_50_off')
  },
  {
    level: 73,
    name: '73',
    iconOn: $r('app.media.ic_badge_73_on'),
    iconOff: $r('app.media.ic_badge_73_off')
  },
  {
    level: 99,
    name: '99',
    iconOn: $r('app.media.ic_badge_99_on'),
    iconOff: $r('app.media.ic_badge_99_off')
  }
]

/**
 * Gets the current maximum number of consecutive days to complete an achievement.
 * @param { number } maxConsecutiveDays The maximum number of consecutive days completed before the achievement.
 * @returns { number } If an achievement is achieved, the achievement index is returned, otherwise -1 is returned.
 */
export function getAchievementDoneIndex(maxConsecutiveDays: number): number {
  for (let index = 0; index < AchievementList.length; index++) {
    if (AchievementList[index].level === maxConsecutiveDays) {
      return index;
    }
  }
  return -1;
}