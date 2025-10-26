import { CommonConstants as Const } from 'common';
import { AchievementStore } from '../viewmodel/AchievementStore';
import { openAchievementCustomDialog } from './dialog/AchievementDialog';
import { AchievementItem, AchievementList } from '../model/AchievementModel';

@Component
export struct AchievementComponent {
  @Consume achievementStore: AchievementStore;

  build() {
    Column() {
      Text($r('app.string.my_achievement'))
        .fontFamily($r(Const.HARMONY_HEI_TI_MEDIUM))
        .fontWeight(FontWeight.Regular)
        .fontColor($r(`sys.color.font_primary`))
        .fontSize($r('app.float.default_24'))
        .width(Const.THOUSANDTH_1000)
        .height($r('app.float.default_56'))
        .padding({
          left: Const.THOUSANDTH_66
        })

      Flex({
        direction: FlexDirection.Row,
        wrap: FlexWrap.Wrap
      }) {
        ForEach(AchievementList, (item: AchievementItem, index: number) => {
          this.achievementBuilder(index, item)
        }, (item: AchievementItem, index: number) => index + JSON.stringify(item))
      }
      .width(Const.THOUSANDTH_1000)
    }
    .width(Const.THOUSANDTH_1000)
    .height(Const.THOUSANDTH_1000)
    .backgroundColor($r('sys.color.background_fourth'))
    .justifyContent(FlexAlign.Start)
    .padding({
      left: $r('app.float.default_10'),
      right: $r('app.float.default_10'),
      bottom: $r('app.float.default_10')
    })
  }

  @Builder
  achievementBuilder(index: number, item: AchievementItem) {
    Column({
      space: $r('app.float.default_18')
    }) {
      Image(item.level <= this.achievementStore.maxConsecutiveDays ? item.iconOn : item.iconOff)
        .width(Const.THOUSANDTH_1000)
        .height($r('app.float.default_88'))
        .objectFit(ImageFit.Contain)

      Text($r('app.string.achievement_level', item.name))
        .lineHeight($r('app.float.default_16'))
        .fontSize($r('app.float.default_12'))
        .fontColor($r(`sys.color.font_primary`))
    }
    .width(Const.THOUSANDTH_333)
    .padding({
      top: $r('app.float.default_38'),
      bottom: $r('app.float.default_10')
    })
    .onClick(() => {
      if (item.level <= this.achievementStore.maxConsecutiveDays) {
        openAchievementCustomDialog(this.getUIContext(), index);
      }
    })
  }
}