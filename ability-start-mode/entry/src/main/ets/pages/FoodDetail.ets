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

import { Want } from '@kit.AbilityKit';
import { emitter } from '@kit.BasicServicesKit';
import { CategoryId, FoodInfo } from '../model/DataModels';
import Logger from '../common/Logger';
import { getContextData, startMode, totast } from '../common/Util';
import { getFoodsData } from '../model/DataUtil';
import Constant from '../common/Constants';

const TAG = '[Sample_StartMode]';
// Set an ID for emitter transmission.
const eventId = Constant.DEFAULT_ONE;

interface EventHub {
  emit(event: string, ...args: Object[]): void;
}

interface GetFoodItemId {
  eventHub: EventHub;
}

interface InnerEvent {
  eventId: number;
}

interface EventData {
  'foodItemId': number;
}

interface Event {
  data: EventData;
}

@Styles
function cardStyle() {
  .height(Constant.FULL_PERCENT)
  .padding({
    top: $r('app.integer.padding_normal'),
    right: $r('app.integer.padding_normal'),
    left: $r('app.integer.padding_normal')
  })
  .backgroundColor($r('app.color.white'))
  .borderRadius(Constant.BORDER_RADIUS_NORMAL_DOUBLE)
}

@Component
struct CardTitle {
  private title: Resource = {
    bundleName: '',
    moduleName: '',
    id: Constant.DEFAULT_ZERO
  };
  private subtitle: Resource = {
    bundleName: '',
    moduleName: '',
    id: Constant.DEFAULT_ZERO
  };

  build() {
    Row() {
      Text(this.title)
        .fontSize($r('app.integer.font_size_normal_md'))
      Blank()
      Text(this.subtitle)
        .fontSize($r('app.integer.font_size_normal_sm'))
        .fontColor($r('app.color.font_color_sp1'))
    }
    .width(Constant.FULL_PERCENT)
    .height($r('app.integer.height_normal_sm'))
  }
}

@Component
struct PageTitle {
  private foodName: Resource = $r('app.string.title_food_detail');

  build() {
    Row() {
      Image($r('app.media.back'))
        .width($r('app.integer.width_normal_sm1'))
        .height($r('app.integer.height_normal_sm1'))
      Text(this.foodName)
        .fontSize($r('app.integer.font_size_normal_md1'))
        .margin({ left: $r('app.integer.margin_normal_md1') })
    }
    .padding($r('app.integer.padding_normal_sm'))
    .width(Constant.FULL_PERCENT)
    .onClick(() => {
      startMode({}, 'MainAbility', this.getUIContext());
    })
  }
}

@Component
struct FoodImageDisplay {
  @State imageBgColorA: number = Constant.DEFAULT_ZERO;
  @Link foodInfo: FoodInfo;

  build() {
    Stack({ alignContent: Alignment.BottomStart }) {
      Image(this.foodInfo.image)
        .sharedTransition(this.foodInfo.letter, {
          duration: Constant.EFFECT_DURATION_FOUR,
          delay: Constant.ANIMATION_DELAY_ONE
        })
        .backgroundColor(`rgba(255, 255, 255, ${this.imageBgColorA})`)
        .objectFit(ImageFit.Contain)
      Row() {
        Text(this.foodInfo.name)
          .fontSize($r('app.integer.font_size_normal_md'))
          .fontWeight(FontWeight.Bold)
          .margin({
            left: $r('app.integer.margin_normal_md2'),
            right: $r('app.integer.margin_normal_sm')
          })
      }
    }
    .height($r('app.integer.height_normal_lg'))
  }
}

@Component
struct ContentTable {
  @Link foodInfo: FoodInfo;
  private IngredientTitle1: Resource = {bundleName: '',  moduleName: '',  id: 1};
  private IngredientTitle2: Resource = {bundleName: '',  moduleName: '',  id: 2};
  private IngredientTitle3: Resource = {bundleName: '',  moduleName: '',  id: 3};

