/*
* Copyright (c) 2024 Huawei Device Co., Ltd.
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*/

/*
* FAQ:调用imageSource.createPixelMap()报错"Create PixelMap error"
 */

// [Start ResolveCreatePixelMapError_Two]
import { BusinessError } from '@kit.BasicServicesKit';
import { image } from '@kit.ImageKit';

let decodingOptions: image.DecodingOptions = {
  editable: true,
  desiredPixelFormat: 3,
  desiredSize: { width: 4, height: 6 }
}
const context: Context = AppStorage.get("context")!;
const filePath: string = context.cacheDir + '/test.jpg';
const imageSource: image.ImageSource = image.createImageSource(filePath);
// Create PixelMap and perform simple rotation and scaling
imageSource.createPixelMap(decodingOptions).then((pixelMap: image.PixelMap) => {
  console.log("Succeeded in creating PixelMap")
}).catch((err: BusinessError) => {
  console.error("Failed to create PixelMap")
});
// [End ResolveCreatePixelMapError_Two]