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

import { JSON } from '@kit.ArkTS';
import { CommonConstants as Const } from 'common';
import { getAchievementDoneIndex } from '../model/AchievementModel';
import { TaskInfoDialogParams } from './dialog/TaskInfoDialogParams';
import PreferencesUtils from 'common/src/main/ets/utils/PreferencesUtils';
import { openAchievementCustomDialog } from '../views/dialog/AchievementDialog';

/**
 * Global achievement information storage.
 */
@Observed
export class AchievementStore {
  public maxConsecutiveDays: number;
  public currentConsecutiveDays: number;
  public currentDayStatus: boolean;

  constructor(maxConsecutiveDays: number, currentConsecutiveDays: number, currentDayStatus: boolean) {
    this.maxConsecutiveDays = maxConsecutiveDays;
    this.currentConsecutiveDays = currentConsecutiveDays;
    this.currentDayStatus = currentDayStatus;
  }
}

/**
 * Initialize global achievement information.
 */
export async function initAchievementStore() {
  const maxConsecutiveDays = Number(await PreferencesUtils.getPreference(Const.MAX_CONSECUTIVE_DAYS));
  const currentConsecutiveDays = Number(await PreferencesUtils.getPreference(Const.CURRENT_CONSECUTIVE_DAYS));
  const currentDayStatusStr: string = await PreferencesUtils.getPreference(Const.CURRENT_DAY_STATUS);
  const currentDayStatus = JSON.parse(currentDayStatusStr) as boolean;
  return new AchievementStore(maxConsecutiveDays, currentConsecutiveDays, currentDayStatus)
}

/**
 * Update the information when the achievement information changes.
 * @param { TaskInfoDialogParams } params Task info for clock custom dialog parameters.
 */
export async function updateAchievementStore(params: TaskInfoDialogParams) {
  //Judge whether all tasks are completed that day, and return if not.
  const dayInfo = params.homeStore.weekList[params.homeStore.selectedDay];
  if (dayInfo.finTaskNum < dayInfo.targetTaskNum || params.achievementStore.currentDayStatus) {
    return;
  }

  // If all tasks have been completed that day, the number of consecutive days of completion is added to the user preferences.
  params.achievementStore.currentConsecutiveDays += 1;
  await PreferencesUtils.putPreference(Const.CURRENT_CONSECUTIVE_DAYS,
    String(params.achievementStore.currentConsecutiveDays));
  params.achievementStore.currentDayStatus = true;
  await PreferencesUtils.putPreference(Const.CURRENT_DAY_STATUS, String(params.achievementStore.currentDayStatus));

  // Determine whether the current number of consecutive days exceeds the maximum number of consecutive days.
  if (params.achievementStore.currentConsecutiveDays > params.achievementStore.maxConsecutiveDays) {
    // If it exceeds, synchronize the global storage and user preference content to update.
    params.achievementStore.maxConsecutiveDays = params.achievementStore.currentConsecutiveDays;
    await PreferencesUtils.putPreference(Const.MAX_CONSECUTIVE_DAYS,
      String(params.achievementStore.maxConsecutiveDays));
    // Get the achievement for a specified number of days, and if so, open a pop-up window to display the achievement animation.
    const achievementDoneIndex = getAchievementDoneIndex(params.achievementStore.maxConsecutiveDays);
    if (achievementDoneIndex !== -1) {
      openAchievementCustomDialog(params.uIContext, achievementDoneIndex);
    }
  }
}