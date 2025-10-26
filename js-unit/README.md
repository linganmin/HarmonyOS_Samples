# 基于JsUnit实现单元功能测试

### 介绍
本示例展示测试框架中单元测试框架的使用示例，便于开发者正确使用单元测试框架。

本实例用到了自动化测试框架代码部件仓arkXtest，如需日志打印调试，需要引入日志打印接口@ohos.hilog。

单元测试用例相较于UI自动化测试用例而言更偏重于接口返回数据的校验及逻辑处理。

### 效果预览
不涉及

使用说明
- 将JsUnit目录下的项目工程整体导入到DevEco Studio开发工具中。
- 查看ohostest目录下的测试代码实现。
- 在DevEco Studio中执行测试用例代码查看执行效果，执行方式请参考官网指南的测试框架章节。

### 工程目录

```
├──entry/src/ohosTest/ets                         // 代码区
│  ├──test
│  │  ├──assertExampleTest                        
│  │  │  └──assertExample.test.ets                // 断言自动化测试脚本
│  │  ├──basicExampleTest                        
│  │  │  └──basicExample.test.ets                 // 基础自动化测试脚本
│  │  ├──callBackExampleTest                        
│  │  │  └──callBackExample.test.ets              // 回调自动化测试脚本
│  │  ├──coverExampleTest                        
│  │  │  └──coverExample.test.ets                 // 嵌套自动化测试脚本
│  │  ├──customExampleTest                        
│  │  │  └──customExample.test.ets                // 通用自动化测试脚本
│  │  ├──paramExampleTest                        
│  │  │  └──paramExample.test.ets                 // 参数自动化测试脚本
│  │  ├──data.json                                // json数据文件
│  │  └──List.test.ets                            // 测试脚本列表
│  ├──testability
│  │  ├──pages
│  │  │  └──Index.ets                             // 首页页面
│  │  └──TestAbility.ets   
│  ├──testrunner                       
│  │  └──OpenHarmonyTestRunner.ets                
│  └──util                       
│     └──Logger.ets                                // 日志工具类
└──entry/src/ohosTest/resources                    // 应用资源目录
```

### 具体实现

#### jsunit单元测试框架示例内容
* 1）在entry的index.ets中放页面组件。
* 2）在ohosTest的test/basicExample.test.ets中it()定义一条测试用例，支持三个参数：用例名称，过滤参数和用例函数。用例操作的行为以异步的形式编写。
* 3）通过Want配置指定唯一的ability即entry：通过want()中指定bundleName：com.samples.test.jsunit和abilityName：EntryAbility。
* 4）启动指定ability(相当于手动运行hap)：通过abilityDelegatorRegistry.getAbilityDelegator.startAbility(want)。
* 5）获取当前应用最顶层的ability对象：通过abilityDelegatorRegistry.getAbilityDelegator.getCurrentTopAbility().then((ability)=>{}) 。
* 6）在第5步.then()中加入需要测试内容：
    * 例如本案例中需要检验当前UIAbility的abilityname是否正确，在第五步中引入断言接口，并检查断言结果是否符合预期：通过expect().assertEqual()断言检查实际值（actualvalue）是否等于期望值（expectvalue）。
* 7）测试完毕： done();

### 相关权限
不涉及

### 依赖
不涉及

### 约束与限制

1.本示例仅支持标准系统上运行，支持设备：华为手机。

2.HarmonyOS系统：HarmonyOS 5.0.5 Release及以上。

3.DevEco Studio版本：DevEco Studio 5.0.5 Release及以上。

4.HarmonyOS SDK版本：HarmonyOS 5.0.5 Release SDK及以上。
