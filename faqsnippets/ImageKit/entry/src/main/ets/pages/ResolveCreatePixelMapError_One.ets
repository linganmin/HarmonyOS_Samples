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
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';

const uri = ''

/*
* FAQ:调用imageSource.createPixelMap()报错"Create PixelMap error"
 */

const createPixelMapError = async () => {
  // [Start ResolveCreatePixelMapError_One]
  const file = fs.openSync(uri, fs.OpenMode.READ_ONLY);
  const imageSource = image.createImageSource(file.fd);
  const pixelMap = await imageSource.createPixelMap({sampleSize: 2, rotate: 0});
  // [End ResolveCreatePixelMapError_One]
}