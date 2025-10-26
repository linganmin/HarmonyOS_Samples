/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2025. All rights reserved.
 */
import { FunctionalButton, functionalButtonComponentManager } from '@kit.ScenarioFusionKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { copyFile, showErrorMessage } from '../common/Utils';

const logTag: string = 'Avatar';
const domainId: number = 0x0000;

@Component
export struct Avatar {
  @Link avatar: string | undefined;
  onChange: (avatar: string | undefined) => void = () => {
  };

  build() {
    Row() {
      Row() {
        if (!this.avatar) {
          FunctionalButton({
            params: {
              openType: functionalButtonComponentManager.OpenType.CHOOSE_AVATAR,
              label: '',
              styleOption: {
                size: functionalButtonComponentManager.SizeType.DEFAULT,
                bgColor: functionalButtonComponentManager.ColorType.DEFAULT,
                plain: false,
                disabled: false,
                loading: false,
                hoverClass: functionalButtonComponentManager.HoverClassType.HOVER_CLASS,
                hoverStartTime: 0,
                hoverStayTime: 0,
                styleConfig: new functionalButtonComponentManager.ButtonConfig()
                  .backgroundColor(Color.Transparent)
                  .borderWidth(0)
                  .borderRadius(20)
                  .type(ButtonType.Circle)
                  .backgroundImagePosition(Alignment.Center)
                  .backgroundImageSize(ImageSize.Cover)
                  .height(40)
                  .width(40)
                  .backgroundImage($r("app.media.avatar_icon"))
              }
            },
            controller: new functionalButtonComponentManager.FunctionalButtonController()
              .onChooseAvatar(async (err: BusinessError,
                data: functionalButtonComponentManager.ChooseAvatarResult) => {
                if (err) {
                  showErrorMessage(this.getUIContext(), err);
                  return;
                }

                // Preferentially use the cloud storage to store the avatar to ensure consistency between devices.
                // ...

                // In this example, the avatar is stored locally.
                if (data.avatarUri) {
                  this.onChange(copyFile(this.getUIContext(), data.avatarUri));
                  this.avatar = data.avatarUri;
                }
              })
          }).id('avatarFunctionalButtonId')
        } else {
          Image(this.avatar)
            .height(40)
            .width(40)
            .borderRadius(20)
            .onError((err) => {
              hilog.info(domainId, logTag, `Avatar image load fail, errMessage is ${err.message}`);
              // When the avatar address becomes invalid, clear the invalid address.
              this.onChange(undefined);
              this.avatar = '';
            })
        }

        Text($r('app.string.hwUser'))
          .fontWeight(FontWeight.Medium)
          .fontSize(16)
          .margin({ left: 12 })
      }

      Image($r('app.media.ic_public_arrow_right'))
        .fillColor($r('sys.color.ohos_id_color_foreground'))
        .opacity(0.2)
        .width(12)
        .height(24)
    }
    .width('100%')
    .height(64)
    .padding({ left: 12, right: 12 })
    .margin({ top: 12 })
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
    .justifyContent(FlexAlign.SpaceBetween)
    .borderRadius(20)
  }
}
