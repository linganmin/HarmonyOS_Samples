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
* | 1   | id(i:string):On                    | Specifies the control id.                    |
* | 2   | text(t:string, p?:MatchPattern):On | Specifies the control text to specify the matching mode.            |
* | 3   | type(t:string):On                 | Specifies the control type.                    |
* | 4   | enabled(e:bool):On                 | Specifies the control enablement status.                  |
* | 5   | clickable(c:bool):On               | Specifies the clickable state of the control.                 |
* | 6   | longClickable(l:bool):On           | Specifies the long-press state of the control.                |
* | 7   | focused(f:bool):On                 | Specifies the focus state of the control.                 |
* | 8   | scrollable(s:bool):On              | Specifies the slippable state of the control.                |
* | 9   | selected(s:bool):On                | Specifies the selected status of the control.                 |
* | 10  | checked(c:bool):On                 | Specifies control selection status.                  |
* | 11  | checkable(c:bool):On               | Specifies the selectable state of the control.                 |
* | 12  | isBefore(b:On):On                  | ** Relative positioning **, limiting the target control to be before the specified feature control. |
* | 13  | isAfter(b:On):On                   | ** Relative positioning **, limiting the target control to be before the specified feature control. |
* >Matching pattern
* EQUALS = 0,
* CONTAINS = 1,
* STARTS_WITH = 2,
* ENDS_WITH = 3
*
 */

import { describe, it, expect, beforeAll, TestType } from '@ohos/hypium';
import { Driver, ON, MatchPattern, abilityDelegatorRegistry } from '@kit.TestKit';
import { Want } from '@kit.AbilityKit';

const delegator = abilityDelegatorRegistry.getAbilityDelegator();
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;
const DELAYMS = 1000;
const arr: number[] = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9];

export default function findExampleTest() {
  describe('findExampleTest', () => {
    beforeAll(async () => {
      let want: Want = {
        bundleName: bundleName,
        abilityName: "EntryAbility"
      }
      await delegator.startAbility(want);
    })

    /**
     * @tc.number:findExampleTest_001
     * @tc.name: findComponent_On_ID
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Use ON.id to get individual components.
     */
    it("findComponent_On_ID", TestType.FUNCTION, async (done: Function) => {
      let dr = await Driver.create();
      await dr.delayMs(DELAYMS);
      let text = await dr.findComponent(ON.id("idTest"));
      expect(dr).not().assertNull();
      expect(await text.getId()).assertEqual("idTest");
      done();
    })

    /**
     * @tc.number:findExampleTest_002
     * @tc.name: findComponents_On_ID
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Get multiple components using ON.id.
     */
    it("findComponents_On_ID", TestType.FUNCTION, async (done: Function) => {
      let dr = await Driver.create();
      await dr.delayMs(DELAYMS);
      let textArr = await dr.findComponents(ON.id("scroll_item"));
      expect(dr).not().assertNull();
      for (let index = 0; index < textArr.length; index++) {
        const element = textArr[index];
        expect(await element.getText() === arr[index].toString()).assertTrue();
      }
      done();
    })

    /**
     * @tc.number:findExampleTest_003
     * @tc.name: findComponents_On_isBefore
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Use ON.isBefore to get individual components.
     */
    it("findComponents_On_isBefore", TestType.FUNCTION, async (done: Function) => {
      let dr = await Driver.create();
      expect(dr).not().assertNull();
      let radio = await dr.findComponent(ON.type("Radio").isBefore(ON.id("radio_test1")));
      expect(await radio.getType()).assertEqual("Radio");
      expect(await radio.getId()).assertEqual("radio_test");
      done();
    })

    /**
     * @tc.number:findExampleTest_004
     * @tc.name: findComponents_On_isBefore_1
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Use ON.isAfter to get individual components.
     */
    it("findComponents_On_isBefore_1", TestType.FUNCTION, async (done: Function) => {
      let dr = await Driver.create();
      expect(dr).not().assertNull();
      let radio = await dr.findComponent(ON.type("Radio").isAfter(ON.id("radio_test")));
      expect(await radio.getType()).assertEqual("Radio");
      expect(await radio.getId()).assertEqual("radio_test1");
      done();
    })


    /**
     * @tc.number:findExampleTest_005
     * @tc.name: testMatchPattern
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Get control objects using different matching patterns.
     */
    it('testMatchPattern', TestType.FUNCTION, async () => {
      let driver = Driver.create();
      await driver.delayMs(DELAYMS);
      let Button1 = await driver.findComponent(ON.text('unit_jsunit', MatchPattern.EQUALS));
      expect(await Button1.getText()).assertEqual("unit_jsunit");
      let Button2 = await driver.findComponent(ON.text('unit', MatchPattern.STARTS_WITH));
      expect(await Button2.getText()).assertEqual("unit_jsunit");
    })

    /**
     * @tc.number:findExampleTest_006
     * @tc.name: findComponents_scrollSearch
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Use ScrollSearch to retrieve individual components.
     */
    it("findComponents_scrollSearch", TestType.FUNCTION, async (done: Function) => {
      let dr = await Driver.create();
      await dr.delayMs(DELAYMS);
      let scrollBar = await dr.findComponent(ON.type('Scroll'));
      await dr.delayMs(DELAYMS);
      let button = await scrollBar.scrollSearch(ON.text('5'));
      await dr.delayMs(DELAYMS);
      expect(await button.getText()).assertEqual("5");
      done();
    })
  })
}