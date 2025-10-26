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
* | No.  | API                | 功能说明                                                     |
* | :--- | :------------------| ------------------------------------------------------------|
* | 1    | assertClose        | Test whether the approximation between actualvalue and expectvalue(0) is expectValue(1). |
* | 2    | assertContain      | Test for inclusion of expectvalue in actualvalue.                       |
* | 3    | assertEqual        | Test whether actualvalue equals expectvalue[0].                      |
* | 4    | assertFail         | Throw an error.                                               |
* | 5    | assertFalse        | Checks whether actualvalue is false.                                 |
* | 6    | assertTrue         | Checks whether actualvalue is true.                                  |
* | 7    | assertInstanceOf   | Test whether actualvalue is expectvalue type.                       |
* | 8    | assertLarger       | Test whether actualvalue is greater than expectvalue.                         |
* | 9    | assertLess         | Test whether actualvalue is less than expectvalue.                         |
* | 10   | assertNull         | Checks whether actualvalue is null.                                  |
* | 11   | assertThrowError   | Test whether the Error content thrown by actualvalue is expectValue.              |
* | 12   | assertUndefined    | Verify that actualvalue is undefined.                            |
* | 13   | assertNaN          | @since1.0.4 Verify that actualvalue is a NaN.                       |
* | 14   | assertNegUnlimited | @since1.0.4 Tests whether actualvalue is equal to Number.NEGATIVE_INFINITY           |
* | 15   | assertPosUnlimited | @since1.0.4 Verify that actualvalue is equal to Number.POSITIVE_INFINITY            |
* | 16   | assertDeepEquals   | @since1.0.4 Test whether actualvalue and expectvalue(0) are the same object象               |
* | 17   | assertPromiseIsPending | @since1.0.4 Determine if the promise is in the Pending state.                         |
* | 18   | assertPromiseIsRejected | @since1.0.4 Check whether the promise is in the Rejected state.                       |
* | 19   | assertPromiseIsRejectedWith | @since1.0.4 Determines whether the promise is in the Rejected state and compares the result value of the execution.|
* | 20   | assertPromiseIsRejectedWithError | @since1.0.4 Determine whether the promise is in the Rejected state and has an exception, and compare the type of the exception with the message value.                   |
* | 21   | assertPromiseIsResolved | @since1.0.4 Determine whether the promise is in Resolved state.                       |
* | 22   | assertPromiseIsResolvedWith | @since1.0.4 Determine if the promise is in Resolved state and compare the result value of the execution.|
* | 23   | not                | @since1.0.4 The inverse of assertions supports all of the above assertion features                                 |
*
 */

import { describe, it, expect, TestType } from '@ohos/hypium';

