import { LayeredDrawableDescriptor } from '@kit.ArkUI';
import { hdsDrawable } from '@kit.UIDesignKit';
import { image } from '@kit.ImageKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { resourceManager } from '@kit.LocalizationKit';

@Entry
@Component
struct GetHdsLayeredIcon {
  bundleName: string = 'com.example.uidesignkit';
  resManager: resourceManager.ResourceManager | undefined = undefined;
  layeredDrawableDescriptor: LayeredDrawableDescriptor | undefined = undefined;
  @State layeredIconsResult: Array<hdsDrawable.ProcessedIcon> = [];
  @State layeredIconAsyncResult: image.PixelMap | null = null;

  build() {
    Column() {
      Column() {
        Text('getHdsLayeredIcon')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .margin(5)

        Image(this.getHdsLayeredIconWithBorder())
          .width(48)
          .height(48)
      }
      .margin({
        top: 20
      })

      Column() {
        Text('getHdsLayeredIconAsync')
          .fontWeight(FontWeight.Bold)
          .fontSize(16)
          .margin(5)

        Image(this.layeredIconAsyncResult)
          .width(48)
          .height(48)
      }
      .margin(20)

      Text('getHdsLayeredIcons')
        .fontWeight(FontWeight.Bold)
        .fontSize(16)
        .margin(5)

      List() {
        ForEach(this.layeredIconsResult,
          (item: hdsDrawable.ProcessedIcon, index?: number) => {
            ListItem() {
              Column() {
                Text(item.bundleName)
                  .fontWeight(FontWeight.Medium)
                  .fontSize(16)
                  .margin(5)

                Image(item.pixelMap)
                  .width(48)
                  .height(48)
              }
              .margin(15)
            }
            .width('100%')
          }, (item: string) => item.toString())
      }
      .scrollBar(BarState.On)
      .height('60%')
      .width('100%')
    }
    .height('100%')
    .width('100%')
  }

  aboutToAppear(): void {
    this.resManager = this.getUIContext().getHostContext()?.resourceManager;
    if (!this.resManager) {
      return;
    }
    this.layeredDrawableDescriptor = (this.resManager.getDrawableDescriptor($r('app.media.drawable')
      .id)) as LayeredDrawableDescriptor;
    this.getHdsLayeredIcons();
    this.getHdsLayeredIconAsync();
  }

  private getHdsLayeredIconWithBorder(): image.PixelMap | null {
    try {
      return hdsDrawable.getHdsLayeredIcon(this.bundleName, this.layeredDrawableDescriptor, 48, true);
    } catch (err) {
      let message = (err as BusinessError).message;
      let code = (err as BusinessError).code;
      console.error(`getHdsLayeredIcon failed, code: ${code}, message: ${message}`);
      return null;
    }
  }

  private getHdsLayeredIcons(): void {
    if (!this.layeredDrawableDescriptor) {
      console.error(`getHdsLayeredIcons layeredDrawableDescriptor is undefined.`);
      return;
    }

    let options: hdsDrawable.Options = {
      size: 48,
      hasBorder: true,
      parallelNumber: 4
    };

    let layeredIcons: Array<hdsDrawable.LayeredIcon> = [];
    for (let i = 0; i < 10; i++) {
      layeredIcons.push({
        bundleName: `${this.bundleName}-${i}`,
        layeredDrawableDescriptor: this.layeredDrawableDescriptor
      });
    }

    try {
      hdsDrawable.getHdsLayeredIcons(layeredIcons, options)
        .then((data: Array<hdsDrawable.ProcessedIcon>) => {
          console.info(`getHdsLayeredIcons data size: ${data.length}`);
          this.layeredIconsResult = data;
        })
        .catch((err: BusinessError) => {
          console.error(`getHdsLayeredIcons return error, code: ${err.code}, msg: ${err.message}`);
        });
    } catch (err) {
      let message = (err as BusinessError).message;
      let code = (err as BusinessError).code;
      console.error(`getHdsLayeredIcons failed, code: ${code}, message: ${message}`);
    }
  }

  private getHdsLayeredIconAsync(): void {
    try {
      hdsDrawable.getHdsLayeredIconAsync(this.bundleName, this.layeredDrawableDescriptor, 48, true)
        .then((data: image.PixelMap) => {
          this.layeredIconAsyncResult = data;
        })
        .catch((err: BusinessError) => {
          console.error(`getHdsLayeredIconAsync return error, code: ${err.code}, msg: ${err.message}`);
        });
    } catch (err) {
      let message = (err as BusinessError).message;
      let code = (err as BusinessError).code;
      console.error(`getHdsLayeredIconAsync failed, code: ${code}, message: ${message}`);
    }
  }
}