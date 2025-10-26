
// [Start foo]
// a.ets
import { hilog } from '@kit.PerformanceAnalysisKit';
@Observed
class Foo {
  constructor() {
    hilog.info(0xFF00, "sampleTag", "this is class Foo");
  }
}

export class Bar {
  constructor() {
    hilog.info(0xFF00, "sampleTag", "this is class Bar");
  }
}
// [End foo]