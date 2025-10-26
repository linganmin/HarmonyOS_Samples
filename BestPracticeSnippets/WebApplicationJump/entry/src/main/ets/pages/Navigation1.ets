import { webview } from "@kit.ArkWeb";

@Builder
export function Page02() {
  Navigation2()
}

@Component
export struct Navigation2 {
  @Consume('navPathStack') navPathStack: NavPathStack;
  private controller: WebviewController = new webview.WebviewController;

  build() {
  // [Start navigation1]
    NavDestination() {
      Column() {
        Web({
          src: $rawfile('index.html'),
          controller: this.controller
        })
          .zoomAccess(false)
          .onLoadIntercept((event) => {
            const url: string = event.data.getRequestUrl();
            if (url === 'arkts://pages/toOriginPage') {
              this.navPathStack.pop();
            }
            // [StartExclude navigation1]
            return false;
            // [EndExclude navigation1]
          })
      }
    }
  // [End navigation1]
  }
}