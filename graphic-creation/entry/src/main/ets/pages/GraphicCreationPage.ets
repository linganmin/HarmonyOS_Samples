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
// [Start collaboration_service_filter]
import {
  CollaborationServiceFilter,
  CollaborationServiceStateDialog,
  createCollaborationServiceMenuItems
} from '@kit.ServiceCollaborationKit';
// [End collaboration_service_filter]
import { CommonConstants } from '../common/CommonConstants';
import Logger from '../utils/Logger';
import { SelectedDataSource } from '../model/SelectedDataSource';
import { UIUtils } from '../utils/UIUtils';
import { FileUtils } from '../utils/FileUtils';
import { TitleBackView } from '../view/TitleBackView';
import { ListAddPictureView } from '../view/ListAddPictureView';
import { BreakpointType } from '../utils/BreakpointSystem';
import { DataUtils } from '../utils/DataUtils';
import { ImageInfo } from '../model/ContentInfo';
import { WaterFlowData } from '../model/WaterFlowDataSource';
import { fileUri } from '@kit.CoreFileKit';
import { AbilityConstant } from '@kit.AbilityKit';

@Entry
@Component
struct GraphicCreationPage {
  private readonly tag: string = 'GraphicCreationPage';
  @StorageLink(CommonConstants.BREAKPOINT_NAME) currentBreakpoint: string = CommonConstants.BREAKPOINT_SM;
  @StorageLink(CommonConstants.KEY_TITLE) title: string = '';
  @StorageLink(CommonConstants.KEY_DESCRIPTION) description: string = '';
  @StorageLink(CommonConstants.KEY_IMAGE_INFO) imageInfoArr: Array<ImageInfo> = [];
  @StorageLink(CommonConstants.KEY_RESTORE_IMAGE_INFO) @Watch('updateSelectedData') restore: Array<ImageInfo> = [];
  @State selectedData: SelectedDataSource = new SelectedDataSource();
  @State currentIndex: number = -1;
  @State categoryArr: Resource[] =
    [$r('app.string.category_1'), $r('app.string.category_2'), $r('app.string.category_3'),
      $r('app.string.category_4')];
  @State selectedUri: string[] = [];
  @State isShow: boolean = false;

  aboutToAppear() {
    UIUtils.setWindowFullScreen(DataUtils.context, true);
    UIUtils.setWindowBackGroundColor(DataUtils.context, CommonConstants.WHITE_COLOR);
    this.imageInfoArr.forEach((imageInfo: ImageInfo) => {
      this.selectedData.addData(imageInfo.imagePixelMap);
    });
  }

  // [Start continue_state]
  onPageShow(): void {
    DataUtils.context.setMissionContinueState(AbilityConstant.ContinueState.ACTIVE, (result) => {
      Logger.info('setMissionContinueState ACTIVE result: ', `${result.code}`);
    });
  }

  aboutToDisappear(): void {
    this.title = '';
    this.description = '';
    DataUtils.context.setMissionContinueState(AbilityConstant.ContinueState.INACTIVE, (result) => {
      Logger.info('setMissionContinueState INACTIVE result: ', `${result.code}`);
    });
  }

  // [End continue_state]

  updateSelectedData(key: string) {
    if (key === 'restore') {
      this.restore.forEach((imageInfo: ImageInfo) => {
        this.selectedData.addData(imageInfo.imagePixelMap);
      });
    }
  }

  build() {
    Flex(
      {
        direction: FlexDirection.Column,
        wrap: FlexWrap.NoWrap,
        justifyContent: FlexAlign.Start,
        alignItems: ItemAlign.Center,
        alignContent: FlexAlign.Center
      }
    ) {
      this.setCollaborationDialog();
      this.setTitle();
      Scroll() {
        Column() {
          this.setListAddPictureView();
          this.setCollaborationBtn();
          this.setTitleInput();
          this.ContentView();
        }
        .width($r('app.string.full_screen'))
        .margin({ top: $r('app.float.margin_24'), bottom: $r('app.float.margin_24') })
      }
      .width($r('app.string.full_screen'))

      this.NavigationTools();
    }
    .padding({
      top: $r('app.float.window_status_bar_height'),
      bottom: $r('app.float.window_navigation_bar_height')
    })
    .backgroundColor(Color.White)
    .width($r('app.string.full_screen'))
    .height($r('app.string.full_screen'))
  }

