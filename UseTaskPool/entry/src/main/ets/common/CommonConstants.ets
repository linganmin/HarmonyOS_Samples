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

export class CommonConstants {
  /**
   * Page Names.
   */
  static readonly PAGE_NAMES: string[] = ['PriorityTasks', 'PeriodicTasks', 'DelayedTasks', 'LongTasks',
    'DependentTasks', 'TaskGroup', 'SequenceRunner', 'ThreadCommunication'];
  /**
   * Page titles.
   */
  static readonly PAGE_TITLES: string[] = ['priorityTask', 'PeriodicTask', 'DelayedTask', 'LongTask', 'DependentTask',
    'TaskGroup', 'SequenceRunner', 'ThreadCommunication'];
  /**
   * Page titles - resource.
   */
  static readonly PAGE_TITLES_RESOURCE: Resource[] = [$r('app.string.priorityTask'), $r('app.string.PeriodicTask'),
    $r('app.string.DelayedTask'), $r('app.string.LongTask'), $r('app.string.DependentTask'),
    $r('app.string.TaskGroup'), $r('app.string.SequenceRunner'), $r('app.string.ThreadCommunication')];
  /**
   * taskpool thread tag.
   */
  static readonly TASKPOOL_TAG: string = '[TASKPOOL]';
  /**
   * Page stack name.
   */
  static readonly PAGE_STACK_NAME: string = 'pageInfos';
  /**
   * Lock name.
   */
  static readonly LOCK_NAME: string = 'lock';
  /**
   * Priority task info.
   */
  static readonly PRIORITY_EXE_INFO: string[] = ['Execute high task', 'Execute mid  task', 'Execute low  task'];
  /**
   * Periodic task info.
   */
  static readonly PERIODIC_EXE_INFO: string = 'Execute periodic task';
  /**
   * Delayed task info.
   */
  static readonly DELAYED_EXE_INFO: string = 'Execute delayed task';
  /**
   * Delayed task submit info.
   */
  static readonly DELAYED_SUBMIT_INFO: string = 'Submit delayed task';
  /**
   * Dependent task info.
   */
  static readonly DEPENDENT_EXE_INFO: string = 'Execute task';
  /**
   * Dependent submit info.
   */
  static readonly DEPENDENT_SUBMIT_INFO: string = 'Submit task';
  /**
   * Long task info.
   */
  static readonly LONG_EXE_INFO: string = 'Execute long task';
  /**
   * SequenceRunner task info.
   */
  static readonly RUNNER_EXE_INFO: string = 'Execute SequenceRunner task';
  /**
   * TaskGroup task info.
   */
  static readonly GROUP_EXE_INFO: string = 'Execute group task';
  /**
   * Send message.
   */
  static readonly SEND_MESSAGES: string = 'Send message';
  /**
   * Receive message.
   */
  static readonly RECV_MESSAGES: string = 'Receive message';
  /**
   * Worker addr.
   */
  static readonly WORKER_ADDR: string = 'entry/ets/workers/Worker.ets';
  /**
   * Long task end info.
   */
  static readonly LONG_END_INFO: string = 'Long task over';
  /**
   * Periodic cycle info.
   */
  static readonly CYCLE_INFO: string = 'Cycle time: 2000ms\nTask execution time: 500ms';
  /**
   * Delayed info.
   */
  static readonly DELAYED_INFO: string = 'Delayed Time: 2000ms';
  /**
   * Long task info.
   */
  static readonly LONG_INFO: string = 'Task execution Time: 10000ms';
  /**
   * Dependent info.
   */
  static readonly DEPENDENT_INFO: string = 'Task0 depend on Task1';
  /**
   * Priority task consume times.
   */
  static readonly PRIORITY_TASK_EXE_TIMES: number = 300;
  /**
   * Periodic task consume times.
   */
  static readonly PERIODIC_TASK_EXE_TIMES: number = 500;
  /**
   * Periodic times.
   */
  static readonly PERIODIC_TIMES: number = 2000;
  /**
   * Delayed task consume times.
   */
  static readonly DELAYED_TASK_EXE_TIMES: number = 500;
  /**
   * Delayed times.
   */
  static readonly DELAYED_TIMES: number = 2000;
  /**
   * Dependent task consume times.
   */
  static readonly DEPENDENT_TASK_EXE_TIMES: number = 500;
  /**
   * Long task consume times.
   */
  static readonly LONG_TASK_EXE_TIMES: number = 10000;
  /**
   * SequenceRunner task consume times.
   */
  static readonly RUNNER_EXE_TIMES: number = 500;
  /**
   * TaskGroup task consume times.
   */
  static readonly GROUP_EXE_TIMES: number = 500;
  /**
   * Communication task consume times.
   */
  static readonly Communication_EXE_TIMES: number = 500;
}