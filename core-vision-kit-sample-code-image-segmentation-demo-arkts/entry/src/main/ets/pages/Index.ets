import { subjectSegmentation } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';
import { common } from '@kit.AbilityKit';

const TAG: string = "ImageSegmentationSample";

@Entry
@Component
struct Index {
  @State chooseImage: PixelMap | undefined = undefined
  @State dataValues: string = ''
  @State maxNum: string = '20'
  private mContext: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;

  async aboutToAppear() {
    initSubjectSegmentation();
    this.chooseImage = await this.getPixelMap($r("app.media.3cat"));
  }

  public async getPixelMap(picPath: Resource): Promise<image.PixelMap> {
    let resourceM = this.mContext.resourceManager;
    const value = await resourceM.getMediaContent(picPath);
    const imageSourceApi = image.createImageSource(value.buffer);
    return imageSourceApi.createPixelMap();
  }

  aboutToDisappear(): void {
    releaseSubjectSegmentation();
  }

  build() {
    Column() {
      Image(this.chooseImage)
        .objectFit(ImageFit.Contain)
        .height('30%')
        .accessibilityDescription("Image to be split")

      Scroll() {
        Text(this.dataValues)
          .copyOption(CopyOptions.LocalDevice)
          .margin(10)
          .width('100%')
      }
      .height('20%')  // Sets the height of the Scroll component.

      Row() {
        Text('Maximum number of principals:')
          .fontSize(16)
        TextInput({ placeholder: 'Please enter the maximum number of entities', text: this.maxNum })
          .type(InputType.Number)
          .placeholderColor(Color.Gray)
          .fontSize(16)
          .backgroundColor(Color.White)
          .onChange((value: string) => {
            this.maxNum = value
          })
      }
      .width('80%')
      .margin(10)

      Button('Select image')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .alignSelf(ItemAlign.Center)
        .width('80%')
        .margin(10)
        .onClick(() => {
          // Pull up the gallery.
          this.selectImage()
        })

      Button('Start subject segmentation')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .alignSelf(ItemAlign.Center)
        .width('80%')
        .margin(10)
        .onClick(async () => {
          if (!this.chooseImage) {
            hilog.error(0x0000, 'testTag', "imageSegmentation not have chooseImage");
            return
          }
          let visionInfo: subjectSegmentation.VisionInfo = {
            pixelMap: this.chooseImage
          };
          let config: subjectSegmentation.SegmentationConfig = {
            maxCount: parseInt(this.maxNum),
            enableSubjectDetails: true,
            enableSubjectForegroundImage: true
          };
          // Call the image segmentation API.
          let data: subjectSegmentation.SegmentationResult = await subjectSegmentation.doSegmentation(visionInfo, config);
          let outputString = `Subjects: ${data.subjectCount}\n`;
          outputString += `Maximum subjects: ${config.maxCount}\n`;
          outputString += `Show bounding box of each subject: ${config.enableSubjectDetails ? 'Yes' : 'No'}\n\n`;
          let segBox : subjectSegmentation.Rectangle = data.fullSubject.subjectRectangle;
          let segBoxString = `Global bounding box:\nLeft: ${segBox.left}, Top: ${segBox.top}, Width: ${segBox.width}, Height: ${segBox.height}\n\n`;
          outputString += segBoxString;

          if (config.enableSubjectDetails) {
            outputString += 'Individual bounding boxes:\n';
            if (data.subjectDetails) {
              for (let i = 0; i < data.subjectDetails.length; i++) {
                let detailSegBox: subjectSegmentation.Rectangle = data.subjectDetails[i].subjectRectangle;
                outputString += `Subject ${i + 1}:\nLeft: ${detailSegBox.left}, Top: ${detailSegBox.top}, Width: ${detailSegBox.width}, Height: ${detailSegBox.height}\n\n`;
              }
            }
          }

          hilog.info(0x0000, 'testTag', "Segmentation result: " + outputString);
          this.dataValues = outputString;
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private async selectImage() {
    let uri = await this.openPhoto()
    if (uri === undefined) {
      hilog.error(0x0000, 'imageSegmentation', "uri is undefined");
    }
    this.loadImage(uri);
  }

  private openPhoto(): Promise<Array<string>> {
    return new Promise<Array<string>>((resolve, reject) => {
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 1;
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        hilog.info(0x0000, TAG, `PhotoViewPicker.select successfully, PhotoSelectResult uri: ${PhotoSelectResult.photoUris}`);
        resolve(PhotoSelectResult.photoUris)
      }).catch((err: BusinessError) => {
        hilog.error(0x0000, TAG, `PhotoViewPicker.select failed with errCode: ${err.code}, errMessage: ${err.message}`);
        reject();
      });
    })
  }

  private loadImage(names: string[]) {
    setTimeout(async () => {
      let imageSource: image.ImageSource | undefined = undefined
      let fileSource = await fileIo.open(names[0], fileIo.OpenMode.READ_ONLY)
      imageSource = image.createImageSource(fileSource.fd)
      this.chooseImage = await imageSource.createPixelMap()
      hilog.info(0x0000, 'imageSegmentation', `this.chooseImage===${JSON.stringify(this.chooseImage)}`);
    }, 100
    )
  }
}

async function initSubjectSegmentation() {
  const initResult = await subjectSegmentation.init();
  hilog.info(0x0000, 'subjectSegmentationSample', `Subject segmentation initialization result:${initResult}`);
}

async function releaseSubjectSegmentation() {
  await subjectSegmentation.release();
  hilog.info(0x0000, 'subjectSegmentationSample', 'Subject segmentation released successfully');
}