  @Builder
  IngredientItem(title: Resource, colorValue: string | ResourceStr, name: Resource, value: Resource) {
    Row() {
      Text(title)
        .fontSize($r('app.integer.font_size_normal'))
        .fontWeight(FontWeight.Bold)
        .layoutWeight(Constant.DEFAULT_ONE)
        .align(Alignment.Start)
      Row() {
        Circle({
          width: Constant.CIRCLE_WIDTH_NORMAL,
          height: Constant.CIRCLE_HEIGHT_NORMAL
        })
          .margin({ right: $r('app.integer.margin_normal_sm1') })
          .fill(colorValue)
        Text(name)
          .fontSize($r('app.integer.font_size_normal'))
        Blank()
        Text(value)
          .fontSize($r('app.integer.font_size_normal'))
      }
      .width(Constant.FULL_PERCENT)
      .layoutWeight(Constant.CARD_LIST_SPACE)
    }
    .margin({ bottom: $r('app.integer.margin_normal_md1') })
    .id('ContentTable')
  }

  build() {
    Column() {
      this.IngredientItem(
        $r('app.string.diet_record_calorie'),
        $r('app.color.ingredient_item_color3'),
        $r('app.string.diet_record_calorie'),
        $r('app.string.calorie_with_kcal_unit', this.foodInfo.calories.toString())
      )
      Row()
        .height($r('app.integer.height_normal_sm1'))
      this.IngredientItem(
        $r('app.string.nutrition_element'),
        $r('app.color.ingredient_item_color4'),
        $r('app.string.nutrition_element'),
        $r('app.string.weight_with_gram_unit', this.foodInfo.protein.toString())
      )
      this.IngredientItem(
        this.IngredientTitle1,
        $r('app.color.ingredient_item_color1'),
        $r('app.string.diet_record_fat'),
        $r('app.string.weight_with_gram_unit', this.foodInfo.fat.toString())
      )
      this.IngredientItem(
        this.IngredientTitle2,
        $r('app.color.ingredient_item_color2'),
        $r('app.string.diet_record_carbohydrates'),
        $r('app.string.weight_with_gram_unit', this.foodInfo.carbohydrates.toString())
      )
      this.IngredientItem(
        this.IngredientTitle3,
        $r('app.color.ingredient_item_color3'),
        $r('app.string.diet_record_vitaminC'),
        $r('app.string.weight_with_milligram_unit', this.foodInfo.vitaminC.toString())
      )
    }.cardStyle()
  }
}

@Component
struct CaloriesProgress {
  @Link foodInfo: FoodInfo
  private averageCalories: number = Constant.DEFAULT_ZERO;
  private totalCalories: number = Constant.DEFAULT_ZERO;
  private highCalories: boolean = false;

  aboutToAppear() {
    switch (this.foodInfo.categoryId) {
      case CategoryId.Vegetable:
        this.averageCalories = Constant.AVERAGE_CALORIES_ONE;
        break
      case CategoryId.Fruit:
        this.averageCalories = Constant.AVERAGE_CALORIES_TWO;
        break
      case CategoryId.Nut:
        this.averageCalories = Constant.AVERAGE_CALORIES_THREE;
        break
      case CategoryId.Seafood:
        this.averageCalories = Constant.AVERAGE_CALORIES_FOUR;
        break
      case CategoryId.Dessert:
        this.averageCalories = Constant.AVERAGE_CALORIES_FIVE;
        break
    }
    this.totalCalories = this.averageCalories * Constant.CARD_LIST_SPACE;
    this.highCalories = this.foodInfo.calories < this.averageCalories;
  }

  build() {
    Column() {
      CardTitle({ title: $r('app.string.diet_record_calorie'), subtitle: $r('app.string.unit_weight') })
      Row() {
        Text(this.foodInfo.calories.toString())
          .fontColor(this.getCalorieColor())
          .fontSize($r('app.integer.font_size_normal_lg'))
        Text($r('app.string.calorie_with_kcal_unit', ''))
          .fontSize($r('app.integer.font_size_normal_md2'))
          .margin({ bottom: $r('app.integer.margin_normal_sm2') })
      }
      .margin({
        top: $r('app.integer.margin_normal_md3'),
        bottom: $r('app.integer.margin_normal_md3')
      })
      .alignItems(VerticalAlign.Bottom)

      Text(this.highCalories ? $r('app.string.high_calorie_food') : $r('app.string.low_calorie_food'))
        .fontSize($r('app.integer.font_size_normal_sm'))
        .fontColor($r('app.color.font_color_normal'))

      Progress({
        value: this.foodInfo.calories,
        total: this.totalCalories,
        style: ProgressStyle.Linear
      })
        .style({ strokeWidth: Constant.STROKE_WIDTH })
        .color(this.getCalorieColor())
        .margin({ top: $r('app.integer.margin_normal_md4') })
    }
    .cardStyle()
    .id('CaloriesProgress')
  }

