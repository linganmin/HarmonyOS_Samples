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
import { loginComponentManager } from '@kit.AccountKit';
import { connection } from '@kit.NetworkKit';
import { showNetWorkError } from '../common/Utils';

const logTag: string = 'PrivacyComponent';
const domainId: number = 0x0000;

@Component
struct PrivacyComponent {
  @Prop params: Params
  @StorageProp('loginLoading') disabled: boolean = false;
  customView: CustomView = this.params?.platformView as CustomView;
  privacyText: loginComponentManager.PrivacyText[] = [
    {
      text: $r('app.string.agree'),
      type: loginComponentManager.TextType.PLAIN_TEXT
    }, {
    text: $r('app.string.shopping_user_agreement'),
    type: loginComponentManager.TextType.RICH_TEXT,

    // Change the link to that of your own privacy policy.
    // ...
  }, {
    text: $r('app.string.protocol_separator'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.shopping_privacy_policy'),
    type: loginComponentManager.TextType.RICH_TEXT,

    // Change the link to that of your own privacy policy.
    // ...

  }, {
    text: $r('app.string.protocol_separator'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.and'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }, {
    text: $r('app.string.huaweiId_user_authentication_protocol'),
    type: loginComponentManager.TextType.RICH_TEXT,
    tag: 'tag'
  }, {
    text: $r('app.string.end'),
    type: loginComponentManager.TextType.PLAIN_TEXT
  }
  ];

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  build() {
    Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
      Text() {
        ForEach(this.privacyText, (item: loginComponentManager.PrivacyText) => {
          if (item?.type === loginComponentManager.TextType.PLAIN_TEXT && item?.text) {
            Span(item?.text)
              .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
              .fontWeight(FontWeight.Regular)
              .fontSize($r('sys.float.ohos_id_text_size_body3'))
          } else if (item?.type === loginComponentManager.TextType.RICH_TEXT && item?.text) {
            Span(item?.text)
              .fontColor($r('sys.color.ohos_id_color_text_primary'))
              .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
              .fontWeight(FontWeight.Medium)
              .fontSize($r('sys.float.ohos_id_text_size_body3'))
              .focusable(true)
              .focusOnTouch(true)
              .id('userAgreeProtocolUrlSpan')
              .onClick(() => {
                if (!this.disabled && item.tag) {
                  hilog.info(domainId, logTag, 'Click protocol url');
                  const hasNet: boolean = connection.hasDefaultNetSync();
                  if (!hasNet) {
                    showNetWorkError();
                    return;
                  }
                  this.customView.sendMessage('openPrivacy', '');
                }
              })
          }
        }, (item: loginComponentManager.PrivacyText, index: number) => `${item.text}_${index}}`)
      }
      .flexGrow(0)
      .flexShrink(0)
      .lineHeight(15)
      .opacity(this.disabled ? 0.6 : 1)
    }

    .height(30)
  }
}

@Builder
function PrivacyBuilder(params: Params) {
  PrivacyComponent({ params: params });
}


@Observed
class CustomView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    // Register the message channel.
    this.methodChannel =
      new MethodChannel(message, `com.example.flutter_login/privacyView${viewId}`, StandardMethodCodec.INSTANCE);
    this.methodChannel.setMethodCallHandler(this);
  }

  onMethodCall(): void {
    // Receive messages from the Dart side.
  }

  public sendMessage = (method: string, data: string) => {

    this.methodChannel.invokeMethod(method, data);
  }

  getView(): WrappedBuilder<[Params]> {
    return new WrappedBuilder(PrivacyBuilder);
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

export default class PrivacyPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return 'PrivacyPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.
    registerViewFactory('com.example.flutter_login/privacyView', new CustomFactory(binding.getBinaryMessenger(),
      StandardMessageCodec.INSTANCE));
  }

  onDetachedFromEngine(): void {
  }
}