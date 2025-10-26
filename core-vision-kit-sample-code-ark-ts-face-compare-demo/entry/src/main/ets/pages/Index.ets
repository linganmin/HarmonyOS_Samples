import { faceComparator } from '@kit.CoreVisionKit';
import { image } from '@kit.ImageKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { fileIo } from '@kit.CoreFileKit';
import { photoAccessHelper } from '@kit.MediaLibraryKit';

@Entry
@Component
struct Index {
  @State chooseImage: PixelMap | undefined = undefined
  @State chooseImage1: PixelMap | undefined = undefined
  @State dataValues: string = ''

  build() {
    Column() {
      Image(this.chooseImage)
        .objectFit(ImageFit.Contain)
        .height('30%')
        .accessibilityDescription("Default image 1")

      Image(this.chooseImage1)
        .objectFit(ImageFit.Fill)
        .height('30%')
        .accessibilityDescription("Default image 2")

      Text(this.dataValues)
        .copyOption(CopyOptions.LocalDevice)
        .height('15%')
        .margin(10)
        .width('60%')

      Button('Select images')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .alignSelf(ItemAlign.Center)
        .width('80%')
        .margin(10)
        .onClick(() => {
          // Pull up the gallery.
          this.selectImage()
        })

      Button('Compare faces')
        .type(ButtonType.Capsule)
        .fontColor(Color.White)
        .alignSelf(ItemAlign.Center)
        .width('80%')
        .margin(10)
        .onClick(async () => {
          if(!this.chooseImage || !this.chooseImage1) {
            hilog.error(0x0000, 'FaceCompareSample', `Failed to choose image. chooseImage: ${this.chooseImage}`);;
            return;
          }
          let visionInfo: faceComparator.VisionInfo = {
            pixelMap: this.chooseImage
          };
          let visionInfo1: faceComparator.VisionInfo = {
            pixelMap: this.chooseImage1
          };
          try {
            // Call the face verification API.
            let data:faceComparator.FaceCompareResult = await faceComparator.compareFaces(visionInfo, visionInfo1);
            let faceString = "Similarity: "+ this.toPercentage(data.similarity)+((data.isSamePerson)?".\nSame":". \nNot the same")+" person";
            hilog.info(0x0000, 'FaceCompareSample', `Succeeded in face compare：${faceString}`);
            this.dataValues = faceString;
          } catch (error) {
            hilog.error(0x0000, 'FaceCompareSample', `face compare failed: ${error}`);
            this.dataValues = "Face comparison error. Ensure that there are faces in both images.";
          }
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }

  private toPercentage(num: number): string {
    return `${(num * 100).toFixed(2)}%`;
  }

  private async selectImage() {
    let uri = await this.openPhoto()
    if (uri === undefined) {
      hilog.error(0x0000, 'FaceCompareSample', "Failed to defined uri.");
    }
    this.loadImage(uri);
  }

  private openPhoto(): Promise<Array<string>> {
    return new Promise<Array<string>>((resolve, reject)=>{
      let PhotoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      PhotoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      PhotoSelectOptions.maxSelectNumber = 2;
      let photoPicker: photoAccessHelper.PhotoViewPicker = new photoAccessHelper.PhotoViewPicker();
      photoPicker.select(PhotoSelectOptions).then((PhotoSelectResult) => {
        resolve(PhotoSelectResult.photoUris)
      }).catch((err:BusinessError) => {
        hilog.error(0x0000, 'faceDetectorSample', `Failed to get photo image uri. code：${err.code}，message：${err.message}`);
        reject();
      });
    })
  }

  private loadImage(names: string[]) {
    setTimeout(async () => {
      let imageSource: image.ImageSource | undefined = undefined;
      let fileSource = await fileIo.open(names[0], fileIo.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(fileSource.fd);
      this.chooseImage = await imageSource.createPixelMap();
      fileSource = await fileIo.open(names[1], fileIo.OpenMode.READ_ONLY);
      imageSource = image.createImageSource(fileSource.fd);
      this.chooseImage1 = await imageSource.createPixelMap();
    }, 100
    )
  }
}