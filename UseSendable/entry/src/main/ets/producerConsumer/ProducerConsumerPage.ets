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

import { BusinessError } from '@kit.BasicServicesKit';
import { taskpool } from '@kit.ArkTS';
import { ConsumerTask, ProducerLongTask, ProducerTask } from './tasks/ProducerTask';
import { LogLevelEnum, LongTaskCommandEnum } from './model/CommEnum';
import { LongTaskController } from './model/LongTaskController';
import { Constants } from '../constants/Constants';
import { ShareQueue } from './model/ShareQueue';
import { LogInfo } from './model/LogInfo';
import Logger from '../utils/Logger';

@Component
export struct ProducerConsumerPage {
  private consumerOne?: taskpool.LongTask;
  private consumerTwo?: taskpool.LongTask;
  private producer?: taskpool.Task;
  private producerLong: taskpool.LongTask | null = null;
  private consumerControllerOne: LongTaskController = new LongTaskController();
  private consumerControllerTwo: LongTaskController = new LongTaskController();
  private producerController: LongTaskController = new LongTaskController();
  private sq: ShareQueue<LogInfo> = new ShareQueue<LogInfo>();
  @State logInfo: string = '';
  @State logNumber: number = 1;

  getResourceString(resource: Resource): string {
    let resourceString: string = '';
    try {
      resourceString = this.getUIContext().getHostContext()?.resourceManager.getStringSync(resource.id) as string;
    } catch (error) {
      Logger.error('getResourceString err:' + JSON.stringify(error));
    }
    return resourceString;
  }

  private startConsumer(taskName: string, consumer: taskpool.LongTask, lct: LongTaskController): void {
    lct.command = LongTaskCommandEnum.START;
    consumer = new taskpool.Task(taskName, ConsumerTask, taskName, this.sq, lct);
    consumer.onReceiveData(async (logInfo: LogInfo) => {
      let log = this.logNumber + ':\t' + taskName + ':' + logInfo.logMsg + '\n';
      this.logInfo = log + this.logInfo;
      this.logNumber++;
    });
    taskpool.execute(consumer).then(() => {
      Logger.info('terminateTask' + taskName);
      taskpool.terminateTask(consumer);
    }).catch((err: BusinessError) => {
      Logger.error(`Execute failed. Cause code: ${err.code}, message: ${err.message}`);
    });
  }

  @Styles
  buttonStyles() {
    .width(Constants.FULL_PERCENT)
    .height($r('app.integer.comm_button_height'))
    .margin({ bottom: $r('app.integer.comm_padding_margin12') })
  }

  build() {
    NavDestination() {
      Column() {
        Row() {
          TextArea({ text: this.logInfo })
            .focusable(false)
            .height($r('app.integer.text_area_height'))
            .width(Constants.FULL_PERCENT)
            .alignSelf(ItemAlign.Center)
            .fontSize($r('app.integer.comm_font_size10'))
        }
        .margin({
          top: $r('app.integer.comm_padding_margin12'),
          right: $r('app.integer.comm_padding_margin24'),
          left: $r('app.integer.comm_padding_margin24')
        })

        Column() {
          Button($r('app.string.button_one'))
            .buttonStyles()
            .onClick(() => {
              Logger.info('The main thread generates a log.');
              let logInfo: LogInfo =
                new LogInfo('MainThread', LogLevelEnum.INFO, 'this is a log from ProducerConsumer');
              this.sq.offer(logInfo);
            })

          Button($r('app.string.button_two'))
            .buttonStyles()
            .onClick(() => {
              Logger.info('Producer ten log');
              for (let i = 0; i < 10; i++) {
                taskpool.execute(this.producer).catch((err: BusinessError) => {
                  Logger.error(`Execute failed. Cause code: ${err.code}, message: ${err.message}`);
                });
              }
            })

          Button($r('app.string.button_three'))
            .buttonStyles()
            .onClick(() => {
              Logger.info('Long-term production logs');
              if (this.producerLong === null) {
                this.producerController = new LongTaskController();
                this.producerController.command = LongTaskCommandEnum.START;
                this.producerLong =
                  new taskpool.Task('producerLong', ProducerLongTask, 'producerLong', this.sq, this.producerController);
                taskpool.execute(this.producerLong).then(() => {
                  Logger.info('terminateTask' + 'producerLong');
                  taskpool.terminateTask(this.producerLong);
                  this.producerLong = null;
                }).catch((err: BusinessError) => {
                  Logger.error(`Execute failed. Cause code: ${err.code}, message: ${err.message}`);
                });
              }
            })

          Button($r('app.string.button_four'))
            .buttonStyles()
            .onClick(() => {
              Logger.info('Stop the long term production log');
              this.producerController.command = LongTaskCommandEnum.STOP;
            })

          Button($r('app.string.button_five'))
            .buttonStyles()
            .onClick(() => {
              this.consumerControllerOne.command = LongTaskCommandEnum.STOP;
              this.consumerControllerTwo.command = LongTaskCommandEnum.STOP;
              this.consumerControllerOne = new LongTaskController();
              this.startConsumer('consumerOne', this.consumerOne!, this.consumerControllerOne);
            })

          Button($r('app.string.button_six'))
            .buttonStyles()
            .onClick(() => {
              this.consumerControllerOne.command = LongTaskCommandEnum.STOP;
              this.consumerControllerTwo.command = LongTaskCommandEnum.STOP;
              this.consumerControllerOne = new LongTaskController();
              this.consumerControllerTwo = new LongTaskController();
              this.startConsumer('consumerOne', this.consumerOne!, this.consumerControllerOne);
              this.startConsumer('consumerTwo', this.consumerTwo!, this.consumerControllerTwo);
            })

          Button($r('app.string.button_seven'))
            .buttonStyles()
            .onClick(() => {
              this.consumerControllerOne.command = LongTaskCommandEnum.STOP;
              this.consumerControllerTwo.command = LongTaskCommandEnum.STOP;
            })
        }
        .padding({
          right: $r('app.integer.comm_padding_margin16'),
          left: $r('app.integer.comm_padding_margin16')
        })
      }
      .justifyContent(FlexAlign.SpaceBetween)
      .height(Constants.FULL_PERCENT)
      .width(Constants.FULL_PERCENT)
    }
    .title(this.getResourceString($r('app.string.producer_consumer_model')))
    .onAppear(() => {
      this.producer = new taskpool.Task('producer', ProducerTask, 'producer', this.sq);
    })
    .onDisAppear(() => {
      this.consumerControllerOne.command = LongTaskCommandEnum.STOP;
      this.consumerControllerTwo.command = LongTaskCommandEnum.STOP;
      this.producerController.command = LongTaskCommandEnum.STOP;
    })
  }
}