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
import { CalendarDialogView } from '../../view/CalendarView';

import { CalendarItem } from '../../viewmodel/CalendarItem';
import { HotelRoomItem } from '../../viewmodel/HotelRoomItem';
import { SearchTicketBarItem } from '../../viewmodel/SearchTicketBarItem';
import { SearchTicketDateItem } from '../../viewmodel/SearchTicketDateItem';
import { TicketItem } from '../../viewmodel/TicketItem';

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
   * The break point value.
   */
  static readonly BREAK_POINTS_VALUE: Array<string> = ['300vp', '600vp', '840vp'];

  /**
   * The number of columns for SM device.
   */
  static readonly COLUMN_SM: number = 4;

  /**
   * The number of columns for MD device.
   */
  static readonly COLUMN_MD: number = 8;

  /**
   * The number of columns for LG device.
   */
  static readonly COLUMN_LG: number = 12;

  /**
   * The number of min margin top.
   */
  static readonly MIN_MARIN_TOP: number = 225;

  /**
   * The number of max margin top.
   */
  static readonly MAX_MARIN_TOP: number = 460;

  /**
   * The full percentage of component.
   */
  static readonly FULL_WIDTH_PERCENT: string = '100%';

  /**
   * The ninety five percent of the components.
   */
  static readonly NINETY_FIVE_PERCENT: string = '95%';

  /**
   * The ninety-one percent of the components.
   */
  static readonly NINETY_ONE_PERCENT: string = '91%';

  /**
   * The ninety percent of the components.
   */
  static readonly NINETY_PERCENT: string = '90%';

  /**
   * The one hundred fifty percent.
   */
  static readonly ONE_HUNDRED_FIFTY_PERCENT: string = '150%';

  /**
   * The eighty percent.
   */
  static readonly EIGHTY_PERCENT: string = '80%';

  /**
   * The seventy percent.
   */
  static readonly SEVENTY_PERCENT: string = '70%';

  /**
   * The sixty percent.
   */
  static readonly SIXTY_PERCENT: string = '60%';

  /**
   * The card two width
   */
  static readonly CARD_TWO_WIDTH: string = '59.1%';

  /**
   * The fifty-five percent.
   */
  static readonly FIFTY_FIVE_PERCENT: string = '55%';

  /**
   * The fifty percent.
   */
  static readonly FIFTY_PERCENT: string = '50%';

  /**
   * The forty percent.
   */
  static readonly FORTY_PERCENT: string = '40%';

  /**
   * The sixty percent.
   */
  static readonly CARD_ONE_WIDTH: string = '38.4%';

  /**
   * The thirty percent.
   */
  static readonly THIRTY_PERCENT: string = '30%';

  /**
   * The twenty-five percent.
   */
  static readonly TWENTY_FIVE_PERCENT: string = '25%';

  /**
   * The twenty-two percent.
   */
  static readonly TWENTY_TWO_PERCENT: string = '22.2%';

  /**
   * The twenty percent.
   */
  static readonly TWENTY_PERCENT: string = '20%';

  /**
   * The fifteen percent.
   */
  static readonly FIFTEEN_PERCENT: string = '15%';

  /**
   * The ten percent.
   */
  static readonly TEN_PERCENT: string = '10%';

  /**
   * The five percent.
   */
  static readonly FIVE_PERCENT: string = '5%';

  /**
   * The four percent.
   */
  static readonly STAR_WIDTH: string = '4.4%';

  /**
   * Common font weight.
   */
  static readonly FONT_WEIGHT_500: number = 500;

  /**
   * Common font weight.
   */
  static readonly FONT_WEIGHT_400: number = 400;

  /**
   * Common font weight.
   */
  static readonly FONT_WEIGHT_200: number = 200;

  /**
   * start time.
   */
  static readonly START_TIME: number = -1;

  /**
   * max time.
   */
  static readonly mAX_TIME: number = 100;

  /**
   * opacity 0.9
   */
  static readonly OPACITY_NINETY_PERCENT: number = 0.9;

  /**
   * opacity 0.8
   */
  static readonly OPACITY_EIGHTY_PERCENT: number = 0.8;

  /**
   * opacity 0.6
   */
  static readonly OPACITY_SIXTY_PERCENT: number = 0.6;

  /**
   * opacity 0.5
   */
  static readonly OPACITY_FIFTY_PERCENT: number = 0.5;

  /**
   * opacity 0.4
   */
  static readonly OPACITY_FORTY_PERCENT: number = 0.4;

  /**
   * opacity 1
   */
  static readonly OPACITY_FULL_PERCENT: number = 1;

  /**
   * number 1
   */
  static readonly NUMBER_ONE: number = 1;

  /**
   * number 2
   */
  static readonly NUMBER_TWO: number = 2;

  /**
   * number 3
   */
  static readonly NUMBER_THREE: number = 3;

  /**
   * number 4
   */
  static readonly NUMBER_FOUR: number = 4;

  /**
   * number 5
   */
  static readonly NUMBER_FIVE: number = 5;

  /**
   * number 6
   */
  static readonly NUMBER_SIX: number = 6;

  /**
   * number 7
   */
  static readonly NUMBER_SEVEN: number = 7;

  /**
   * number 8
   */
  static readonly NUMBER_EIGHT: number = 8;

  /**
   * number 9
   */
  static readonly NUMBER_NINE: number = 9;

  /**
   * number 10
   */
  static readonly NUMBER_TEN: number = 10;

  /**
   * number 11
   */
  static readonly NUMBER_ELEVEN: number = 11;

  /**
   * number 28
   */
  static readonly NUMBER_TWENTY_EIGHT: number = 28;

  /**
   * number 31
   */
  static readonly NUMBER_THIRTY_ONE: number = 31;

  /**
   * number 60
   */
  static readonly NUMBER_SIXTY: number = 60;

  /**
   * number 15
   */
  static readonly NUMBER_FIFTEEN: number = 15;

  /**
   * number 0.
   */
  static readonly NUMBER_ZERO: number = 0;

  /**
   * number 100.
   */
  static readonly NUMBER_ONE_HUNDRED: number = 100;

  /**
   * number 1000
   */
  static readonly NUMBER_THOUSAND: number = 1000;

  /**
   * empty string
   */
  static readonly EMPTY_STRING: string = '';

  /**
   * grid column template.
   */
  static readonly GRID_COLUMN_TEMPLATE: string = '1fr 1fr 1fr 1fr 1fr 1fr 1fr';

  /**
   * auto height.
   */
  static readonly AUTO_HEIGHT: string = 'auto';

  /**
   * The url of index page.
   */
  static readonly INDEX_PAGE_URL: string = 'pages/Index';

  /**
   * The url of hotel detail page.
   */
  static readonly HOTEL_DETAIL_PAGE_URL: string = 'HotelDetailsPage';

  /**
   * The url of search ticket page.
   */
  static readonly SEARCH_TICKET_PAGE_URL: string = 'SearchTicketPage';

  /**
   * The url of lower price Calendar page.
   */
  static readonly LOW_PRICE_CALENDAR_URL: string = 'LowPriceCalendarPage';

  /**
   * Hotel Name.
   */
  static readonly HOTEL_NAME: Resource = $r('app.string.hotel_name');

  /**
   * hotel message one
   */
  static readonly HOTEL_MESSAGE_ONE: Resource = $r('app.string.hotel_message_one');

  /**
   * hotel message two
   */
  static readonly HOTEL_MESSAGE_TWO: Resource = $r('app.string.hotel_message_two');

  /**
   * hotel message three
   */
  static readonly HOTEL_MESSAGE_THREE: Resource = $r('app.string.hotel_message_three');

  /**
   * hotel message four
   */
  static readonly HOTEL_MESSAGE_FOUR: Resource = $r('app.string.hotel_message_four');

  /**
   * hotel message five
   */
  static readonly HOTEL_MESSAGE_FIVE: Resource = $r('app.string.hotel_message_five');

  /**
   * hotel message six
   */
  static readonly HOTEL_MESSAGE_SIX: Resource = $r('app.string.hotel_message_six');

  /**
   * hotel message seven
   */
  static readonly HOTEL_MESSAGE_SEVEN: Resource = $r('app.string.hotel_message_seven');

  /**
   * hotel message eight
   */
  static readonly HOTEL_MESSAGE_EIGHT: Resource = $r('app.string.hotel_message_eight');

  /**
   * hotel message nine
   */
  static readonly HOTEL_MESSAGE_NINE: Resource = $r('app.string.hotel_message_nine');

  /**
   * Room message one.
   */
  static readonly ROOM_MESSAGE_ONE: Resource = $r('app.string.room_message_one');

  /**
   * Room message two.
   */
  static readonly ROOM_MESSAGE_TWO: Resource = $r('app.string.room_message_two');

  /**
   * Room message three.
   */
  static readonly ROOM_MESSAGE_THREE: Resource = $r('app.string.room_message_three');

  /**
   * The number of breakfast.
   */
  static readonly BREAKFAST_NUMBER: string = 'breakfast :  ';

  /**
   * money flag.
   */
  static readonly MONEY: string = '￥';

  /**
   * start flag.
   */
  static readonly START: Resource = $r('app.string.at_least');

  /**
   * ticket number.
   */
  static readonly TICKET_NUMBER: string = 'Ticket number :';

  /**
   * journey information.
   */
  static readonly JOURNEY: Resource = $r('app.string.journey');

  /**
   * Room button message.
   */
  static readonly ROOM_BUTTON_MESSAGES: Resource[] = [
    $r('app.string.room_button_message_one'),
    $r('app.string.room_button_message_two'),
    $r('app.string.room_button_message_three'),
    $r('app.string.room_button_message_four'),
    $r('app.string.room_button_message_five'),
    $r('app.string.room_button_message_six'),
    $r('app.string.room_button_message_seven'),
    $r('app.string.room_button_message_eight'),
    $r('app.string.room_button_message_nine'),
    $r('app.string.room_button_message_ten'),
    $r('app.string.room_button_message_eleven'),
  ];

  /**
   * Hotel Room Informations.
   */
  static readonly HOTEL_ROOMS_MESSAGES: Array<HotelRoomItem> = [
    new HotelRoomItem($r('app.media.roomOne'), $r('app.string.room_type_one'), 1,
      $r('app.string.room_information_one'), 2, $r('app.string.room_services'), '¥2038', '¥1884', true),
    new HotelRoomItem($r('app.media.roomTwo'), $r('app.string.room_type_two'), 2,
      $r('app.string.room_information_two'), 2, $r('app.string.room_services'), '¥2680', '¥2400', true),
    new HotelRoomItem($r('app.media.roomThree'), $r('app.string.room_type_three'), 3,
      $r('app.string.room_information_three'), 2, $r('app.string.room_services'), '¥2680', '¥2400', false),
    new HotelRoomItem($r('app.media.roomFour'), $r('app.string.room_type_four'), 4,
      $r('app.string.room_information_four'), 2, $r('app.string.room_services'), '¥4890', '¥4800', false),
    new HotelRoomItem($r('app.media.roomFive'), $r('app.string.room_type_five'), 5,
      $r('app.string.room_information_five'), 2, $r('app.string.room_services'), '¥5597', '¥5547', false)
  ];

  /**
   * Hotel Picture Informations.
   */
  static readonly HOTEL_PICTURE_MESSAGE: Array<Resource> = [
    $r('app.media.hotelPadone'), $r('app.media.hotelPadtwo'),
    $r('app.media.hotelPadthree'), $r('app.media.hotelPadfour'),
    $r('app.media.hotelPadfive')
  ];

  /**
   * Navigation bar information on the ticket search page.
   */
  static readonly SEARCH_BAR_MESSAGE: Array<SearchTicketBarItem> = [
    new SearchTicketBarItem($r('app.media.sift'), $r('app.string.filter'), $r('app.media.sift_select')),
    new SearchTicketBarItem($r('app.media.stopwatch'),$r('app.string.shortest_time'), $r('app.media.stopwatch_select')),
    new SearchTicketBarItem($r('app.media.history'),$r('app.string.earliest_departure'),$r('app.media.history_select')),
    new SearchTicketBarItem($r('app.media.cheap'), $r('app.string.the_cheapest'), $r('app.media.cheap_select')),
    new SearchTicketBarItem($r('app.media.shop'), $r('app.string.reservation_order'), $r('app.media.shop_select'))
  ];

  /**
   * The date message on search ticket page.
   */
  static readonly SEARCH_DATE_MESSAGE: Array<SearchTicketDateItem> = [
    new SearchTicketDateItem($r('app.string.Today'), '01.22'),
    new SearchTicketDateItem($r('app.string.Friday'), '01.23'),
    new SearchTicketDateItem($r('app.string.Saturday'), '01.24'),
    new SearchTicketDateItem($r('app.string.Sunday'), '01.25'),
    new SearchTicketDateItem($r('app.string.Monday'), '01.26'),
    new SearchTicketDateItem($r('app.string.Tuesday'), '01.27'),
    new SearchTicketDateItem($r('app.string.Wednesday'), '01.28')
  ];

  /**
   * The Button message on search ticket page.
   */
  static readonly SEARCH_ADDRESS_BUTTON_MESSAGE: Array<Resource> = [
    $r('app.string.Beijing_South'),$r('app.string.Beijing'),
    $r('app.string.Shanghai_Hongqiao'),$r('app.string.Shanghai')
  ];

  /**
   * The ticket informations.
   */
  static readonly TICKET_MESSAGE: Array<TicketItem> = [
    new TicketItem('01.22', '23:48', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 0, 0, 0),
    new TicketItem('01.22', '12:03', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.Railway'), 'T113', '4h20m', 548, 2, 2, 0),
    new TicketItem('01.22', '01:02', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.high_speed'), 'G113', '3h14m', 648, 2, 2, 0),
    new TicketItem('01.22', '01:01', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '3h46m', 328, 2, 2, 0),
    new TicketItem('01.22', '09:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '2h12m', 168, 2, 2, 0),
    new TicketItem('01.22', '16:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '5h38m', 618, 0, 0, 0),
    new TicketItem('01.22', '14:03', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.Railway'), 'T113', '4h17m', 514, 2, 2, 0),
    new TicketItem('01.22', '13:02', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.high_speed'), 'G113', '4h16m', 647, 2, 2, 0),
    new TicketItem('01.22', '07:01', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '3h20m', 344, 2, 2, 0),
    new TicketItem('01.22', '06:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '3h37m', 369, 2, 2, 0),
    new TicketItem('01.22', '13:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '2h18m', 114, 2, 2, 0),
    new TicketItem('01.23', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.23', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.23', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.23', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.23', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.23', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.24', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.24', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.24', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.24', '17:00', '21:18', $r('app.string.Beijing'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.24', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.24', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.25', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 0, 0, 0),
    new TicketItem('01.25', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 0, 0, 0),
    new TicketItem('01.25', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 0, 0, 0),
    new TicketItem('01.25', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 0, 0, 0),
    new TicketItem('01.25', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 0, 0, 0),
    new TicketItem('01.26', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.26', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.26', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.26', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.26', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.27', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.28', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
    new TicketItem('01.28', '17:00', '21:18', $r('app.string.Beijing_South'), $r('app.string.Shanghai_Hongqiao'), $r('app.string.train'), 'K113', '4h18m', 662, 2, 2, 0),
  ];

  /**
   * The bar message on search ticket page.
   */
  static readonly SEARCH_TICKET_BAR: Array<Resource> = [
    $r('app.string.direct'), $r('app.string.Transfer')
  ];

  /**
   * The calendar message.
   */
  static readonly CALENDAR_TIME_MESSAGE: Array<Array<CalendarItem>> = [
    [
      new CalendarItem('', '', false, true), new CalendarItem('1', '', false, true),
      new CalendarItem('2', '', false, true), new CalendarItem('3', '', false, true),
      new CalendarItem('4', '', false, true), new CalendarItem('5', '', false, true),
      new CalendarItem('6', '', false, true), new CalendarItem('7', '', false, true),
      new CalendarItem('8', '', false, true), new CalendarItem('9', '', false, true),
      new CalendarItem('10', '', false, true), new CalendarItem('11', '', false, true),
      new CalendarItem('12', '', false, true), new CalendarItem('13', '', false, true),
      new CalendarItem('14', '', false, true), new CalendarItem('15', '', false, true),
      new CalendarItem('16', '', false, true), new CalendarItem('17', '', false, true),
      new CalendarItem('18', '', false, true), new CalendarItem('19', '', false, true),
      new CalendarItem('20', '', false, true), new CalendarItem('21', '', false, true),
      new CalendarItem('22', '￥2063', false, false, true), new CalendarItem('23', '￥2063', false),
      new CalendarItem('24', '￥2063', false), new CalendarItem('25', '￥2063', false),
      new CalendarItem('26', '￥2063', false), new CalendarItem('27', '￥2063', false),
      new CalendarItem('28', '￥2063', false), new CalendarItem('29', '￥1965', true),
      new CalendarItem('30', '￥1965', true), new CalendarItem('31', '￥1965', true),
      new CalendarItem('', '', false), new CalendarItem('', '', false), new CalendarItem('', '', false),
    ],
    [
      new CalendarItem('', '', false), new CalendarItem('', '', false), new CalendarItem('', '', false),
      new CalendarItem('', '', false), new CalendarItem('1', '￥2063', false), new CalendarItem('2', '￥2063', false),
      new CalendarItem('3', '￥2063', false), new CalendarItem('4', '￥2063', false),
      new CalendarItem('5', '￥2063', false), new CalendarItem('6', '￥2063', false),
      new CalendarItem('7', '￥2063', false), new CalendarItem('8', '￥2063', false),
      new CalendarItem('9', '￥2063', false), new CalendarItem('10', '￥2063', false),
      new CalendarItem('11', '￥2063', false), new CalendarItem('12', '￥2063', false),
      new CalendarItem('13', '￥2063', false), new CalendarItem('14', '￥2063', false),
      new CalendarItem('15', '￥2063', false), new CalendarItem('16', '￥2063', false),
      new CalendarItem('17', '￥2063', false), new CalendarItem('18', '￥2063', false),
      new CalendarItem('19', '￥2063', false), new CalendarItem('20', '￥2063', false),
      new CalendarItem('21', '￥2063', false), new CalendarItem('22', '￥2063', false),
      new CalendarItem('23', '￥2063', false), new CalendarItem('24', '￥2063', false),
      new CalendarItem('25', '￥2063', false), new CalendarItem('26', '￥2063', false),
      new CalendarItem('27', '￥2063', false), new CalendarItem('28', '￥2063', false),
      new CalendarItem('29', '￥2063', false), new CalendarItem('', '', false), new CalendarItem('', '', false),
    ]
  ];

  /**
   * The week message on calendar page.
   */
  static readonly WEEK_MESSAGE: Array<Resource> = [
    $r('app.string.Calendar_Sunday'),
    $r('app.string.Calendar_Monday'),
    $r('app.string.Calendar_Tuesday'),
    $r('app.string.Calendar_Wednesday'),
    $r('app.string.Calendar_Thursday'),
    $r('app.string.Calendar_Friday'),
    $r('app.string.Calendar_Saturday')
  ];

  /**
   * The sift condition.
   */
  static readonly FILTERING_CRITERIA: Array<Resource> = [
    $r('app.string.only_railway'),
    $r('app.string.only_train'),
    $r('app.string.view_available')
  ];
}