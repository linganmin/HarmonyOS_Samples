/*
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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

import { hilog } from '@kit.PerformanceAnalysisKit'
import { image } from '@kit.ImageKit'

import hiai from 'libentry.so'

@Entry
@Component
struct Index {
  build() {
    Column({space : 16}) {
      PageTitleDisplay()
      ImageForClassificationDisplay()
    }
    .alignItems(HorizontalAlign.Center)
  }
}

@Component
struct PageTitleDisplay {
  @State message: string = 'HiAI Classification DEMO'

  build() {
    Column({space: 16}) {
      Text(this.message)
        .fontSize(24)
        .height('6%')
        .backgroundColor(Color.Orange)
    }
  }
}

@Component
struct ImageForClassificationDisplay
{
  @State messageClickPredict : string = "Click for classification"
  @State messageForNext : string = "Click for next image"
  @State imageToBeClassified : Resource = $r('app.media.guitar')
  @State imagesList : Resource[] = [$r('app.media.guitar'), $r('app.media.cup')]

  @State index : number = 0
  @State firstResult : string = ''
  @State secondResult : string = ''
  @State thirdResult : string = ''

  build() {
    Column() {
      Row() {
        Button(this.messageClickPredict)
          .type(ButtonType.Normal)
          .width('90%')
          .height('7%')
          .margin('1%')
          .padding('1%')
          .layoutWeight(1)
          .onClick(() => {
            const context = getContext(this)
            context.resourceManager.getMediaContent(this.imageToBeClassified).then(value => {
              let buf = new ArrayBuffer(value.length)
              let tempBuffer = new Uint8Array(buf)
              for (let i = 0; i < value.length; i++) {
                tempBuffer[i] = value[i]
              }
              const imageSource = image.createImageSource(buf)

              // Set the image format to BGRA_8888.
              imageSource.createPixelMap({desiredPixelFormat : image.PixelMapFormat.BGRA_8888})
                .then(async pixelMapObj => {
                  let width = 0
                  let height = 0
                  await pixelMapObj.getImageInfo().then(async info => {
                    width = info.size.width
                    height = info.size.height
                  })
                  // Zoom the image to 227 * 227
                  await pixelMapObj.scale(227 / width, 227 / height)
                  // Adjust the image back to the correct
                  await pixelMapObj.rotate(270.0)
                  await pixelMapObj.flip(false, true)
                  pixelMapObj.getImageInfo().then(info => {
                    let resizeH = info.size.height
                    let resizeW = info.size.width

                    const readBuffer = new ArrayBuffer(pixelMapObj.getPixelBytesNumber())
                    pixelMapObj.readPixelsToBuffer(readBuffer, (err, res)=> {
                      if (err) {
                        hilog.error(0x0000, 'HiAIFoundationDemo', 'Failed to read image pixel data')
                        return
                      } else {
                        let dataArray = new Uint8Array(readBuffer)
                        let len1 = 227
                        let len2 = 227
                        let len3 = 4
                        let pixelArray : Array<Array<Uint8Array>> = new Array<Array<Uint8Array>>(len1)
                        for (let i = 0; i < len1; ++i) {
                          pixelArray[i] = new Array<Uint8Array>(len2)
                          for (let j = 0; j < len2; ++j) {
                            pixelArray[i][j] = new Uint8Array(len3)
                            for (let k = 0; k < len3; ++k) {
                              pixelArray[i][j][k] = dataArray[i * len2 * len3 + j * len3 + k]
                            }
                          }
                        }
                        // Sets the input BGR channel value.
                        let channel = 3
                        const color = new ArrayBuffer(channel * resizeW * resizeH)
                        let inputData = new Uint8Array(color)
                        for (let i = 0; i < resizeW; i++) {
                          for (let j = 0; j < resizeH; j++) {
                            let bIndex = (i * resizeW) + j;
                            let gIndex = bIndex + (resizeW * resizeH);
                            let rIndex = gIndex + (resizeW * resizeH);
                            inputData[bIndex] = pixelArray[j][i][0];
                            inputData[gIndex] = pixelArray[j][i][1];
                            inputData[rIndex] = pixelArray[j][i][2];

                          }
                        }

                        // Initialize input and output data.
                        let ret = hiai.InitIOTensors(inputData)
                        if (ret != 0) {
                          hilog.error(0x0000, 'HiAIFoundationDemo', 'Failed to init IOTensors.')
                          return
                        }
                        hilog.info(0x0000, 'HiAIFoundationDemo', 'Succeeded in initing IOTensors.')
                        
                        // Model Inference
                        ret = hiai.RunModel()
                        if (ret != 0) {
                          hilog.error(0x0000, 'HiAIFoundationDemo', 'Failed to run model.')
                          return
                        }
                        hilog.info(0x0000, 'HiAIFoundationDemo', 'Successed in running model.')
                        // Get model Output
                        let classificationResult = hiai.GetResult()
                        this.firstResult = classificationResult[0]
                        this.secondResult = classificationResult[1]
                        this.thirdResult = classificationResult[2]
                        hilog.info(0x0000, 'HiAIFoundationDemo', 'Done.')
                      }
                    })
                  })
                })
            })
          })

        Button(this.messageForNext)
          .type(ButtonType.Normal)
          .width('90%')
          .height('7%')
          .margin('1%')
          .padding('1%')
          .layoutWeight(1)
          .onClick(() => {
            this.index++;
            this.firstResult = ''
            this.secondResult = ''
            this.thirdResult = ''
            if (this.index >= this.imagesList.length) {
              this.index = 0
            }
            this.imageToBeClassified = this.imagesList[this.index]
          })
      }

      Image(this.imageToBeClassified)
        .width('90%')
        .height('50%')
        .objectFit(ImageFit.Contain)
        .id('detectImage')

      Text(this.firstResult)
        .textAlign(TextAlign.Start)
        .fontSize(17)
        .fontColor(0xFF69B4)
        .padding('2%')
        .width('100%')
        .height('5%')
        .backgroundColor(Color.White)

      Text(this.secondResult)
        .textAlign(TextAlign.Start)
        .fontSize(17)
        .fontColor(0xFF69B4)
        .padding('2%')
        .width('100%')
        .height('5%')
        .backgroundColor(Color.White)

      Text(this.thirdResult)
        .textAlign(TextAlign.Start)
        .fontSize(17)
        .fontColor(0xFF69B4)
        .padding('2%')
        .width('100%')
        .height('5%')
        .backgroundColor(Color.White)
    }
  }
}