export default function assertExampleTest() {
  describe('assertExampleTest', () => {

    /**
     * @tc.number:basicExampleTest_001
     * @tc.name: basicExampleTest
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Test whether the approximation between actualvalue and expectvalue(0) is expectValue(1)
     * @tc.version since1.0.0
     */
    it('basicExampleTest_001', TestType.FUNCTION, () => {
      let a = 100;
      let b = 0.1;
      expect(a).assertClose(99, b);
    })

    /**
     * @tc.number:basicExampleTest_002
     * @tc.name: basicExampleTest_002
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Checks whether actualvalue is null
     * @tc.version since1.0.0
     */
    it('basicExampleTest_002', TestType.FUNCTION, () => {
      expect(null).assertNull(); // true
    })

    /**
     * @tc.number:basicExampleTest_003
     * @tc.name: basicExampleTest_003
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Verify that 'abc' contains 'a'
     * @tc.version since1.0.0
     */
    it('basicExampleTest_003', TestType.FUNCTION, () => {
      let a = "abc";
      let b = "a";
      expect(a).assertContain(b);
    })

    /**
     * @tc.number:basicExampleTest_04
     * @tc.name: basicExampleTest_04
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Throw an error
     * @tc.version since1.0.0
     */
    it('basicExampleTest_04', TestType.FUNCTION, () => {
      expect().not().assertFail(); // 默认用例失败，使用not pass 用例
    })


    /**
     * @tc.number:basicExampleTest_05
     * @tc.name: basicExampleTest_05
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Checks whether actualvalue is false.
     * @tc.version since1.0.0
     */
    it('basicExampleTest_05', TestType.FUNCTION, () => {
      expect(false).assertFalse();
    })

    /**
     * @tc.number:basicExampleTest_06
     * @tc.name: basicExampleTest_06
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Verify that 10 is of type Number
     * @tc.version since1.0.0
     */
    it('basicExampleTest_06', TestType.FUNCTION, () => {
      expect(10).assertInstanceOf("Number");
    })

    /**
     * @tc.number:basicExampleTest_07
     * @tc.name: basicExampleTest_07
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Check if 5 is greater than 4
     * @tc.version since1.0.0
     */
    it('basicExampleTest_07', TestType.FUNCTION, () => {
      expect(5).assertLarger(4);
    })

    /**
     * @tc.number:basicExampleTest_08
     * @tc.name: basicExampleTest_08
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Check if 1 is less than 2
     * @tc.version since1.0.0
     */
    it('basicExampleTest_08', TestType.FUNCTION, () => {
      expect(1).assertLess(2);
    })

    /**
     * @tc.number:basicExampleTest_09
     * @tc.name: basicExampleTest_09
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Check if undefined is undefined
     * @tc.version since1.0.0
     */
    it('basicExampleTest_09', TestType.FUNCTION, () => {
      expect(undefined).assertUndefined();
    })

    /**
     * @tc.number:basicExampleTest_010
     * @tc.name: basicExampleTest_010
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Check whether the Error content raised by the testThro method is "test"
     * @tc.version since1.0.0
     */
    it('basicExampleTest_010', TestType.FUNCTION, () => {
      expect(testThro).assertThrowError("test");
    });

    /**
     * @tc.number:basicExampleTest_011
     * @tc.name: basicExampleTest_011
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Checks whether actualvalue is true
     * @tc.version since1.0.0
     */
    it('basicExampleTest_011', TestType.FUNCTION, () => {
      expect(true).assertTrue();
    });

    /**
     * @tc.number:basicExampleTest_012
     * @tc.name: basicExampleTest_012
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Check whether "test1" is equal to "test1"
     * @tc.version since1.0.0
     */
    it('basicExampleTest_012', TestType.FUNCTION, () => {
      expect("test1").assertEqual("test1");
    });

    /**
     * @tc.number:basicExampleTest_013
     * @tc.name: basicExampleTest_013
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Determine if the promise is in the Pending state
     * @tc.version since1.0.4
     */
    it('basicExampleTest_013', TestType.FUNCTION, () => {
      let p = new Promise<void>(() => {
      });
      expect(p).assertPromiseIsPending();
    });

    /**
     * @tc.number:basicExampleTest_014
     * @tc.name: basicExampleTest_014
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Check whether the promise is in the Rejected state
     * @tc.version since1.0.4
     */
    it('basicExampleTest_014', TestType.FUNCTION, () => {
      let info: PromiseInfo = {
        res: "no"
      }
      let p = Promise.reject<string>(info);
      expect(p).assertPromiseIsRejected();
    });

    /**
     * @tc.number:basicExampleTest_015
     * @tc.name: basicExampleTest_015
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Determines whether the promise is in the Rejected state and compares the result value of the execution
     * @tc.version since1.0.4
     */
    it("basicExampleTest_015", TestType.FUNCTION, () => {
      let info: PromiseInfo = {
        res: "reject value"
      }
      let p = Promise.reject(info);
      expect(p).assertPromiseIsRejectedWith(info);
    })

    /**
     * @tc.number:basicExampleTest_016
     * @tc.name: basicExampleTest_016
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Determine whether the promise is in the Rejected state and has an exception, and compare the type of the exception with the message value
     * @tc.version since1.0.4
     */
    it('basicExampleTest_016', TestType.FUNCTION, () => {
      let p1 = Promise.reject(new Error('number'));
      expect(p1).assertPromiseIsRejectedWithError(Error);
    });

    /**
     * @tc.number:basicExampleTest_017
     * @tc.name: basicExampleTest_017
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Determine whether the promise is in Resolved state
     * @tc.version since1.0.4
     */
    it('basicExampleTest_017', TestType.FUNCTION, () => {
      let info: PromiseInfo = {
        res: "result value"
      }
      let p = Promise.resolve(info);
      expect(p).assertPromiseIsResolved();
    });


    /**
     * @tc.number:basicExampleTest_018
     * @tc.name: basicExampleTest_018
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Determine if the promise is in Resolved state and compare the result value of the execution
     * @tc.version since1.0.4
     */
    it('basicExampleTest_018', TestType.FUNCTION, () => {
      let info: PromiseInfo = {
        res: "result value"
      }
      let p = Promise.resolve(info);
      expect(p).assertPromiseIsResolvedWith(info);
    });

    /**
     * @tc.number:basicExampleTest_019
     * @tc.name: basicExampleTest_019
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Verify that actualvalue is a NAN
     * @tc.version since1.0.4
     */
    it('basicExampleTest_019', TestType.FUNCTION, () => {
      expect(Number.NaN).assertNaN(); // true
    })

    /**
     * @tc.number:basicExampleTest_020
     * @tc.name: basicExampleTest_020
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Tests whether actualvalue is equal to Number.NEGATIVE_INFINITY
     * @tc.version since1.0.4
     */
    it('basicExampleTest_020', TestType.FUNCTION, () => {
      expect(Number.NEGATIVE_INFINITY).assertNegUnlimited(); // true
    })

    /**
     * @tc.number:basicExampleTest_021
     * @tc.name: basicExampleTest_021
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Verify that actualvalue is equal to Number.POSITIVE_INFINITY
     * @tc.version since1.0.4
     */
    it('basicExampleTest_021', TestType.FUNCTION, () => {
      expect(Number.POSITIVE_INFINITY).assertPosUnlimited(); // true
    })

    /**
     * @tc.number:basicExampleTest_022
     * @tc.name: basicExampleTest_022
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Test whether actualvalue is greater than or equal to EXPECTalValue
     * @tc.version since1.0.4
     */
    it('basicExampleTest_022', TestType.FUNCTION, () => {
      expect(1).assertLargerOrEqual(1);
    })

    /**
     * @tc.number:basicExampleTest_023
     * @tc.name: basicExampleTest_023
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Test whether actualvalue is less than or equal to expectvalue
     * @tc.version since1.0.4
     */
    it('basicExampleTest_023', TestType.FUNCTION, () => {
      expect(1).assertLessOrEqual(2);
    })

    /**
     * @tc.number:basicExampleTest_024
     * @tc.name: basicExampleTest_024
     * @tc.type: 0 || TestType.FUNCTION || Size.SMALLTEST || Level.LEVEL0
     * @tc.desc: Checks whether object a and object b have the same object properties
     * @tc.version since1.0.4
     */
    it("basicExampleTest_024", TestType.FUNCTION, () => {
      const a: SampleTest = {
        x: 1
      };
      const b: SampleTest = {
        x: 1
      };
      expect(a).assertDeepEquals(b);
    })
  });
}

function testThro() {
  throw new Error("test");
}

interface SampleTest {
  x: number;
}

interface PromiseInfo {
  res: string;
}