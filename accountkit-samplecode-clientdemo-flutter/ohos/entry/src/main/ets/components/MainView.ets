/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 * */
import MethodChannel, { MethodCallHandler } from '@ohos/flutter_ohos/src/main/ets/plugin/common/MethodChannel';
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
import { dealAllError, getQuickLoginAnonymousPhone } from '../common/Utils';

const logTag: string = 'MainComponent';
const domainId: number = 0x0000;

@Component
export struct MainComponent {
  @Prop params: Params
  customView: CustomView = this.params?.platformView as CustomView
  cards: number[] = [72, 144, 88, 192];
  loginData?: Record<string, Object>;
  loading: boolean = false;
  @StorageProp('statusBarHeight') statusBarHeight: number = 36;

  aboutToAppear() {
    hilog.info(domainId, logTag, 'aboutToAppear');
  }

  // Redirect to LoginPage.
  private async jumpToLoginPage() {
    if (this.loading) {
      return;
    }
    this.loading = true;
    try {
      const quickLoginAnonymousPhone = await getQuickLoginAnonymousPhone();
      hilog.info(domainId, logTag, `quickLoginAnonymousPhone is ${quickLoginAnonymousPhone}.`);
      if (quickLoginAnonymousPhone !== '') {
        hilog.info(domainId, logTag, 'Go to LoginPage');
        this.customView.sendMessage('jumpToLoginPage', '跳转到登录页面');
      } else {
        throw new Error('Failed to get quickLoginAnonymousPhone.');
      }
    } catch (err) {
      dealAllError(err);
    } finally {
      const timer = setTimeout(() => {
        this.loading = false;
        clearTimeout(timer);
      }, 300)
    }
  }

  @Builder
  Unit(active: boolean = false) {
    Column() {
      Image(active ? $r('app.media.ic_me') : $r('app.media.ic_me_normal'))
        .width(21)
        .height(21)
        .borderRadius('50%')
        .draggable(false)

      Text('Tab')
        .fontSize(10)
        .lineHeight(13)
        .fontWeight(FontWeight.Regular)
        .fontColor(active ? '#' : $r('sys.color.ohos_id_color_text_secondary'))
        .textAlign(TextAlign.Center)
    }
    .alignItems(HorizontalAlign.Center)
    .width('25%')
    .height(52)
    .padding({
      top: 5,
      bottom: 5
    })
    .backgroundColor(Color.Transparent)
  }

  @Builder
  NavBar() {
    Flex({
      direction: FlexDirection.Row,
      justifyContent: FlexAlign.Center
    }) {
      this.Unit()
      this.Unit()
      this.Unit()
      this.Unit(true)
    }
    .shadow({
      type: ShadowType.COLOR,
      color: '#ff807b7b',
      offsetX: 0,
      offsetY: 0,
      fill: true
    } as ShadowOptions)
    .width('100%')
    .height(80)
    .alignSelf(ItemAlign.Center)
    .backgroundColor($r('sys.color.ohos_id_color_sub_background'))
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Flex({
        direction: FlexDirection.Column,
        justifyContent: FlexAlign.SpaceAround,
        alignItems: ItemAlign.Start
      }) {
        Column() {
          Row() {
            Row() {
              Image($r('app.media.avatar'))
                .borderRadius(28)
                .width(56)
                .height(56)
                .margin(12)
                .draggable(false)
              Column() {
                Row() {
                  Text($r('app.string.login'))
                    .fontFamily('HarmonyHeiTi')
                    .fontWeight(FontWeight.Bold)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_sub_title1'))
                    .height(24)
                }

                Row() {
                  Text($r('app.string.login_for_enjoy_service'))
                    .fontFamily('HarmonyHeiTi')
                    .fontWeight(FontWeight.Regular)
                    .fontColor($r('sys.color.ohos_id_color_text_primary'))
                    .fontSize($r('sys.float.ohos_id_text_size_body2'))
                    .height(18)
                }
              }
              .alignItems(HorizontalAlign.Start)
            }
            .id('dearUserOrLoginRow')
            .onClick(() => {
              this.jumpToLoginPage();
            })
          }
          .width('100%')
          .padding({
            top: 12 + this.statusBarHeight,
            right: 16,
            bottom: 12,
            left: 16
          })

          Scroll() {
            Column() {
              ForEach(this.cards, (item: number) => {
                Card(item)
              }, (item: number, index: number) => `${item}_${index}`)
            }
            .height('100%')
            .constraintSize({
              minHeight: this.cards.reduce((prevResult: number, current: number) => prevResult + current + 12, 2)
            })
            .width('100%')
          }
          .padding({
            left: 16,
            right: 16
          })
          .width('100%')
          .layoutWeight(1)
        }
        .layoutWeight(1)
        .backgroundColor($r('sys.color.ohos_id_color_sub_background'))

        this.NavBar()
      }
    }

  }
}

@Builder
function Card(cardHeight: number) {
  Row()
    .margin({ bottom: 12 })
    .padding({ left: 16, right: 16 })
    .height(cardHeight)
    .backgroundColor($r('sys.color.ohos_fa_list_card_bg'))
    .borderRadius(20)
    .width('100%')
}

@Builder
function MainBuilder(params: Params) {
  MainComponent({ params: params });
}


@Observed
class CustomView extends PlatformView implements MethodCallHandler {
  methodChannel: MethodChannel;
  index: number = 1;

  constructor(context: common.Context, viewId: number, args: ESObject, message: BinaryMessenger) {
    super();
    // Register the message channel.
    this.methodChannel =
      new MethodChannel(message, `com.example.flutter_login/mainView${viewId}`, StandardMethodCodec.INSTANCE);
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
    return new WrappedBuilder(MainBuilder);
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

export default class MainPlugin implements FlutterPlugin {
  getUniqueClassName(): string {
    return 'MainPlugin';
  }

  onAttachedToEngine(binding: FlutterPluginBinding): void {
    binding.getPlatformViewRegistry()?.
    registerViewFactory('com.example.flutter_login/mainView', new CustomFactory(binding.getBinaryMessenger(),
      StandardMessageCodec.INSTANCE));
  }

  onDetachedFromEngine(): void {
  }
}