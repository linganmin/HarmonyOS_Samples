import { HMRouterMgr } from "@hadss/hmrouter";

class ParamsType {
}

// [Start page_url]
@Component
export struct ProductContent {
  // ...
  @State param: ParamsType | null = null;

  aboutToAppear(): void {
    this.param = HMRouterMgr.getCurrentParam() as ParamsType;
  }

  // [StartExclude page_url]
  build() {
  }

  // [EndExclude page_url]
}

// [End page_url]
