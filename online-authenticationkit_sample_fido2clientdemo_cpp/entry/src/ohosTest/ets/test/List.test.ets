import abilityTest from './Ability.test';
import ConnectServiceTest from './ModuleFido2.test';

export default function testsuite() {
  abilityTest();
  ConnectServiceTest();
}