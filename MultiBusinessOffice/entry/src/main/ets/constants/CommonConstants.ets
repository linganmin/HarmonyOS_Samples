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

import { CalendarItem } from '../viewmodel/CalendarItem';
import { NotesData } from '../viewmodel/NotesData';
import { TripData } from '../viewmodel/TripData';
import { common } from '@kit.AbilityKit';

const uiContext: UIContext | undefined = AppStorage.get('uiContext');
const context = uiContext?.getHostContext() as common.UIAbilityContext;

/**
 * Common constants for all features.
 */
export class CommonConstants {
  /**
   * Breakpoint sm.
   */
  static readonly BREAK_POINT_SM: string = 'sm';
  /**
   * Breakpoint md.
   */
  static readonly BREAK_POINT_MD: string = 'md';
  /**
   * Breakpoint lg.
   */
  static readonly BREAK_POINT_LG: string = 'lg';
  /**
   * DeviceType PC/2in1.
   */
  static readonly DEVICE_TYPE_2IN1: string = '2in1';
  /**
   * The break point value.
   */
  static readonly BREAK_POINTS_VALUE: Array<string> = ['300', '600', '840'];
  /**
   * Notes icon list.
   */
  static readonly MEMO_LIST_ICON: Array<Resource> = [
    $r('sys.symbol.doc_plaintext'),
    $r('sys.symbol.star'),
    $r('sys.symbol.lock'),
    $r('sys.symbol.trash')
  ];
  /**
   * Notes list.
   */
  static readonly MEMO_LIST: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.memo_list').id);
  /**
   * Notes number list.
   */
  static readonly MEMO_LIST_NUMBER: Array<string> = ['18', '2', '1', '10'];
  /**
   * Folder icon list.
   */
  static readonly FOLDER_LIST_ICON: Array<Resource> = [
    $r('app.media.ic_blank'),
    $r('app.media.ic_blue'),
    $r('app.media.ic_pink'),
    $r('app.media.ic_green'),
    $r('app.media.ic_purple')
  ];
  /**
   * Folder list.
   */
  static readonly FOLDER_LIST: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.folder_list').id);
  /**
   * Folder list number.
   */
  static readonly FOLDER_LIST_NUMBER: Array<string> = ['18', '2', '5', '7', '11'];
  /**
   * start time.
   */
  static readonly START_TIME: number = -1;
  /**
   * The week message on calendar page.
   */
  static readonly WEEK_MESSAGE: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.week_message').id);
  /**
   * grid column template.
   */
  static readonly GRID_COLUMN_TEMPLATE: string = '1fr 1fr 1fr 1fr 1fr 1fr 1fr';
  /**
   * grid row template.
   */
  static readonly GRID_ROW_TEMPLATE: string = '1fr 1fr 1fr 1fr 1fr';
  /**
   * The calendar message.
   */
  static readonly CALENDAR_TIME_MESSAGE: Array<CalendarItem | string> = [
    new CalendarItem('1', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[0],
      false),
    new CalendarItem('2', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[1],
      false),
    new CalendarItem('3', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[2],
      false),
    new CalendarItem('4', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[3],
      false),
    new CalendarItem('5', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[4],
      false),
    new CalendarItem('6', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[5],
      false),
    new CalendarItem('7', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[6],
      false),
    new CalendarItem('8', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[7],
      false),
    new CalendarItem('9', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[8],
      false),
    new CalendarItem('10', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[9],
      false),
    new CalendarItem('11', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[10],
      false),
    new CalendarItem('12', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[11],
      false, true),
    new CalendarItem('13', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[12],
      false),
    new CalendarItem('14', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[13],
      false),
    new CalendarItem('15', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[14],
      false),
    new CalendarItem('16', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[15],
      false, true),
    new CalendarItem('17', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[16],
      false),
    new CalendarItem('18', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[17],
      false),
    new CalendarItem('19', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[18],
      false),
    new CalendarItem('20', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[19],
      false),
    new CalendarItem('21', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[20],
      false),
    new CalendarItem('22', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[21],
      false, false),
    new CalendarItem('23', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[22],
      false),
    new CalendarItem('24', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[23],
      false),
    new CalendarItem('25', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[24],
      false, true),
    new CalendarItem('26', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[25],
      false),
    new CalendarItem('27', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[26],
      false),
    new CalendarItem('28', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[27],
      false),
    new CalendarItem('29', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[28],
      false),
    new CalendarItem('30', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[29],
      false),
    new CalendarItem('1', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[30],
      true),
    new CalendarItem('2', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[31],
      true),
    new CalendarItem('3', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[32],
      true),
    new CalendarItem('4', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[33],
      true),
    new CalendarItem('5', context.resourceManager.getStringArrayValueSync($r('app.strarray.september').id)[34],
      true)
  ];
  /**
   * The trip schedule.
   */
  static readonly TRIP_SCHEDULE: Array<TripData> = [
    new TripData('08:00', '09:00', context.resourceManager.getStringSync($r('app.string.trip_schedule1').id),
      true),
    new TripData('08:00', '09:20', context.resourceManager.getStringSync($r('app.string.trip_schedule2').id),
      true, 'F1A3-F78G'),
    new TripData('11:00', '11:20', context.resourceManager.getStringSync($r('app.string.trip_schedule3').id),
      false, 'A3F4-2501'),
    new TripData('11:30', '12:00', context.resourceManager.getStringSync($r('app.string.trip_schedule4').id),
      false, 'A3F4-2501'),
    new TripData('14:00', '15:20', context.resourceManager.getStringSync($r('app.string.trip_schedule5').id),
      false, 'A5F4-2506')
  ];
  /**
   * The notes schedule.
   */
  static readonly NOTES_SCHEDULE: Array<Array<NotesData>> = [
    [
      new NotesData('#E6BA0B', context.resourceManager.getStringSync($r('app.string.notes_schedule1').id),
        $r('app.string.notes_schedule2'), $r('app.string.notes_schedule3'), $r('app.media.notes_list1'),
        $r('sys.symbol.star')),
      new NotesData('#E64566', context.resourceManager.getStringSync($r('app.string.notes_schedule4').id),
        $r('app.string.notes_schedule2'), $r('app.string.notes_schedule5'), undefined, $r('sys.symbol.lock')),
      new NotesData('#64BB5C', context.resourceManager.getStringSync($r('app.string.notes_schedule6').id),
        $r('app.string.notes_schedule2'), $r('app.string.notes_schedule6'),
        $r('app.media.notes_list2'))
    ],
    [
      new NotesData('#AC49F5', context.resourceManager.getStringSync($r('app.string.notes_schedule7').id),
        $r('app.string.notes_schedule8'), $r('app.string.notes_schedule9'), undefined, $r('app.media.add')),
      new NotesData('#46B1E3', 'Yesterday Once More', $r('app.string.notes_schedule10'), "When i was young I'd ...")
    ]
  ];
  /**
   * The full percentage of component.
   */
  static readonly FULL_PERCENT: string = '100%';
  /**
   * Control button.
   */
  static readonly CONTROL_BUTTON: number = 40;
  /**
   * Calendar sideBar width.
   */
  static readonly SIDEBAR_WIDTH: number = 240;
  /**
   * Notes sideBar width.
   */
  static readonly NOTES_SIDEBAR_WIDTH: number = 304;
  /**
   * Calendar content width.
   */
  static readonly CALENDAR_CONTENT_WIDTH: number = 346;
  /**
   * Control button left.
   */
  static readonly CONTROL_BUTTON_LEFT: number = 256;
  /**
   * Control button top.
   */
  static readonly CONTROL_BUTTON_TOP: number = 44;
  /**
   * Control notes button top.
   */
  static readonly CONTROL_NOTES_BUTTON_TOP: number = 12;
  /**
   * Common margin.
   */
  static readonly COMMON_MARGIN: number = 16;
  /**
   * Common zero.
   */
  static readonly COMMON_ZERO: number = 0;
  /**
   * Common one.
   */
  static readonly COMMON_ONE: number = 1;
  /**
   * Common five.
   */
  static readonly COMMON_FIVE: number = 5;
  /**
   * Common six.
   */
  static readonly COMMON_SIX: number = 6;
  /**
   * Common seven.
   */
  static readonly COMMON_SEVEN: number = 7;
  /**
   * Trip schedule view.
   */
  static readonly TRIP_SCHEDULE_VIEW: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.trip_schedule_view').id);
  /**
   * Calendar side bar view text list.
   */
  static readonly CALENDAR_SIDE_BAR_TEXT: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.calendar_side_bar_text').id);
  /**
   * Entrances.
   */
  static readonly ENTRANCES: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.entrances').id);
  /**
   * Title list.
   */
  static readonly TITLE_LIST: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.title_list').id);
  /**
   * Notes list.
   */
  static readonly NOTES_LIST: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.notes_list').id);
  /**
   * Notes page C content.
   */
  static readonly NOTES_CONTENT: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.notes_content').id);
  /**
   * Notes page C English content.
   */
  static readonly NOTES_ENGLISH_CONTENT: string =
    'When I was young. I\'d listen to the radio. Waiting for my favorite songs. When they played I\'d sing along. It made me smile...';
  /**
   * Notes sidebar text list.
   */
  static readonly NOTES_SIDE_BAR_TEXT: Array<string> =
    context.resourceManager.getStringArrayValueSync($r('app.strarray.notes_side_bar_text').id);
  /**
   * Common font weight 500.
   */
  static readonly FONT_WEIGHT_500: number = 500;
  /**
   * Common font weight 400.
   */
  static readonly FONT_WEIGHT_400: number = 400;
  /**
   * Trip list.
   */
  static readonly TRIP_LIST: Array<number> = [1, 2];
  /**
   * Notes content title height.
   */
  static readonly NOTES_TITLE_HEIGHT: number = 230;
  /**
   * Notes content title height on PC/2in1.
   */
  static readonly NOTES_TITLE_2IN1: number = 120;
}