import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { webview } from "@kit.ArkWeb";
import { Constants } from "../common/Constants";
import { OriginPage } from "./OriginPage";

@Builder
export function Page05() {
  Navigation5()
}

@Component
export struct Navigation5 {
  @Consume('navPathStack') navPathStack: NavPathStack;
  private controller: WebviewController = new webview.WebviewController;

  @Builder
  PageMap(name: string) {
    if (name === Constants.ORIGIN_PAGE) {
      OriginPage()
    }
  }

  build() {
    // [Start path_stack2]
    Navigation(this.navPathStack) {
      Column() {
        Web({
          src: $rawfile('index.html'),
          controller: this.controller
        })
          .zoomAccess(false)
          .onLoadIntercept((event) => {
            const url: string = event.data.getRequestUrl();
            if (url === 'photo://pages/selectPhoto') {
              const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
              photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE; // Filter and select the media file type as IMAGE
              photoSelectOptions.maxSelectNumber = 5; // Select the maximum number of media files
              let uris: Array<string> = [];
              const photoViewPicker = new photoAccessHelper.PhotoViewPicker();
              photoViewPicker.select(photoSelectOptions)
                .then((photoSelectResult: photoAccessHelper.PhotoSelectResult) => {
                  uris = photoSelectResult.photoUris;
                  console.info('photoViewPicker.select to file succeed and uris are:' + uris);
                })
                .catch((err: BusinessError) => {
                  console.error(`Invoke photoViewPicker.select failed, code is ${err.code}, message is ${err.message}`);
                })
            }
            return url !== 'resource://rawfile/index3.html';
          })
      }
    }
    .hideTitleBar(true)
    .navDestination(this.PageMap)
    // [End path_stack2]
  }
}