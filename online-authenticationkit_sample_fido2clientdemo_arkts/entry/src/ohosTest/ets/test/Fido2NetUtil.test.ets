import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import { Fido2NetUtil } from '../../../main/ets/server/Fido2NetUtil';

export default function Fido2NetUtilTest() {
  describe('Fido2NetUtilTest', () => {
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
    it('connectFidoServer', 0, async () => {
      let name: string = 'Alice';
      let displayName: string = '123456';
      let request = Fido2NetUtil.getRegRequest(name, displayName);
      let reg: string = await Fido2NetUtil.connectFidoServer(Fido2NetUtil.url + Fido2NetUtil.regChallengeReq, JSON.stringify(request));

      expect(reg).not().assertEqual('');
    })

    it('getRegRequest', 0, async () => {
      let name: string = 'Alice';
      let displayName: string = '123456';
      let request = Fido2NetUtil.getRegRequest(name, displayName);

      expect(request.username).not().assertEqual('');
      expect(request.displayName).not().assertEqual('');
      expect(request.fido2CredentialCreationOptions).not().assertEqual('');
    })
  })
}