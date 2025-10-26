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

import Constants from '../constants/Constants';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

@Component
export struct VotingComponent {
  @State notice: ResourceStr = $r('app.string.voting_notice');
  @State leftOptionWidth: string = Constants.HALF_PERCENT;
  @State rightOptionWidth: string = Constants.HALF_PERCENT;
  @State isClick: boolean = false;
  @State points: number[][] = Constants.BEGIN_POINTS;
  @State fillOpacity: number = Constants.BEGIN_FILL_OPACITY;
  leftOptionChoose: number = Constants.LEFT_COUNT;
  rightOptionChoose: number = Constants.RIGHT_COUNT;
  animateParam: AnimateParam = {
    duration: Constants.ANIMATE_DURATION,
    curve: Curve.EaseOut
  };

  changeState(option: string) {
    this.isClick = true;
    this.notice = `${$r('app.string.result_notice')}'${option}'`;
    this.fillOpacity = Constants.END_FILL_OPACITY;
    const leftOptionPercent: number =
      this.leftOptionChoose / (this.leftOptionChoose + this.rightOptionChoose) * Constants.PERCENTAGE;
    this.getUIContext().animateTo(this.animateParam, () => {
      this.leftOptionWidth = leftOptionPercent.toFixed(0) + '%';
      this.rightOptionWidth = (Constants.PERCENTAGE - leftOptionPercent).toFixed(0) + '%';
      this.points = Constants.END_POINTS;
    });
  }

  build() {
    Column() {
      Flex({
        direction: FlexDirection.Row,
        justifyContent: FlexAlign.Start
      }) {
        Image($r('app.media.ic_voting_component_avatars'))
          .width($r('app.integer.voting_component_voting_theme_image_width'))
          .height($r('app.integer.voting_component_voting_theme_image_height'))
          .margin({
            left: $r('app.integer.voting_component_voting_theme_image_margin_left'),
            right: $r('app.integer.voting_component_voting_theme_image_margin_right')
          })
        Text($r('app.string.voting_component_voting_theme_image_text'))
          .fontSize($r('app.integer.voting_component_voting_theme_image_text_font_size'))
      }

      Stack() {
        Flex({
          direction: FlexDirection.Row,
          justifyContent: FlexAlign.Center
        }) {
          Stack() {
            Column()
              .borderRadius({
                topLeft: $r('app.integer.voting_component_fillet_radius'),
                bottomLeft: $r('app.integer.voting_component_fillet_radius'),
                topRight: $r('app.integer.voting_component_right_angle_radius'),
                bottomRight: $r('app.integer.voting_component_right_angle_radius')
              })
              .backgroundColor(Constants.LEFT_COLOR)
              .opacity(this.fillOpacity)
              .width(this.leftOptionWidth)
              .height($r('app.integer.voting_component_option_background_height'))
            Stack() {
              if (!this.isClick) {
                Text($r('app.string.left_option'))
                  .fontColor(Color.White)
                  .margin({ right: $r('app.integer.voting_component_text_center_margin') })
              } else {
                Column() {
                  Text(this.leftOptionWidth)
                    .fontColor(Constants.LEFT_COLOR)
                    .fontSize($r('app.integer.voting_component_upper_text_font_size'))
                  Text($r('app.string.left_option'))
                    .fontColor(Constants.LEFT_COLOR)
                    .fontSize($r('app.integer.voting_component_under_text_font_size'))
                }
              }
            }
          }.onClick(() => {
            if (this.isClick) {
              return;
            }
            this.leftOptionChoose++;
            this.changeState(this.resourceToString($r('app.string.left_option')));
          })

          Stack() {
            Column()
              .borderRadius({
                topLeft: $r('app.integer.voting_component_right_angle_radius'),
                bottomLeft: $r('app.integer.voting_component_right_angle_radius'),
                topRight: $r('app.integer.voting_component_fillet_radius'),
                bottomRight: $r('app.integer.voting_component_fillet_radius')
              })
              .backgroundColor(Constants.RIGHT_COLOR)
              .opacity(this.fillOpacity)
              .width(this.rightOptionWidth)
              .height($r('app.integer.voting_component_option_background_height'))
            Stack() {
              if (!this.isClick) {
                Text($r('app.string.right_option'))
                  .fontColor(Color.White)
                  .margin({ left: $r('app.integer.voting_component_text_center_margin') })
              } else {
                Column() {
                  Text(this.rightOptionWidth)
                    .fontColor(Constants.RIGHT_COLOR)
                    .fontSize($r('app.integer.voting_component_upper_text_font_size'))
                  Text(this.resourceToString($r('app.string.right_option')))
                    .fontColor(Constants.RIGHT_COLOR)
                    .fontSize($r('app.integer.voting_component_under_text_font_size'))
                }
              }
            }
          }.onClick(() => {
            if (this.isClick) {
              return;
            }
            this.rightOptionChoose++;
            this.changeState(this.resourceToString($r('app.string.right_option')));
          })
        }

        Stack() {
          Polygon()
            .points(this.points)
            .fill(Color.White)
            .stroke(Color.White)
            .antiAlias(true)
            .width($r('app.integer.voting_component_polygon_width'))
            .height($r('app.integer.voting_component_polygon_height'))
          Stack() {
            if (!this.isClick) {
              Text() {
                Span($r('app.string.voting_component_mid_text_left'))
                  .fontColor(Constants.LEFT_COLOR)
                Span($r('app.string.voting_component_mid_text_right'))
                  .fontColor(Constants.RIGHT_COLOR)
              }
              .fontSize($r('app.integer.voting_component_mid_text_font_size'))
              .fontStyle(FontStyle.Italic)
              .fontWeight(Constants.MID_TEXT_FONT_WEIGHT)
              .textAlign(TextAlign.Center)
            }
          }
        }
        .position({ x: this.leftOptionWidth })
        .markAnchor({ x: $r('app.string.voting_component_mid_gap_mark_anchor') })
      }
      .width($r('app.string.voting_component_parent_column_width'))

      Flex({ direction: FlexDirection.Row, justifyContent: FlexAlign.SpaceBetween }) {
        Text(this.notice)
          .fontSize($r('app.integer.voting_component_bottom_text_font_size'))
        Stack() {
          if (this.isClick) {
            Text(this.leftOptionChoose + this.rightOptionChoose +
            this.resourceToString($r('app.string.bottom_text_suffix')))
              .fontSize($r('app.integer.voting_component_bottom_text_font_size'))
          }
        }
      }
    }
    .height($r('app.string.voting_component_parent_column_height'))
    .width($r('app.string.voting_component_parent_column_width'))
    .padding($r('app.integer.voting_component_padding_top'))
    .justifyContent(FlexAlign.Start)
  }

  resourceToString(resource: Resource): string {
    let result = '';
    try {
      result = this.getUIContext().getHostContext()!.resourceManager.getStringSync(resource.id);
    } catch (err) {
      let error = err as BusinessError;
      hilog.error(0x0000, 'VotingComponent',
        `getStringSync failed. error code=${error.code}, message=${error.message}`);
    }
    return result;
  }
}

@Builder
export function getPageVotingComponent(name: string): void {
  if (name === 'VotingComponent') {
    NavDestination() {
      VotingComponent()
    }
  }
}

export const wrappedBuilderVotingComponent: WrappedBuilder<[string, number]> = wrapBuilder(getPageVotingComponent);