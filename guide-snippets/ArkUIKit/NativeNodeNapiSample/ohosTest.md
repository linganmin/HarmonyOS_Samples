# 测试用例归档

## 用例表

| 测试功能                                 | 预置条件     | 输入                                                         | 预期显示                                | 是否自动 | 测试结果 |
| ---------------------------------------- | ------------ | ------------------------------------------------------------ | --------------------------------------- | -------- | -------- |
| 启动应用                                 | 设备正常运行 | 1.开启开发板 <br/>2.编译hap包并将hap包及环境烧录进开发板，运行测试用例<br /> | 成功拉起应用。                          | 否       | 验证通过 |
| swiper正确获取navigation和router相关信息 | 应用位于首页 | 1.点击首页navigation按钮<br/>2.点击pushPath按钮              | 1.获取到以A0ff00/Manager为tag的相关日志 | 否       | 验证通过 |
| 测试ArkTS侧创建的DrawableDescriptor对象映射到Native侧接口1 | 应用位于首页 | 1.点击首页Mapping DrawableDescriptor按钮<br/>2.点击方式1:GetDrawableDescriptorFromNapiValue按钮              | 1.界面显示 测试结果: 方式1映射DrawableDescriptor成功 | 否       | 验证通过 |
| 测试ArkTS侧创建的DrawableDescriptor对象映射到Native侧接口2 | 应用位于首页 | 1.点击首页Mapping DrawableDescriptor按钮<br/>2.点击方式2:GetDrawableDescriptorFromResourceNapiValue按钮              | 1.界面显示 测试结果: 方式2映射DrawableDescriptor成功 | 否       | 验证通过 |