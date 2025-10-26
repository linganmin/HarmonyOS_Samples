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

import { HMRouter, HMRouterMgr, HMLifecycle, HMLifecycleContext, IHMLifecycle } from '@hadss/hmrouter';
import { CsvFileUtil, MediaTools } from '@ohos/mediaservice';
import { AppStore } from '../common/store/AppStore';
import { SceneOption } from '../common/store/Score';
import { setBorder } from '../common/utils/ListBorder';
import { GenerateFile } from '../common/utils/GenerateFileTips';
import { DataConfig } from '../common/store/DataInterface';

export interface AnalyticalInfo {
  sceneName: string;
  isRequired: boolean;
  isDetected: boolean;
  isFullScore: boolean;
  adviseLink: string;
}

@HMLifecycle({ lifecycleName: 'ScorePageLifecycle' })
export class SceneCheckLifecycle implements IHMLifecycle {
  onBackPressed(ctx: HMLifecycleContext): boolean {
    AppStore.getInstance().currentSceneIndex--;
    return false;
  }
}

@HMRouter({ pageUrl: 'ScorePage', singleton: true, lifecycle: 'ScorePageLifecycle' })
@Component
export struct ScorePage {
  @StorageLink('configSource') @Watch('configSourceChange') configSource: Array<DataConfig> | undefined =
    AppStorage.get('configSource')!;
  @State requiredSceneInfo: Array<AnalyticalInfo> = [];
  @State recommendSceneInfo: Array<AnalyticalInfo> = [];
  scroller: Scroller = new Scroller();
  private score: string = '';
  private acquiredScore: number = 0;
  private totalScore: number = 0;
  private tableData: Array<Array<string>> = [];
  private csvFileUtil: CsvFileUtil | undefined = undefined;
  private dialogController: CustomDialogController = new CustomDialogController({
    builder: GenerateFile({
      cancel: () => {
        this.onCancel();
      },
      confirm: () => {
        this.onConfirm();
      }
    })
  });

  async initData() {
    const sceneOption: Array<SceneOption> = AppStore.getInstance().optionRecord;
    this.requiredSceneInfo = [];
    this.recommendSceneInfo = [];
    this.acquiredScore = 0;
    this.totalScore = 0;

    for (let i = 0; i < sceneOption.length; i++) {
      let currentSceneInfo: AnalyticalInfo = {
        sceneName: this.configSource![i].sceneName,
        isRequired: this.configSource![i].required,
        isDetected: !sceneOption[i].isSkiped,
        isFullScore: sceneOption[i].score === this.configSource![i].highestScore,
        adviseLink: this.configSource![i].adviceLink[0],
      };
      if (this.configSource![i].required) {
        this.requiredSceneInfo.push(currentSceneInfo);
        if (!sceneOption[i].isSkiped) {
          this.acquiredScore += sceneOption[i].score;
        }
        this.totalScore += this.configSource![i].highestScore;
      } else {
        this.recommendSceneInfo.push(currentSceneInfo);
        if (!sceneOption[i].isSkiped) {
          this.acquiredScore += sceneOption[i].score;
          this.totalScore += this.configSource![i].highestScore;
        }
      }
    }
    this.score = Math.floor(this.acquiredScore / this.totalScore * 100) + '';
  }

  configSourceChange() {
    this.initData();
  }

  aboutToAppear(): void {
    this.initData();
  }

  setImageSource(item: AnalyticalInfo) {
    if (item.isDetected && item.isFullScore) {
      return $r('app.media.right');
    } else if (!item.isRequired && !item.isDetected) {
      return $r('app.media.skip');
    } else {
      return $r('app.media.error');
    }
  }

  onCancel() {
    this.getUIContext().getPromptAction().showToast({ message: $r('app.string.export_cancel') });
  }