  // [Start set_collaboration_dialog]
  @Builder
  setCollaborationDialog() {
    CollaborationServiceStateDialog({
      onState: (stateCode: number, bufferType: string, buffer: ArrayBuffer): void => this.doInsertPicture(stateCode,
        bufferType, buffer)
    });
  }

  private doInsertPicture(stateCode: number, bufferType: string, buffer: ArrayBuffer): void {
    if (stateCode !== 0) {
      Logger.error(this.tag, `doInsertPicture stateCode: ${stateCode}}`);
      return;
    }
    Logger.info(this.tag, `doInsertPicture bufferType: ${bufferType}}`);
    if (bufferType === CommonConstants.BUFFER_TYPE) {
      if (this.imageInfoArr.length === CommonConstants.LIMIT_PICKER_NUM) {
        this.getUIContext().getPromptAction().showToast({
          message: $r('app.string.toast_picker_limit'),
          duration: DataUtils.fromResToNumber($r('app.float.show_DELAY_TIME')),
        });
        return;
      }
      let saveUri: string = FileUtils.saveFile(DataUtils.context, buffer);
      let imageInfo: ImageInfo | undefined = FileUtils.createPixelMap(saveUri);
      if (imageInfo) {
        this.imageInfoArr.unshift(imageInfo);
        this.selectedData.unshiftData(imageInfo.imagePixelMap);
        // copy file to distributedFilesDir
        FileUtils.copyFileToDestination(saveUri, DataUtils.context.distributedFilesDir);
      }
    }
  }

  // [End set_collaboration_dialog]

  @Builder
  setTitle() {
    TitleBackView({ title: $r('app.string.notes') })
      .backgroundColor(Color.White);
  }

  @Builder
  setListAddPictureView() {
    ListAddPictureView({
      currentIndex: this.currentIndex,
      selectedData: this.selectedData,
      itemSize: $r('app.float.size_114')
    })
      .width($r('app.string.full_screen'))
      .padding({
        left: $r('sys.float.ohos_id_elements_margin_horizontal_l'),
        right: $r('sys.float.ohos_id_elements_margin_horizontal_l')
      });
  }

  @Builder
  setCollaborationBtn() {
    Row() {
      Button($r('app.string.span_end'), { type: ButtonType.Normal, stateEffect: true })
        .borderRadius($r('sys.float.ohos_id_corner_radius_clicked'))
        .fontColor($r('sys.color.ohos_id_color_text_hyperlink'))
        .fontSize($r('sys.float.ohos_id_text_size_button3'))
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
        .height($r('app.float.finish_btn_height'))
        .bindMenu(this.isShow, this.CollaborationMenu(), {
          onDisappear: () => {
            this.isShow = false;
          }
        })
        .onClick(() => {
          if (this.imageInfoArr.length === CommonConstants.LIMIT_PICKER_NUM) {
            this.getUIContext().getPromptAction().showToast({
              message: $r('app.string.toast_picker_limit'),
              duration: DataUtils.fromResToNumber($r('app.float.show_DELAY_TIME')),
            });
          } else {
            this.isShow = true;
          }
        })
    }
    .alignItems(VerticalAlign.Center)
    .width($r('app.string.full_screen'))
    .padding({ left: $r('app.float.margin_16'), right: $r('app.float.margin_16'), })
    .margin({ top: $r('app.float.margin_24'), bottom: $r('app.float.margin_24') })
  }

