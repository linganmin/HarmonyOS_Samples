/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025-2025. All rights reserved.
 */

import { cloudDatabase } from '@kit.CloudFoundationKit';
import { PicInfo } from '../model/PicInfo';
import { BusinessError } from '@kit.BasicServicesKit';
import { i18n } from '@kit.LocalizationKit';

const databaseZone = cloudDatabase.zone('QuickStartDemo');

let UI: CloudDatabasePage;

@Entry
@Component
struct CloudDatabasePage {
  @State showMessage: string = '';
  @State uploadFileName: string = '';
  private arr: string[] = [];

  aboutToAppear(): void {
    UI = this;
    let systemLanguage = i18n.System.getSystemLanguage();
    if (systemLanguage === 'zh-Hans') {
      this.arr = ['插入名称为‘左传’的数据', '查询所有数据', '查询名称为‘左传’的数据', '查询名称不等于‘左传’的数据',
        '查询名称以‘左’开始的数据', '查询名称以‘传’结尾的数据', '查询名称中包含‘d’的数据', '查询价格高于82.0的数据',
        '查询价格高于等于82.0的数据', '查询价格低于82.0的数据', '查询价格低于等于82.0的数据',
        '查询名称被包含在‘demo’,‘左传’中的数据', '查询价格为空的数据', '查询价格不为空的数据', '按价格升序查询',
        '按价格降序查询', '按价格降序查询最多两条数据',
        '使用beginGroup和endGroup查询价格小于200并且名称等于‘demo’的数据',
        '查询价格小于50或者名称等于‘demo’的数据', '查询价格大于40并且名称中包含‘j’的数据',
        '查询所有数据并对‘price’进行算术计算', '删除名称为‘左传’的数据'];
    } else {
      this.arr = [`Insert data named 'Zuo Zhuan'`, 'Query all data', `Query data named 'Zuo Zhuan'`,
        `Query data whose name is not 'Zuo Zhuan'`,
        `Query data whose name starts with 'Zuo'`, `Query data whose name ends with 'Zhuan'`,
        `Query data containing 'd' in the name`, 'Query data with price higher than 82.0',
        'Query data whose price is higher than or equal to 82.0', 'Query data with price lower than 82.0',
        'Query data whose price is lower than or equal to 82.0',
        `Query data whose name is contained in 'demo', 'Zuo Zhuan'`, 'Query data with empty price',
        'Query data whose price is not empty', 'Search by price in ascending order',
        'Search by price in descending order', 'Query up to two pieces of data in descending order by price',
        `Use beginGroup and endGroup to query data whose price is less than 200 and whose name is equal to 'demo'`,
        `Query data whose price is less than 50 or whose name is 'demo'`,
        `Query data whose price is greater than 40 and whose name contains 'j'`,
        `Query all data and perform arithmetic calculations on 'price'`, `Delete data named 'Zuo Zhuan'`];
    }
  }

  build() {
    Column() {
      Navigation()
        .title($r('app.string.cloud_database_title'))
        .height('50vp')
        .width('100%')
        .margin({ bottom: 10 })
        .titleMode(NavigationTitleMode.Mini)
      Row() {
        Column() {
          List({
            space: 20,
            initialIndex: 0
          }) {
            // eslint-disable-next-line @performance/hp-arkui-load-on-demand
            ForEach(this.arr, (item: string) => {
              ListItem() {
                this.newButton(item);
              }
            })
          }
          .listDirection(Axis.Vertical)
          .divider({
            strokeWidth: 2,
            color: 0xFFFFFF,
            startMargin: 20,
            endMargin: 20
          })
          .edgeEffect(EdgeEffect.Spring)
          .width('100%')
          .height('90%')
        }
      }.height('80%').width('100%');

      // eslint-disable-next-line @performance/hp-arkui-reduce-view-nest-level
      Row() {
        Text('messages:').fontSize(12).fontWeight(FontWeight.Bold).align(Alignment.BottomStart).width('100%');
      };

      Row() {
        TextArea({ text: this.showMessage })
          .fontSize(10)
          .align(Alignment.TopStart)
          .width('100%')
          .height('100%')
          .borderRadius(2)
          .backgroundColor('#fff3efef')
          .maxLines(1000)
      }.height('18%');
    }
  }