  async generateTableData() {
    const sceneOption: Array<SceneOption> = AppStore.getInstance().optionRecord;
    this.tableData = [];
    const csvTitle = await Promise.all([
      MediaTools.getStringFromResource('scene'),
      MediaTools.getStringFromResource('operation'),
      MediaTools.getStringFromResource('sub_scene'),
      MediaTools.getStringFromResource('recommended_performance'),
      MediaTools.getStringFromResource('actual_performance'),
      MediaTools.getStringFromResource('optimization_suggestions')
    ]);
    const connectText =
      `${await MediaTools.getStringFromResource('csv_generate_semicolon')}${await MediaTools.getStringFromResource('csv_generate_reference_guide')}`;

    for (let i = 0; i < sceneOption.length; i++) {
      let temp: Array<string>;
      const scene: string = this.configSource![i].sceneName;
      const isDetected = sceneOption[i].isSkiped ? await MediaTools.getStringFromResource('csv_generate_skiped') :
        await MediaTools.getStringFromResource('csv_generate_completed');
      let subScene: string, bestExperience: string, curExperience: string, advise: string;

      if (this.configSource![i].steps.length > 1) {
        for (let j = 0; j < this.configSource![i].steps.length; j++) {
          subScene = this.configSource![i].steps[j].text;
          bestExperience = this.configSource![i].steps[j].options[0].text;
          if (!sceneOption[i].isSkiped && sceneOption[i].optionIndex[j] !== undefined &&
            this.configSource![i]?.steps[j]?.options[sceneOption[i].optionIndex[j]]?.text) {
            curExperience = this.configSource![i].steps[j].options[sceneOption[i].optionIndex[j]].text;
          } else {
            curExperience = await MediaTools.getStringFromResource('csv_generate_skiped');
          }
          advise =
            sceneOption[i].optionIndex[j] === 0 && !sceneOption[i].isSkiped ?
              await MediaTools.getStringFromResource('csv_generate_none') :
              `${this.configSource![i].optimization}${connectText}${this.configSource![i].adviceLink.join(';')}`;
          temp = [scene, isDetected, subScene, bestExperience, curExperience, advise];
          this.tableData.push(temp);
        }
      } else {
        subScene = await MediaTools.getStringFromResource('csv_generate_none');
        bestExperience = this.configSource![i].steps[0].options[0].text;
        if (!sceneOption[i].isSkiped && sceneOption[i].optionIndex[0] !== undefined &&
          this.configSource![i]?.steps[0]?.options[sceneOption[i].optionIndex[0]]?.text) {
          curExperience = this.configSource![i].steps[0].options[sceneOption[i].optionIndex[0]].text;
        } else {
          curExperience = await MediaTools.getStringFromResource('csv_generate_skiped');
        }
        advise =
          sceneOption[i].optionIndex[0] === 0 && !sceneOption[i].isSkiped ?
            await MediaTools.getStringFromResource('csv_generate_none') :
            `${this.configSource![i].optimization}${connectText}${this.configSource![i].adviceLink.join(';')}`;
        temp = [scene, isDetected, subScene, bestExperience, curExperience, advise];
        this.tableData.push(temp);
      }
    }
    this.tableData.unshift(csvTitle);
  }

  async onConfirm() {
    let filename = 'test' + new Date().getTime() + '.txt';
    this.csvFileUtil = new CsvFileUtil(filename);
    await this.csvFileUtil.getCsvPath();
    await this.generateTableData();
    await this.csvFileUtil.writeDataToCsv(this.tableData);
    await this.csvFileUtil.exportCsvFile();
    await this.csvFileUtil.closeWriteData();
  }

