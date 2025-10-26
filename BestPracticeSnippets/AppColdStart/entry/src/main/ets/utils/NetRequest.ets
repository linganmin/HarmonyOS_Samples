// [Start request_in_home]
// [Start net_request]
// NetRequest.ets
import { hiTraceMeter } from '@kit.PerformanceAnalysisKit';
import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';
// Download picture resources from the Internet through the http request method
export function httpRequest(): void {
  hiTraceMeter.startTrace('Http Request', 1);
  http.createHttp()
  // The actual development needs to "https://www.example1.com/POST?e=f&g=h"replaced with the real website address to visit
    .request('https://www.example1.com/POST?e=f&g=h',
      (error: BusinessError, data: http.HttpResponse) => {
        if (error) {
          // The follow-up logic is not executed when the download fails.
          return;
        }
        // Processing the data returned by network requests
        transcodePixelMap(data);
      }
    )
}

// Use createPixelMap to replace pictures of ArrayBuffer types with PixelMap types.
function transcodePixelMap(data: http.HttpResponse): void {
  if (http.ResponseCode.OK === data.responseCode) {
    const imageData: ArrayBuffer = data.result as ArrayBuffer;
    // Create a picture source instance through ArrayBuffer
    const imageSource: image.ImageSource = image.createImageSource(imageData);
    const options: image.InitializationOptions = {
      'alphaType': 0, // Transparency
      'editable': false, // Is it editable?
      'pixelFormat': 3, // Pixel format
      'scaleMode': 1, // Abbreviation
      'size': { height: 100, width: 100 }
    }; // Create the size of the picture
    // Create PixelMap through properties
    imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
      AppStorage.set('netData', pixelMap);
      hiTraceMeter.finishTrace('Http Request', 1);
    });
  }
}
// [End net_request]
// [End request_in_home]
