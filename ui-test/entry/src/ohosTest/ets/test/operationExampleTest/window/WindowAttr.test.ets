/*
* Copyright (c) 2023 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License")
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
/*

* >查找控件属性
* | No. | API                                | Function description.                       |
* |-----|------------------------------------|----------------------------|
* | 1   | getBundleName():Promise<string>    | Get the bundleName.                     |
* | 2   | getBounds():Promise<Rect>          | Gets the area of window.            |
* | 3   | getTitle():Promise<string>         | Gets the specified window title.                   |
* | 4   | getWindowMode():Promise<WindowMode> | Gets the window type.                 |
* | 5   | isFocused():Promise<boolean>       | Goods window status.                |
* | 6   | isActived():Promise<boolean>       | Gets whether the current window is active.                |
*
 */

import { describe, beforeAll, it, expect, TestType } from '@ohos/hypium';
import { abilityDelegatorRegistry, Driver } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';
import Logger from '../../../util/Logger';

const delegator = abilityDelegatorRegistry.getAbilityDelegator();
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;
const WAIT_UI_READYMS = 1000;
const TAG = "WindowAttr_Test";
const BUNDLE = "WindowAttr_";

export default function WindowAttr() {
  describe('WindowAttr',  () => {
    beforeAll(async () => {
      let want: Want = {
        bundleName : bundleName,
        abilityName : "EntryAbility"
      }
      await delegator.startAbility(want);
    })

    /**
     * @tc.number:WindowAttr_001
     * @tc.name: WindowAttr_Test_001
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Sets the size and orientation test specified by window.
     */
    it("WindowAttr_Test_001", TestType.FUNCTION, async (done: Function) => {
      Logger.info(TAG, BUNDLE + "Test_001 start");
      let driver = Driver.create();
      await driver.delayMs(WAIT_UI_READYMS);
      let window = await driver.findWindow({bundleName: bundleName});
      let name = await window.getBundleName();
      expect(name == bundleName).assertTrue();
      Logger.info(TAG, BUNDLE + "Test_001 end");
      done();
    })
  })
}