  build() {
    Column() {
      Scroll(this.scroller) {
        Column() {
          Image($r('app.media.trophy'))
            .width('100%')
            .height(227)
            .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

          Column() {
            Text() {
              Span($r('app.string.score_congratulations'));
              Span(this.score);
            }
            .fontSize(30)
            .fontWeight(700);
          }
          .width('100%')
          .margin({
            top: 24,
            bottom: 16
          })
          .padding({
            left: 20,
            right: 20
          });

          Column() {
            Text($r('app.string.score_required_scene'))
              .fontSize(14)
              .lineHeight(24)
              .fontWeight(700)
              .width('100%')
              .margin({ bottom: 16 });

            ForEach(this.requiredSceneInfo, (item: AnalyticalInfo, index: number) => {
              Row() {
                Image(this.setImageSource(item))
                  .width(20)
                  .height(20)
                  .margin({
                    left: 2,
                    right: 14
                  });
                Text() {
                  Span(item.sceneName)
                    .fontColor($r('app.color.text'))
                    .opacity(0.9);
                  if (!item.isDetected || !item.isFullScore) {
                    Span($r('app.string.score_comma'))
                      .fontColor($r('app.color.text'))
                      .opacity(0.9);
                    Span($r('app.string.optimization_suggestions'))
                      .fontColor($r('app.color.primary_button'))
                      .onClick(() => {
                        HMRouterMgr.push({
                          pageUrl: 'SceneAdvice',
                          param: index,
                        });
                      });
                  }
                }
                .fontSize(14)
                .lineHeight(19)
                .layoutWeight(1)
                .textAlign(TextAlign.Start);
              }
              .width('100%')
              .padding({
                top: 12,
                bottom: 12
              })
              .border(setBorder(index, this.requiredSceneInfo.length - 1));
            }, (item: AnalyticalInfo) => item.sceneName.toString());

            Text($r('app.string.score_recommended_scene'))
              .fontSize(14)
              .lineHeight(24)
              .fontWeight(700)
              .width('100%')
              .margin({
                top: 18,
                bottom: 16
              });

            ForEach(this.recommendSceneInfo, (item: AnalyticalInfo, index: number) => {
              Row() {
                Image(this.setImageSource(item))
                  .width(20)
                  .height(20)
                  .margin({
                    left: 2,
                    right: 14
                  });
                Text() {
                  Span(item.sceneName)
                    .fontColor($r('app.color.text'))
                    .opacity(0.9);
                  if (!item.isDetected || !item.isFullScore) {
                    Span($r('app.string.score_comma'))
                      .fontColor($r('app.color.text'))
                      .opacity(0.9);
                    Span($r('app.string.optimization_suggestions'))
                      .fontColor($r('app.color.primary_button'))
                      .onClick(() => {
                        HMRouterMgr.push({
                          pageUrl: 'SceneAdvice',
                          param: index + 3,
                        });
                      });
                  }
                }
                .fontSize(14)
                .lineHeight(19)
                .layoutWeight(1)
                .textAlign(TextAlign.Start);
              }
              .width('100%')
              .padding({
                top: 8,
                bottom: 12
              })
              .border(setBorder(index, this.recommendSceneInfo.length - 1));
            }, (item: AnalyticalInfo) => item.sceneName.toString());
          }
          .padding({
            left: 20,
            right: 20
          })
          .width('100%');
        }
        .width('100%')
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);
      }
      .scrollable(ScrollDirection.Vertical)
      .scrollBar(BarState.Off)
      .layoutWeight(1)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP]);

      Row() {
        Button($r('app.string.export_report'), { type: ButtonType.Capsule, stateEffect: false })
          .width('48%')
          .height(40)
          .onClick(() => {
            this.dialogController.open();
          });
        Button($r('app.string.export_log_guide'), { type: ButtonType.Capsule, stateEffect: false })
          .width('48%')
          .height(40)
          .fontColor($r('app.color.primary_button'))
          .backgroundColor('rgba(0, 0, 0, 0.05)')
          .onClick(() => {
            HMRouterMgr.push({
              pageUrl: 'ExportLog'
            });
          });
      }
      .width('100%')
      .padding({
        top: 10,
        left: 20,
        right: 20
      })
      .justifyContent(FlexAlign.SpaceBetween);
    }
    .justifyContent(FlexAlign.SpaceBetween)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM]);
  }
}