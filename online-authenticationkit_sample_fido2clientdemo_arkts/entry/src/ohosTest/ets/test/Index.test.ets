import { describe, beforeAll, beforeEach, afterEach, afterAll, it, expect } from '@ohos/hypium';
import fido2 from '@hms.security.fido2';
import common from '@ohos.app.ability.common';
import AbilityDelegatorRegistry from '@ohos.app.ability.abilityDelegatorRegistry';
import hilog from '@ohos.hilog';

let context: common.UIAbilityContext;
let registerOptions: fido2.CredentialCreationOptions;
let authenticateOptions: fido2.CredentialRequestOptions;
let tokenBinding: fido2.TokenBinding;

function generateRandomString(length: number): string {
  const characters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  let result: string = '';
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * characters.length));
  }
  return result;
}

export default function IndexTest() {
  describe('IndexTest', () => {
    // Defines a test suite. Two parameters are supported: test suite name and test suite function.
    beforeAll(async () => {
      // Presets an action, which is performed only once before all test cases of the test suite start.
      // This API supports only one parameter: preset action function.
      await AbilityDelegatorRegistry.getAbilityDelegator()
        .executeShellCommand('aa start -b cn.com.union.fidotest -a EntryAbility');
      context = AppStorage.get<common.UIAbilityContext>('TestAbilityContext') as common.UIAbilityContext;
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
     * @tc.number FIDO_HctsServiceAbility_0104
     * @tc.name getClientCapabilitiesInterfaceTest ability test
     * @tc.desc Check the return value and error code of the interface (by Promise)
     * @tc.size MediumTest
     * @tc.type Function
     * @tc.level Level1
     */
    it('getClientCapabilities', 0, async () => {
      hilog.info(0x0000, 'getClientCapabilitiesInterfaceTest', '%{public}s', 'it begin');
      try {
        let clientCapabilities = await fido2.getClientCapabilities(context);
        expect(clientCapabilities[fido2.ClientCapability.CONDITIONAL_CREATE]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.CONDITIONAL_GET]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.HYBRID_TRANSPORT]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.PASSKEY_PLATFORM_AUTHENTICATOR]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.USER_VERIFYING_PLATFORM_AUTHENTICATOR]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.RELATED_ORIGINS]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.SIGNAL_ALL_ACCEPTED_CREDENTIALS]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.SIGNAL_CURRENT_USER_DETAILS]).not().assertEqual(null);
        expect(clientCapabilities[fido2.ClientCapability.SIGNAL_UNKNOWN_CREDENTIAL]).not().assertEqual(null);
      } catch (error) {
        expect(error.code).assertEqual(0);
        }
    })

    it('getClientCapabilitiesWithNullInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'getClientCapabilitiesWithNullInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.getClientCapabilities(null);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })

    it('getClientCapabilitiesWithUndefinedInterfaceTest2', 0, async () => {
      hilog.info(0x0000, 'getClientCapabilitiesWithUndefinedInterfaceTest2', '%{public}s', 'it begin');
      try {
        await fido2.getClientCapabilities(undefined);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })

    /**
     * @tc.number FIDO_HctsServiceAbility_0105
     * @tc.name getPlatformAuthenticatorsInterfaceTest ability test
     * @tc.desc Check the return value and error code of the interface (by Promise)
     * @tc.size MediumTest
     * @tc.type Function
     * @tc.level Level1
     */
    it('getPlatformAuthenticatorsInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'getPlatformAuthenticatorsInterfaceTest', '%{public}s', 'it begin');
      let platformAuthenticators: Array<fido2.AuthenticatorMetadata> = await fido2.getPlatformAuthenticators(context);
      expect(platformAuthenticators).not().assertEqual(null);
    })

    it('getPlatformAuthenticatorWithNullInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'getPlatformAuthenticatorsInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.getPlatformAuthenticators(null);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })

    it('getPlatformAuthenticatorsWithUndefinedInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'getPlatformAuthenticatorsInterfaceTest2', '%{public}s', 'it begin');
      try {
        await fido2.getPlatformAuthenticators(undefined);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })

    /**
     * @tc.number FIDO_HctsServiceAbility_0106
     * @tc.name registerInterfaceTest ability test
     * @tc.desc Check the return value and error code of the interface (by Promise)
     * @tc.size MediumTest
     * @tc.type Function
     * @tc.level Level1
     */
    it('registerInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'registerInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.register(context, registerOptions, tokenBinding);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })

    it('registerWithNullInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'registerWithNullInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.register(null, registerOptions, tokenBinding);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })

    it('registerWithUndefinedInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'registerWithUndefinedInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.register(undefined, registerOptions, tokenBinding);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })

    /**
     * @tc.number FIDO_HctsServiceAbility_0107
     * @tc.name authenticateInterfaceTest ability test
     * @tc.desc Check the return value and error code of the interface (by Promise)
     * @tc.size MediumTest
     * @tc.type Function
     * @tc.level Level1
     */
    it('authenticateInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'authenticateInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.authenticate(context, authenticateOptions, tokenBinding);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })
    it('authenticateWithNullInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'authenticateWithNullInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.authenticate(null, authenticateOptions, tokenBinding);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })
    it('authenticateWithUndefinedInterfaceTest', 0, async () => {
      hilog.info(0x0000, 'authenticateWithUndefinedInterfaceTest', '%{public}s', 'it begin');
      try {
        await fido2.authenticate(undefined, authenticateOptions, tokenBinding);
      } catch (e) {
        expect(e.code).assertEqual(1021300011);
      }
    })
  })
}