  getCalorieColor() {
    return this.highCalories ? $r('app.color.high_calorie') : $r('app.color.low_calorie');
  }
}

@Component
struct StartModeCard {
  @Link foodData: FoodInfo[];
  @Link foodItemId: number;
  @Link foodInfo: FoodInfo;
  private modeName: string = '';
  private foodListIndex: number = Constant.DEFAULT_ZERO;

  aboutToAppear(): void {
    this.emitterOn();
  }

  emitterOn(){
    let innerEvent: InnerEvent = { eventId };
    emitter.on(innerEvent, (eventData: emitter.EventData) => {
      this.foodItemId = eventData.data?.foodItemId;
      // Determine if the ID value of the data is 0.
      if (this.foodItemId == Constant.DEFAULT_ZERO) {
        this.foodInfo = getFoodsData()[this.foodListIndex][this.foodItemId + Constant.DEFAULT_ONE];
        this.foodData = [getFoodsData()[this.foodListIndex][this.foodItemId]];
      } else {
        this.foodInfo = getFoodsData()[this.foodListIndex][this.foodItemId - Constant.DEFAULT_ONE];
        this.foodData = [getFoodsData()[this.foodListIndex][this.foodItemId]];
      }
    });
  }

  async cateMode(foodItemId: number) {
    Logger.info(TAG, 'MultitonAbility startMode start')
    if (this.modeName == 'multiton') {
      startMode({
        'foodItemId': foodItemId,
        'modeName': this.modeName,
        'foodListIndex': this.foodListIndex
      }, 'MultitonAbility', this.getUIContext())
    } else if (this.modeName == 'specified') {
      if (this.foodItemId == foodItemId) {
        totast(this.getUIContext());
        return;
      }
      startMode({
        'target': 'pages/FoodDetail',
        'foodItemId': foodItemId,
        'modeName': this.modeName,
        'foodListIndex': this.foodListIndex
      }, 'SpecifiedAbility', this.getUIContext())
    } else {
      startMode({
        'foodItemId': foodItemId,
        'modeName': this.modeName,
        'foodListIndex': this.foodListIndex
      }, 'SingletonAbility', this.getUIContext())
      this.emitterOn();
    }
  }

  build() {
    Column() {
      Text($r('app.string.otherFoods'))
        .width(Constant.FULL_PERCENT)
        .height($r('app.integer.height_normal1'))
        .fontSize($r('app.integer.font_size_normal_sm1'))
        .fontWeight(Constant.FONT_WEIGHT_MD)
        .fontColor($r('app.color.font_color_normal1'))
      Grid() {
        ForEach(this.foodData, (item: FoodInfo) => {
          GridItem() {
            Row() {
              Image(item.image)
                .objectFit(ImageFit.Contain)
                .autoResize(false)
                .height($r('app.integer.height_normal'))
                .width($r('app.integer.width_normal'))
                .backgroundColor($r('app.color.back_ground_color'))
                .margin({ right: $r('app.integer.margin_normal') })
                .borderRadius(Constant.BORDER_RADIUS_NORMAL)
              Row() {
                Text(item.name)
                  .fontSize($r('app.integer.font_size_normal'))
                  .fontWeight(Constant.FONT_WEIGHT_MD)
              }.width(Constant.EIGHTY_PERCENT)
            }
            .width(Constant.FULL_PERCENT)
            .height($r('app.integer.height_normal_md'))
            .padding({
              left: $r('app.integer.padding_normal_sm1'),
              right: $r('app.integer.padding_normal')
            })
            .onClick(() => {
              this.cateMode(item.id)
            })
          }
        })
      }
      .columnsTemplate(Constant.COLUMNS_TEMPLATE_ONE)
      .columnsGap(Constant.SPACE_TEN)
      .rowsGap(Constant.SPACE_TEN)
    }
    .backgroundColor($r('app.color.white'))
    .borderRadius(Constant.BORDER_RADIUS_NORMAL_DOUBLE)
    .height($r('app.integer.height_normal_lg1'))
    .padding({
      left: $r('app.integer.padding_normal_sm2'),
      bottom: $r('app.integer.padding_normal_sm2')
    })
    .margin({
      top: $r('app.integer.margin_normal_md1'),
      right: $r('app.integer.margin_normal_sm2'),
      left: $r('app.integer.margin_normal_md1')
    })
  }
}