  @Builder
  setTitleInput() {
    Row() {
      TextInput({ placeholder: $r('app.string.edit_hold_txt'), text: this.title })
        .maxLines(1)
        .fontSize($r('sys.float.ohos_id_text_size_headline9'))
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .placeholderFont({ size: $r('sys.float.ohos_id_text_size_headline9') })
        .placeholderColor($r('sys.color.ohos_id_color_text_tertiary'))
        .fontWeight(FontWeight.Medium)
        .backgroundColor(Color.White)
        .onChange((value: string) => {
          this.title = value;
        })
        .width($r('app.string.full_screen'))
    }.width($r('app.string.full_screen'))
    .alignItems(VerticalAlign.Center)
    .margin({ bottom: $r('app.float.margin_12') })
  }

  @Builder
  ContentView() {
    Row() {
      List({ space: DataUtils.fromResToNumber($r('app.float.space_12')) }) {
        ForEach(this.categoryArr, (item: Resource) => {
          ListItem() {
            this.getGrayButton(item)
          }
        }, (item: string) => item)
      }
      .scrollBar(BarState.Off)
      .listDirection(Axis.Horizontal)
      .edgeEffect(EdgeEffect.None)
      .width($r('app.string.full_screen'))
      .height($r('app.float.line_height_28'))
      .sticky(StickyStyle.Header)
      .cachedCount(this.categoryArr.length)
    }.alignItems(VerticalAlign.Center)
    .width($r('app.string.full_screen'))
    .padding({ left: $r('app.float.margin_16'), right: $r('app.float.margin_16'), })

    this.getLine();
    this.setTextAreaView();
    Row({ space: DataUtils.fromResToNumber($r('app.float.space_8')) }) {
      this.getGrayButton($r('app.string.topics'))
      this.getGrayButton($r('app.string.buddy'))
    }
    .width($r('app.string.full_screen'))
    .alignItems(VerticalAlign.Center)
    .padding({ left: $r('app.float.margin_16'), right: $r('app.float.margin_16') });

    this.getLine();
    Column() {
      this.getRowClickItem($r('app.media.ic_public_local'), $r('app.string.location'))
      this.getRowClickItem($r('app.media.ic_public_lock'), $r('app.string.visible'))
    }.margin({ left: $r('app.float.margin_16'), right: $r('app.float.margin_16') });

    this.getLine();
  }

