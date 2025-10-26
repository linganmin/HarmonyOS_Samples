/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { hilog } from '@kit.PerformanceAnalysisKit';
import { shippingAddress } from '@kit.AccountKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { ConfigurationConstant } from '@kit.AbilityKit';
import { showErrorMessage } from '../common/Utils';
import { AvoidRepeatClick } from '../common/AvoidRepeatClick';

const storage: LocalStorage = new LocalStorage();

const domainId: number = 0x0000;
const logTag: string = 'Address';

@Component
export struct Address {
  @Link address: shippingAddress.AddressInfo;

  // Obtain the shipping address.
  private chooseAddress() {
    const context = this.getUIContext().getHostContext();
    try {
      if (canIUse("SystemCapability.AuthenticationServices.HuaweiID.ShippingAddress")) {
        shippingAddress.chooseAddress(context).then((data: shippingAddress.AddressInfo) => {
          hilog.info(domainId, logTag, 'Succeeded in getting address');
          this.address = data;
          storage.setOrCreate('address', this.address);
        }).catch((error: BusinessError) => {
          showErrorMessage(this.getUIContext(), error);
        })
      } else {
        // The API is not supported on this device.
        hilog.error(domainId, logTag, 'The API is not supported on this device.');
      }
    } catch (error) {
      hilog.error(domainId, logTag, 'Failed to get address');
      showErrorMessage(this.getUIContext(), error);
    }
  }

  build() {
    // Shipping address.
    Flex({ direction: FlexDirection.RowReverse, alignItems: ItemAlign.Center }) {
      Image($r('app.media.ic_public_arrow_right'))
        .fillColor($r('sys.color.ohos_id_color_foreground'))
        .opacity(0.2)
        .width(12)
        .height(24)
        .margin({ left: 4 })
        .draggable(false)

      Row() {
        Text($r('app.string.shippingAddress'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)

        Row() {
          if (this.address) {
            Column() {
              if (canIUse("SystemCapability.AuthenticationServices.HuaweiID.ShippingAddress")) {
                Text(`${this.address.userName} ${this.address.mobileNumber}`)
                  .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .wordBreak(WordBreak.BREAK_ALL)
                Text(`${this.address.provinceName} ${this.address.cityName} ${this.address.districtName}` +
                  `${this.address.streetName} ${this.address.detailedAddress}`)
                  .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
                  .fontColor($r('sys.color.ohos_id_color_text_secondary'))
                  .maxLines(1)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
                  .wordBreak(WordBreak.BREAK_ALL)
              } else {
                // The API is not supported on this device.
              }
            }
            .alignItems(HorizontalAlign.End)
          } else {
            Text($r('app.string.addAddress'))
              .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
              .fontColor($r('sys.color.ohos_id_color_text_secondary'))
              .fontWeight(FontWeight.Medium)
              .textAlign(TextAlign.End)
              .maxLines(2)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .wordBreak(WordBreak.BREAK_ALL)
          }
        }.padding({ top: 8, bottom: 8 })
        .justifyContent(FlexAlign.End)
        .constraintSize({ minHeight: 48, maxWidth: '60%' })
        .padding({ left: 16 })

      }.justifyContent(FlexAlign.SpaceBetween)
      .layoutWeight(1)
    }
    .width('100%')
    .constraintSize({ minHeight: 56 })
    .padding({
      left: 12,
      right: 12,
      top: 4,
      bottom: 4
    })
    .border({
      width: 2,
      color: AppStorage.get('colorMode') === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT ?
        $r('sys.color.ohos_fa_list_card_bg') : Color.Transparent,
      radius: 20
    })
    .id('shippingAddressRow')
    .onClick(() => {
      AvoidRepeatClick.avoidRepeatClick(() => {
        this.chooseAddress();
      });
    })
  }
}