  @Builder
  newButton(title: string) {
    Row() {
      Button(title, { type: ButtonType.Normal })
        .borderRadius(4)
        .width('90%')
        .height(40)
        .margin({
          left: 20,
          right: 20
        })
        .fontSize(15)
        .onClick(async () => {
          this.showMessage = '';
          try {
            switch (title) {
              case this.arr[0]:
                this.upsert();
                break
              case this.arr[1]:
                this.queryAll();
                break
              case this.arr[2]:
                this.queryEqual();
                break
              case this.arr[3]:
                this.queryNotEqualTo();
                break
              case this.arr[4]:
                this.queryBeginsWith();
                break
              case this.arr[5]:
                this.queryEndsWith();
                break
              case this.arr[6]:
                this.queryContains();
                break
              case this.arr[7]:
                this.queryGreaterThan();
                break
              case this.arr[8]:
                this.queryGreaterThanOrEqualTo();
                break
              case this.arr[9]:
                this.queryLessThan();
                break
              case this.arr[10]:
                this.queryLessThanOrEqualTo();
                break
              case this.arr[11]:
                this.queryIn();
                break
              case this.arr[12]:
                this.queryIsNull();
                break
              case this.arr[13]:
                this.queryIsNotNull();
                break
              case this.arr[14]:
                this.queryOrderByAsc();
                break
              case this.arr[15]:
                this.queryOrderByDesc();
                break
              case this.arr[16]:
                this.queryOrderByLimit();
                break
              case this.arr[17]:
                this.queryBeginGroupEndGroup();
                break
              case this.arr[18]:
                this.queryOr();
                break
              case this.arr[19]:
                this.queryAnd();
                break
              case this.arr[20]:
                this.calculateQuery();
                break
              case this.arr[21]:
                this.delete();
                break
              default:
                break
            }

          } catch (e) {
            UI.printMessage(e.message);
            UI.printMessage(e.code);
            UI.printMessage(e.stack);
          }
        })
    }

    Row() {
    }.margin({ bottom: 4 })
  }

  printMessage(message: string) {
    UI.showMessage = UI.showMessage.concat(message + '\n');
  }

  isChinese(): boolean {
    let systemLanguage = i18n.System.getSystemLanguage();
    return systemLanguage === 'zh-Hans';
  }

  async upsert() {
    let pic = new PicInfo();
    pic.id = 11;
    if (this.isChinese()) {
      pic.picName = '左传';
    } else {
      pic.picName = 'Zuo Zhuan';
    }

    pic.price = 100.0;
    databaseZone.upsert(pic).then((record: number) => {
      UI.printMessage('Promise upsert success: ' + record);
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise upsert err: ' + err);
    });

    databaseZone.upsert(pic, (err: BusinessError, record: number) => {
      if (err) {
        UI.printMessage('Callback upsert err: ' + err);
        return;
      }
      UI.printMessage('Callback upsert success: ' + record);
    });
  }

