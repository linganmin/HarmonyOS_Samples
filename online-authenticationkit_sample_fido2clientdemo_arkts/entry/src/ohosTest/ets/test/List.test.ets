import Fido2NetUtilTest from './Fido2NetUtil.test'
import IndexTest from './Index.test'
import abilityTest from './Ability.test';

export default function testsuite() {
  abilityTest();
  IndexTest()
  Fido2NetUtilTest()
}