  @Builder
  setTextAreaView() {
    Row() {
      TextArea({ placeholder: $r('app.string.edit_contents_hold_txt'), text: this.description })
        .fontSize($r('sys.float.ohos_id_text_size_button2'))
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('sys.color.ohos_id_color_text_primary'))
        .placeholderFont({ size: $r('sys.float.ohos_id_text_size_button2') })
        .placeholderColor($r('sys.color.ohos_id_color_text_tertiary'))
        .backgroundColor(Color.White)
        .onChange((value: string) => {
          this.description = value;
        })
        .align(Alignment.TopStart)
        .width($r('app.string.full_screen'))
        .height($r('app.float.text_area_height'))
    }.width($r('app.string.full_screen'))
    .margin({ bottom: $r('app.float.margin_12') })
  }

  @Builder
  NavigationTools() {
    Row({ space: DataUtils.fromResToNumber($r('app.float.space_16')) }) {
      Column({ space: DataUtils.fromResToNumber($r('app.float.space_2')) }) {
        Image($r('app.media.ic_public_drafts'))
          .objectFit(ImageFit.Fill)
          .width($r('app.float.icon_size_24'))
          .height($r('app.float.icon_size_24'))
        Text($r('app.string.save_drafts'))
          .fontSize($r('sys.float.ohos_id_text_size_caption1'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontColor($r('sys.color.ohos_id_color_text_secondary'))
          .fontWeight(FontWeight.Medium)
      }.margin({ left: $r('app.float.margin_16'), bottom: $r('app.float.margin_2') })

      Button($r('app.string.publish_notes'), { type: ButtonType.Normal, stateEffect: true })
        .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
        .fontColor(Color.White)
        .fontSize($r('app.float.font_size_15'))
        .fontWeight(FontWeight.Medium)
        .borderRadius($r('app.float.rounded_size_20'))
        .backgroundColor($r('sys.color.ohos_id_color_emphasize'))
        .width(new BreakpointType({
          sm: $r('app.float.publishes_btn_width'),
          md: $r('app.float.publishes_btn_width'),
          lg: $r('app.float.publishes_btn_width_lg'),
        }).getValue(this.currentBreakpoint))
        .onClick(() => {
          let uri: string = ''
          if (this.imageInfoArr.length > 0) {
            uri = fileUri.getUriFromPath(`${DataUtils.context.distributedFilesDir}/${this.imageInfoArr[0].imageName}`);
          }
          const waterFlowData: WaterFlowData = {
            coverPath: uri,
            descriptions: this.description,
            favorites: $r('app.string.favorites_number'),
            author: $r('app.string.author_2')
          }
          AppStorage.setOrCreate(CommonConstants.KEY_POST_CONTENT, waterFlowData);
          this.getUIContext().getRouter().back({
            url: 'pages/Index'
          });
          this.getUIContext().getRouter().clear();
        })
        .margin({ right: $r('app.float.margin_16') })
    }
    .margin({ right: $r('app.float.margin_16') })
    .width($r('app.string.full_screen'))
    .height($r('app.float.navigation_height_sm'))
    .backgroundColor(Color.White)
    .justifyContent(FlexAlign.Center)
  }

  // [Start collaboration_service_filter]
  @Builder
  CollaborationMenu() {
    Menu() {
      createCollaborationServiceMenuItems([CollaborationServiceFilter.ALL]);
    }
  }

  // [End collaboration_service_filter]

  @Builder
  getLine() {
    Row() {
      Divider()
        .strokeWidth(DataUtils.fromResToNumber($r('app.float.divider_height')))
        .color($r('sys.color.ohos_id_color_sub_background'))
    }
    .padding({ left: $r('app.float.margin_16'), right: $r('app.float.margin_16'), })
    .margin({ top: $r('app.float.margin_12'), bottom: $r('app.float.margin_12') })
  }

  @Builder
  getGrayButton(txt: Resource) {
    Button(txt, { type: ButtonType.Normal, stateEffect: true })
      .fontFamily($r('sys.string.ohos_id_text_font_family_regular'))
      .fontColor($r('sys.color.ohos_id_color_text_tertiary'))
      .fontSize($r('app.float.font_size_12'))
      .borderRadius($r('sys.float.ohos_id_corner_radius_default_l'))
      .backgroundColor($r('sys.color.ohos_id_color_button_normal'))
      .height($r('app.float.line_height_28'))
  }

  @Builder
  getRowClickItem(img: Resource, txt: Resource) {
    Row() {
      Row({ space: DataUtils.fromResToNumber($r('app.float.space_8')) }) {
        Image(img)
          .objectFit(ImageFit.Fill)
          .fillColor(Color.Black)
          .width($r('app.float.font_size_16'))
          .height($r('app.float.font_size_16'))
        Text(txt)
          .fontSize($r('sys.float.ohos_id_text_size_button2'))
          .fontFamily($r('sys.string.ohos_id_text_font_family_medium'))
          .fontColor($r('sys.color.ohos_id_color_text_primary'))
          .fontWeight(FontWeight.Medium)
      }

      Blank()
      Image($r('app.media.ic_public_arrow_right'))
        .objectFit(ImageFit.Fill)
        .width($r('app.float.font_size_16'))
        .height($r('app.float.font_size_16'))
    }
    .width($r('app.string.full_screen'))
    .height($r('app.float.title_height_44'))
    .justifyContent(FlexAlign.SpaceBetween)
  }
}