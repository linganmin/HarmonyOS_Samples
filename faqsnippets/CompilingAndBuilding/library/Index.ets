// FAQ:如何获取BuildProfile中的值
// [Start build_profile_1]
import BuildProfile from './BuildProfile';

// [End build_profile_1]

// [Start build_profile_2]
const HAR_VERSION: string = BuildProfile.HAR_VERSION;
const BUILD_MODE_NAME: string = BuildProfile.BUILD_MODE_NAME;
const DEBUG: boolean = BuildProfile.DEBUG;

// [End build_profile_2]

export default class allFunction {
  static sub(a: number, b: number): number {
    return a + b
  }
}