  async queryAll() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryEqual() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    if (this.isChinese()) {
      condition.equalTo('picName', '左传');
    } else {
      condition.equalTo('picName', 'Zuo Zhuan');
    }

    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryNotEqualTo() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    if (this.isChinese()) {
      condition.notEqualTo('picName', '左传');
    } else {
      condition.notEqualTo('picName', 'Zuo Zhuan');
    }

    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryBeginsWith() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    if (this.isChinese()) {
      condition.beginsWith('picName', '左');
    } else {
      condition.beginsWith('picName', 'Zuo');
    }

    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryEndsWith() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    if (this.isChinese()) {
      condition.endsWith('picName', '传');
    } else {
      condition.endsWith('picName', 'Zhuan');
    }

    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryContains() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.contains('picName', 'd');
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryGreaterThan() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.greaterThan('price', 82.0);
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryGreaterThanOrEqualTo() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.greaterThanOrEqualTo('price', 82.0);
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryLessThan() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.lessThan('price', 82.0);
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryLessThanOrEqualTo() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.lessThanOrEqualTo('price', 82.0);
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryIn() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    if (this.isChinese()) {
      condition.in('picName', ['demo', '左传']);
    } else {
      condition.in('picName', ['demo', 'Zuo Zhuan']);
    }

    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryIsNull() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.isNull('price');
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryIsNotNull() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.isNotNull('price');
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryOrderByAsc() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.orderByAsc('price');
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryOrderByDesc() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.orderByDesc('price');
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryOrderByLimit() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.orderByDesc('price').limit(2, 0);
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryBeginGroupEndGroup() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.beginGroup()
      .lessThan('price', 200.0)
      .endGroup()
      .beginGroup()
      .equalTo('picName', 'demo')
      .endGroup();
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryOr() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.lessThan('price', 50.0).or().equalTo('picName', 'demo');
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async queryAnd() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.greaterThan('price', 40.0).and().contains('picName', 'j');
    databaseZone.query(condition).then((resultArray: PicInfo[]) => {
      resultArray.forEach((value) => {
        UI.printMessage('Promise query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise query err: ' + err);
    });

    databaseZone.query(condition, (err: BusinessError, resultArray: PicInfo[]) => {
      if (err) {
        UI.printMessage('Callback query err: ' + err);
        return;
      }
      resultArray.forEach((value) => {
        UI.printMessage('Callback query success: picName = ' + value.picName + '    price: ' + value.price?.toString());
      });
    });
  }

  async calculateQuery() {
    let condition = new cloudDatabase.DatabaseQuery(PicInfo);
    condition.lessThan('price', 1000);
    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.AVERAGE).then((num: number) => {
      UI.printMessage('Promise calculateQuery success: QueryCalculate.AVERAGE price  = ' + num);
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise calculateQuery err: ' + err);
    });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.AVERAGE,
      (err: BusinessError, num: number) => {
        if (err) {
          UI.printMessage('Callback calculateQuery err: ' + err);
          return;
        }
        UI.printMessage('Callback calculateQuery success: QueryCalculate.AVERAGE price  = ' + num);
      });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.SUM).then((num: number) => {
      UI.printMessage('Promise calculateQuery success: QueryCalculate.AVERAGE price  = ' + num);
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise calculateQuery err: ' + err);
    });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.SUM,
      (err: BusinessError, num: number) => {
        if (err) {
          UI.printMessage('Callback calculateQuery err: ' + err);
          return;
        }
        UI.printMessage('Callback calculateQuery success: QueryCalculate.SUM price  = ' + num);
      });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.MINIMUM).then((num: number) => {
      UI.printMessage('Promise calculateQuery success: QueryCalculate.MINIMUM price  = ' + num);
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise calculateQuery err: ' + err);
    });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.MINIMUM,
      (err: BusinessError, num: number) => {
        if (err) {
          UI.printMessage('Callback calculateQuery err: ' + err);
          return;
        }
        UI.printMessage('Callback calculateQuery success: QueryCalculate.MINIMUM price  = ' + num);
      });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.MAXIMUM).then((num: number) => {
      UI.printMessage('Promise calculateQuery success: QueryCalculate.MAXIMUM price  = ' + num);
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise calculateQuery err: ' + err);
    });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.MAXIMUM,
      (err: BusinessError, num: number) => {
        if (err) {
          UI.printMessage('Callback calculateQuery err: ' + err);
          return;
        }
        UI.printMessage('Callback calculateQuery success: QueryCalculate.MAXIMUM price  = ' + num);
      });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.COUNT).then((num: number) => {
      UI.printMessage('Promise calculateQuery success: QueryCalculate.COUNT price  = ' + num);
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise calculateQuery err: ' + err);
    });

    databaseZone.calculateQuery(condition, 'price', cloudDatabase.QueryCalculate.COUNT,
      (err: BusinessError, num: number) => {
        if (err) {
          UI.printMessage('Callback calculateQuery err: ' + err);
          return;
        }
        UI.printMessage('Callback calculateQuery success: QueryCalculate.COUNT price  = ' + num);
      });
  }

  async delete() {
    let pic = new PicInfo();
    pic.id = 11;
    databaseZone.delete(pic).then((deleteNum: number) => {
      UI.printMessage('Promise delete success: ' + deleteNum);
    }).catch((err: BusinessError) => {
      UI.printMessage('Promise delete err: ' + err);
    });

    databaseZone.delete(pic, (err: BusinessError, deleteNum: number) => {
      if (err) {
        UI.printMessage('Callback delete err: ' + err);
        return;
      }
      UI.printMessage('Callback delete success: ' + deleteNum);
    });
  }
}
