import { bundleManager, common, OpenLinkOptions } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { webview } from "@kit.ArkWeb";

@Builder
export function Page03() {
  Navigation3()
}

// [Start link1]
const link: string = "appScheme://www.test.com:80/path1";
// [End link1]
@Component
export struct Navigation3 {
  @Consume('navPathStack') navPathStack: NavPathStack;
  private controller: WebviewController = new webview.WebviewController;
  private context = this.getUIContext().getHostContext() as common.UIAbilityContext;

  build() {
    // [Start link3]
    Navigation(this.navPathStack) {
      Column() {
        Web({
          src: $rawfile('index.html'),
          controller: this.controller
        })
          .zoomAccess(false)
          .onLoadIntercept((event) => {
            const url: string = event.data.getRequestUrl();
            if (url === 'third-party://pages/toThirdApp') {
              const link: string = "appScheme://www.test.com:80/path1";
              // [Start link2]
              if (!bundleManager.canOpenLink(link)) {
                return true;
              }
              // [End link2]
              // Configuration parameter.
              const openLinkOptions: OpenLinkOptions = {
                appLinkingOnly: false,
                parameters: {
                  name: 'test'
                }
              };
              // Open the application using the openLink interface.
              this.context.openLink(link, openLinkOptions).then(() => {
                console.info('open link success.');
              }).catch((err: BusinessError) => {
                console.error(`open link failed. Code is ${err.code}, message is ${err.message}`);
              })
            }
            return url !== 'resource://rawfile/index2.html';
          })
      }
    }
    // [End link3]
  }
}