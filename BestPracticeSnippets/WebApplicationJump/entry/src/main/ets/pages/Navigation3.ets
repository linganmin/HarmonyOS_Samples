import { hilog } from "@kit.PerformanceAnalysisKit";
import { common } from "@kit.AbilityKit";
import { webview } from "@kit.ArkWeb";

@Builder
export function Page04() {
  Navigation4()
}

@Component
export struct Navigation4 {
  @Consume('navPathStack') navPathStack: NavPathStack;
  private controller: WebviewController = new webview.WebviewController;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    // [Start path_stack1]
    Navigation(this.navPathStack) {
      Column() {
        Web({
          src: $rawfile('index.html'),
          controller: this.controller
        })
          .zoomAccess(false)
          .onLoadIntercept((event) => {
            const url: string = event.data.getRequestUrl();
            if (url === 'arkts://pullSpeciallyApp') {
              const wantParam: Record<string, Object> = {
                'sceneType': 1,
                'destinationLatitude': 32.060844,
                'destinationLongitude': 118.78315,
                'destinationName': 'xx市xx路xx号',
                'destinationPoiIds': {
                  1: '111111111111',
                  2: '222222222222'
                } as Record<number, string>,
                'originName': 'xx市xx公园',
                'originLatitude': 31.060844,
                'originLongitude': 120.78315,
                'originPoiIds': {
                  1: '333333333333',
                  2: '444444444444'
                } as Record<number, string>,
                'vehicleType': 0
              };
              const abilityStartCallback: common.AbilityStartCallback = {
                onError: (code: number, name: string, message: string) => {
                  hilog.error(0x0000, 'Sample', '%{public}s', 'onError code ' + code + 'name: ' + name + 'message: ' + message);
                },
                onResult: (result:ESObject) => {
                  hilog.error(0x0000, 'Sample', '%{public}s', 'onResult result: ' + JSON.stringify(result));
                }
              };
              this.context.startAbilityByType('navigation', wantParam, abilityStartCallback);
            }
            return url !== 'resource://rawfile/index.html';
          })
      }
    }
    // [End path_stack1]
  }
}