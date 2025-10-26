/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * */
import MethodChannel, { MethodCallHandler, } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
import PlatformView, { Params } from '@ohos/flutter_ohos/src/main/ets/plugin/platform/PlatformView';
import common from '@ohos.app.ability.common';
import { BinaryMessenger } from '@ohos/flutter_ohos/src/main/ets/plugin/common/BinaryMessenger';
import StandardMethodCodec from '@ohos/flutter_ohos/src/main/ets/plugin/common/StandardMethodCodec';

import {
  FlutterPlugin,
  FlutterPluginBinding,
  MessageCodec,
  PlatformViewFactory,
  StandardMessageCodec
} from '@ohos/flutter_ohos';
import { hilog } from '@kit.PerformanceAnalysisKit';

const logTag: string = 'UserInfoComponent';
const domainId: number = 0x0000;

@Component
struct UserInfoComponent {
  @Prop params: Params
  @StorageProp('statusBarHeight') statusBarHeight: number = 36;
  @StorageProp('aiBarHeight') aiBarHeight: number = 28;
  @StorageProp('quickLoginAnonymousPhone') quickLoginAnonymousPhone: string = '';
  customView: CustomView = this.params?.platformView as CustomView

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  // Sign out.
  private async logout() {
    this.customView.sendMessage('logout', '退出登录');
    AppStorage.set('agreementStatus', false);
  }

  build() {
    Column() {
      // Page title and back button.
      Row() {
        Text($r('app.string.personalInfo'))
          .fontSize($r('sys.float.ohos_id_text_size_headline8'))
          .fontWeight(FontWeight.Bold)
          .padding({ left: 8 })
      }.alignSelf(ItemAlign.Start)
      .height(56)

      Row() {
        Text($r('app.string.phone'))
          .fontSize($r('sys.float.ohos_id_text_size_sub_title2'))
          .fontWeight(FontWeight.Medium)
          .height('100%')
        Row() {
          Text(this.quickLoginAnonymousPhone)
            .fontSize($r('sys.float.ohos_id_text_size_sub_title3'))
            .fontColor($r('sys.color.ohos_id_color_text_secondary'))
            .height(19)
            .width(100)
            .padding({ left: 20 })
          Image($r('app.media.ic_public_arrow_right'))
            .fillColor($r('sys.color.ohos_id_color_foreground'))
            .opacity(0.2)
            .width(12)
            .height(24)
            .margin({ left: 4 })
            .draggable(false)
        }
        .width(115)
      }
      .width('100%')
      .height(56)
      .padding({
        left: 12,
        right: 12,
        top: 4,
        bottom: 4
      })
      .margin({ top: 8 })
      .border({
        width: 2,
        color: $r('sys.color.ohos_fa_list_card_bg'),
        radius: 20
      })
      .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
      .justifyContent(FlexAlign.SpaceBetween)
      .id('phoneRow')

      Blank().layoutWeight(1)

      Button({ type: ButtonType.Capsule }) {
        Text($r('app.string.logout'))
          .fontWeight(FontWeight.Medium)
      }
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .fontColor('#CE0E2D')
      .width('100%')
      .height(40)
      .constraintSize({
        maxWidth: 448
      })
      .id('logoutButton')
      .onClick(() => {
        this.logout();
      })
    }
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
    .padding({
      top: this.statusBarHeight,
      bottom: this.aiBarHeight + 16,
      left: 16,
      right: 16
    })
  }
}

@Builder
function UserInfoBuilder(params: Params) {
  UserInfoComponent({ params: params });
}


@Observed
class CustomView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel;
  index: number = 1;

  constructor(context: common.Context, viewId: number, args: Object, message: BinaryMessenger) {
    super();
    // Register the message channel.
    this.methodChannel =
      new MethodChannel(message, `com.example.flutter_login/userInfoView${viewId}`, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  onMethodCall(): void {
    // Receive messages from the Dart side.
  }

  public sendMessage = (method: string, data: string) => {
    // Send messages to the Dart side.
    this.methodChannel.invokeMethod(method, data);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(UserInfoBuilder);
  }

  dispose(): void {
  }
}

class CustomFactory extends PlatformViewFactory {
  message: BinaryMessenger;

  constructor(message: BinaryMessenger, createArgsCodes: MessageCodec<Object>) {
    super(createArgsCodes);
    this.message = message;
  }

  public create(context: common.Context, viewId: number, args: Object): PlatformView {
    return new CustomView(context, viewId, args, this.message); // Export the custom native view.
  }
}

export default class UserInfoPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return 'UserInfoPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.
    registerViewFactory('com.example.flutter_login/userInfoView', new CustomFactory(binding.getBinaryMessenger(),
      StandardMessageCodec.INSTANCE));
  }

  onDetachedFromEngine(): void {
  }
}