/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2024-2024. All rights reserved.
 */
import { systemShare } from '@kit.ShareKit';
import FormItem from './FormItem';

@Component
export default struct ShareControllerOptions {
  @Link previewMode: systemShare.SharePreviewMode;
  @Link selectionMode: systemShare.SelectionMode;
  @Link excludedAbilities: Array<systemShare.ShareAbilityType>;

  @State isShowExcludedAbilitiesSheet: boolean = false;

  @Builder
  PreviewModeBuilder() {
    Row() {
      Row() {
        Radio({ value: 'DEFAULT', group: 'PreviewMode' })
          .checked(this.previewMode === systemShare.SharePreviewMode.DEFAULT)
          .onChange((isChecked) => {
            if (isChecked) {
              this.previewMode = systemShare.SharePreviewMode.DEFAULT;
            }
          })
        Text('DEFAULT')
      }
      .margin({ right: 20 })
      Row() {
        Radio({ value: 'DETAIL', group: 'PreviewMode' })
          .checked(this.previewMode === systemShare.SharePreviewMode.DETAIL)
          .onChange((isChecked) => {
            if (isChecked) {
              this.previewMode = systemShare.SharePreviewMode.DETAIL;
            }
          })
        Text('DETAIL')
      }
    }
  }

  @Builder
  SelectionModeBuilder() {
    Row() {
      Row() {
        Radio({ value: 'SINGLE', group: 'SelectionMode' })
          .checked(this.selectionMode === systemShare.SelectionMode.SINGLE)
          .onChange((isChecked) => {
            if (isChecked) {
              this.selectionMode = systemShare.SelectionMode.SINGLE;
            }
          })
        Text('SINGLE')
      }
      .margin({ right: 20 })
      Row() {
        Radio({ value: 'BATCH', group: 'SelectionMode' })
          .checked(this.selectionMode === systemShare.SelectionMode.BATCH)
          .onChange((isChecked) => {
            if (isChecked) {
              this.selectionMode = systemShare.SelectionMode.BATCH;
            }
          })
        Text('BATCH')
      }
    }
  }

  @Builder
  ExcludedAbilitiesItem(name: string, value: systemShare.ShareAbilityType) {
    Row() {
      Text(name);
      Checkbox({ name: name, group: 'ExcludedAbilities' })
        .shape(CheckBoxShape.ROUNDED_SQUARE)
        .select(this.excludedAbilities.includes(value))
        .onChange((checked: boolean) => {
          if (checked) {
            this.excludedAbilities.push(value);
          } else {
            this.excludedAbilities = this.excludedAbilities.filter((item) => {
              return item !== value;
            })
          }
        })
    }
    .width('100%')
    .height(40)
    .alignItems(VerticalAlign.Center)
    .justifyContent(FlexAlign.SpaceBetween)
  }

  @Builder
  ExcludedAbilitiesSheet() {
    Flex({ direction: FlexDirection.Column }) {
      Column() {
        this.ExcludedAbilitiesItem('COPY_TO_PASTEBOARD', systemShare.ShareAbilityType.COPY_TO_PASTEBOARD);
        this.ExcludedAbilitiesItem('SAVE_TO_MEDIA_ASSET', systemShare.ShareAbilityType.SAVE_TO_MEDIA_ASSET);
        this.ExcludedAbilitiesItem('SAVE_AS_FILE', systemShare.ShareAbilityType.SAVE_AS_FILE);
        this.ExcludedAbilitiesItem('PRINT', systemShare.ShareAbilityType.PRINT);
        this.ExcludedAbilitiesItem('SAVE_TO_SUPERHUB', systemShare.ShareAbilityType.SAVE_TO_SUPERHUB);
      }
      .width('100%')
      .flexGrow(1)
      .padding({ left: 20, right: 20 })

      Column() {
        Button($r('app.string.confirm'))
          .width('100%')
          .height(40)
          .onClick(() => this.isShowExcludedAbilitiesSheet = false)
      }
      .height(100)
      .padding({ top: 10, left: 20, right: 20 })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  ExcludedAbilitiesBuilder() {
    Button(this.excludedAbilities.length <= 0 ? $r('app.string.select') : $r('app.string.selected'))
      .bindSheet($$this.isShowExcludedAbilitiesSheet, this.ExcludedAbilitiesSheet, {
        height: SheetSize.MEDIUM,
        showClose: false,
        title: {
          title: $r('app.string.select')
        }
      })
      .onClick(() => this.isShowExcludedAbilitiesSheet = true)
  }

  build() {
    Column() {
      FormItem({ label: 'previewMode', content: (): void => this.PreviewModeBuilder()});
      FormItem({ label: 'selectionMode', content: (): void => this.SelectionModeBuilder()});
      FormItem({ label: 'excludedAbilities', content: (): void => this.ExcludedAbilitiesBuilder()});
    }
    .height(260)
    .padding({ left: 20, right: 20 })
  }
}