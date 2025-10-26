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

import { describe, it, expect, TestType } from '@ohos/hypium';

export default function paramExampleTest() {
  describe('paramExampleTest', () => {

    /**
     * @tc.number:paramExampleTest_001
     * @tc.name: testDataDriverAsync
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Checks the delegater.startability interface to open the specified Ability object
     * @tc.done Asynchronous use cases execute completion callback functions
     * @tc.suitParam Using the data passing function to pass parameter objects to the test suite, the suitParam object reference passes data objects
     */
    it('testDataDriverAsync', TestType.FUNCTION, async (done: Function, suitParam: SuitParam) => {
      let suitParam1 = suitParam.suiteParams1;
      let suitParam2 = suitParam.suiteParams2;
      expect(suitParam1).assertEqual("suiteParams001");
      expect(suitParam2).assertEqual("suiteParams002");
      done();
    });

    /**
     * @tc.number:paramExampleTest_002
     * @tc.name: testDataDriverParam
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Checks the delegater.startability interface to open the specified Ability object
     * @tc.done Asynchronous use cases execute completion callback functions
     * @tc.suitParam Using the data passing function to pass parameter objects to the test case, the suitParam object reference passes data objects
     */
    it('testDataDriverParam', TestType.FUNCTION, async (done: Function, suitParam: SuitParam) => {
      let suitParam1 = suitParam.suiteParams1;
      let suitParam2 = suitParam.suiteParams2;
      let spParam1 = suitParam.ts1;
      let spParam2 = suitParam.ts2;
      expect(suitParam1).assertEqual("suiteParams001");
      expect(suitParam2).assertEqual("suiteParams002");
      expect(spParam1).assertEqual("ts1");
      expect(spParam2).assertEqual("ts2");
      done();
    });
  });
}

interface SuitParam {
  suiteParams1: string,
  suiteParams2: string,
  ts1: string,
  ts2: string,
}