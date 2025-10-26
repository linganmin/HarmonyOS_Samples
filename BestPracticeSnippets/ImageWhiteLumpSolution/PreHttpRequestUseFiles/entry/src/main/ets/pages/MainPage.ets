/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/*
 * 最佳实践：Image白块解决问题指导
 *
 * 使用预下载解决Image长时间白块 正例
 */

// [Start local_storage]
import { fileIo as fs } from '@kit.CoreFileKit';
import { image } from '@kit.ImageKit';
import { common } from '@kit.AbilityKit';
import { httpRequest } from '../utils/NetRequest';

// Get the application file path
const uiContext: UIContext | undefined = AppStorage.get('uiContext');
let context = uiContext?.getHostContext() as common.UIAbilityContext;
let filesDir = context.filesDir;
let fileUrl = filesDir + '/xxx.png'; // 当使用实际网络地址时，需填入实际地址的后缀。
let para: Record<string, PixelMap | undefined> = { 'imageData': undefined };
let localStorage: LocalStorage = new LocalStorage(para);

@Entry(localStorage)
@Component
struct MainPage {
  @State childNavStack: NavPathStack = new NavPathStack();
  @LocalStorageLink('imageData') imageData: PixelMap | undefined = undefined;

  getPixMap() { // Read files from the application sandbox.
    try {
      let file = fs.openSync(fileUrl, fs.OpenMode.READ_WRITE); // Open the file using synchronous method
      const imageSource: image.ImageSource = image.createImageSource(file.fd);
      const options: image.InitializationOptions = {
        'alphaType': 0, // opacity
        'editable': false, // Is it editable
        'pixelFormat': 3, // Pixel format
        'scaleMode': 1, // Abbreviation
        'size': { height: 100, width: 100 }
      };
      fs.close(file);
      imageSource.createPixelMap(options).then((pixelMap: PixelMap) => {
        this.imageData = pixelMap;
      });
    } catch (e) {
      console.error('资源加载错误，文件或不存在！');
    }
  }

  aboutToAppear(): void {
    httpRequest(); // Initiate network requests in the parent component in advance.
  }

  build() {
    Navigation(this.childNavStack) {
      Column() {
        Button('push Path to pageOne', { stateEffect: true, type: ButtonType.Capsule })
          .width('80%')
          .height(40)
          .margin({ bottom: '36vp' })
          .onClick(() => {
            if (!localStorage.get('imageData')) { // Do not call getPixMap() repeatedly for non-first clicks to avoid reading files from the sandbox every time.
              this.getPixMap();
            }
            this.childNavStack.pushPath({ name: 'pageOne' });
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.End)
    }
    .backgroundColor(Color.Transparent)
    .title('ParentNavigation')
  }
}
// [End local_storage]