@Entry
@Component
struct FoodDetail {
  @State foodInfo: FoodInfo = new FoodInfo();
  @State MultitonFoodData: FoodInfo[] = [];
  @State specifiedFoodData: FoodInfo[] = [];
  @State singletonFoodData: FoodInfo[] = [];
  // Accept the foodItemId sent by want and filter the data based on this Id, with an initial value of 0.
  @State foodItemId: number = Constant.DEFAULT_ZERO;
  private foodData: Array<FoodInfo>[] = getFoodsData();
  private modeName: string | undefined = '';
  private foodListIndex: number = Constant.DEFAULT_ZERO;
  private abilityWant: Want = getContextData(this.getUIContext());


  async aboutToAppear() {
    this.foodItemId = Number(this.abilityWant.parameters?.foodItemId);
    this.modeName = this.abilityWant.parameters?.modeName.toString();
    this.foodListIndex = Number(this.abilityWant.parameters?.foodListIndex);
    this.foodInfo = this.foodData[this.foodListIndex].filter(item => {
      return this.foodItemId == item.id;
    })[Constant.DEFAULT_ZERO];
    if (this.modeName === 'multiton') {
      // Determine if the ID value of the data is 0.
      if (this.foodItemId == Constant.DEFAULT_ZERO) {
        // Here, 1 is used to search for data with ID 1.
        this.foodItemId = Constant.DEFAULT_ONE;
        this.MultitonFoodData = [this.foodData[this.foodListIndex][this.foodItemId]];
      } else {
        // Here, 0 is used to search for data with ID 0.
        this.foodItemId = Constant.DEFAULT_ZERO;
        this.MultitonFoodData = [this.foodData[this.foodListIndex][this.foodItemId]];
      }
    } else if (this.modeName == 'specified') {
      this.specifiedFoodData = this.foodData[this.foodListIndex];
    } else {
      if (this.foodItemId == Constant.DEFAULT_ZERO) {
        this.foodItemId = Constant.DEFAULT_ONE;
        this.singletonFoodData = [this.foodData[this.foodListIndex][this.foodItemId]];
      } else {
        this.foodItemId = Constant.DEFAULT_ZERO;
        this.singletonFoodData = [this.foodData[this.foodListIndex][this.foodItemId]];
      }
    }
  }

  build() {
    Scroll() {
      Column() {
        PageTitle()
        FoodImageDisplay({ foodInfo: this.foodInfo })
        Swiper() {
          ContentTable({ foodInfo: this.foodInfo })
          CaloriesProgress({ foodInfo: this.foodInfo })
        }
        .clipShape(new Rect()
          .width(Constant.FULL_PERCENT)
          .height(Constant.FULL_PERCENT)
          .radiusWidth(Constant.SPACE_FIFTEEN)
          .radiusHeight(Constant.SPACE_FIFTEEN)
        )
        .itemSpace(Constant.SPACE_TWENTY)
        .height($r('app.integer.height_normal_lg2'))
        .margin({
          top: $r('app.integer.margin_normal_sm2'),
          right: $r('app.integer.margin_normal_sm2'),
          left: $r('app.integer.margin_normal_sm2')
        })

        if (this.modeName === 'multiton') {
          StartModeCard({
            foodData: $MultitonFoodData,
            modeName: this.modeName,
            foodItemId: $foodItemId,
            foodInfo: this.foodInfo,
            foodListIndex: this.foodListIndex
          })
        } else if (this.modeName === 'specified') {
          StartModeCard({
            foodData: $specifiedFoodData,
            modeName: this.modeName,
            foodItemId: $foodItemId,
            foodInfo: this.foodInfo,
            foodListIndex: this.foodListIndex
          })
        } else {
          StartModeCard({
            foodData: $singletonFoodData,
            modeName: this.modeName,
            foodItemId: $foodItemId,
            foodInfo: this.foodInfo,
            foodListIndex: this.foodListIndex
          })
        }
      }
      .alignItems(HorizontalAlign.Center)
    }
    .backgroundColor($r('app.color.back_ground_color_sp1'))
    .height(Constant.FULL_PERCENT)
    .align(Alignment.Top)
    .id('detailPage')
  }
}
