import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import fido2 from 'libentry.so';
import { JSON } from '@kit.ArkTS';
import { BusinessError } from '@kit.BasicServicesKit';
import { fido } from '@kit.OnlineAuthenticationKit'
export default function ConnectServiceTest() {
  describe('ConnectServiceTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(() => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
    })
    beforeEach(() => {
      // Presets an action, which is performed before each unit test case starts.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: preset action function.
    })
    afterEach(() => {
      // Presets a clear action, which is performed after each unit test case ends.
      // The number of execution times is the same as the number of test cases defined by **it**.
      // This API supports only one parameter: clear action function.
    })
    afterAll(() => {
      // Presets a clear action, which is performed after all test cases of the test suite end.
      // This API supports only one parameter: clear action function.
    })
    /**
     * @tc.number HCTS_Module_Install_GetFetchModulesTaskId
     * @tc.name HCTS_Module_Install_GetFetchModulesTaskId
     * @tc.desc config -> active
     * @tc.size MediumTest
     * @tc.type Function
     * @tc.level Level0
     */
    it('HCTS_FIDO2_ConnectService', 0, () => {
      // console.info("fido2: ", JSON.stringify(fido2));
      let ret: number = fido2.HCTS_ConnectService();
      // let ret0: number = fido2.add(2, 3);
      expect(ret).assertEqual(0);


    })

  })
}