/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 */

import { BusinessError } from '@kit.BasicServicesKit';
import { guardService } from '@kit.ScreenTimeGuardKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { Constants } from '../common/Constants';
import { ControlStrategyMode } from '../common/ControlStrategyMode';
import { ToastUtils } from '../utils/ToastUtils';
import Utils from '../utils/Utils';

export class StrategyGuardApps {
  private logTag: string = 'StrategyGuardApps';
  private domainId: number = 0x0000;
  private guardStrategy: guardService.GuardStrategy = this.getDefaultGuardStrategy();
  private isStartControl: boolean = false;

  private getDefaultGuardStrategy(): guardService.GuardStrategy {
    let guardStrategy: guardService.GuardStrategy = {
      name: '',
      timeStrategy: { type: guardService.TimeStrategyType.START_END_TIME_TYPE },
      appInfo: { appTokens: [] },
      appRestrictionType: guardService.RestrictionType.BLOCKLIST_TYPE
    }
    return guardStrategy;
  }

  /**
   * Determine whether control is currently enabled
   *
   * @returns { boolean } whether the control has been enabled
   */
  public isStartControlApps(): boolean {
    return this.isStartControl;
  }

  /**
   * Set strategy name
   *
   * @param name - strategy name
   */
  public setGuardStrategyName(name: string): void {
    this.guardStrategy.name = name;
  }

  /**
   * set appInfo of the strategy
   *
   * @param appInfo - App Information
   */
  public setAppInfo(appInfo: guardService.AppInfo): void {
    this.guardStrategy.appInfo = appInfo;
  }

  /**
   * set time strategy of the guard strategy
   *
   * @param timeStrategy - time strategy of the guard strategy
   */
  public setTimeStrategy(timeStrategy: guardService.TimeStrategy): void {
    this.guardStrategy.timeStrategy = timeStrategy;
  }

  /**
   * get guard strategy name
   *
   * @returns { string } the name of the strategy
   */
  public getGuardStrategyName(): string {
    return this.guardStrategy.name;
  }

  /**
   * get strategy object
   *
   * @returns { guardService.GuardStrategy } the strategy object
   */
  public getGuardStrategy(): guardService.GuardStrategy {
    return this.guardStrategy;
  }

  /**
   * query configured guard strategies
   *
   * @returns { guardService.GuardStrategy[] } the configured guard strategies
   */
  public async getGuardStrategies(): Promise<guardService.GuardStrategy[]> {
    let guardStrategies: guardService.GuardStrategy[] = await guardService.queryGuardStrategies();
    return guardStrategies;
  }

  /**
   * set app restriction
   *
   * @param restrictionType - restriction type of the strategy
   */
  private restrictApps(restrictionType: guardService.RestrictionType): void {
    guardService.setAppsRestriction(this.guardStrategy.appInfo, restrictionType)
      .then(() => {
        this.isStartControl = true;
        ToastUtils.showShortToastNormal($r('app.string.control_set_success_desc'));
      }).catch((error: BusinessError) => {
        hilog.error(this.domainId, this.logTag,
          `setAppsRestriction fail, errCode is ${error.code}, errMessage is ${error.message}`);
        Utils.dealAllError(error);
    })
  }

  /**
   * check whether the customized guard strategy exists
   *
   * @returns { boolean } true - strategy exist, false - strategy does not exist
   */
  private async isStrategyExist(): Promise<boolean> {
    try {
      let guardStrategies: guardService.GuardStrategy[] = await guardService.queryGuardStrategies();
      for (let i = 0; i < guardStrategies.length; i++) {
        if (guardStrategies[i].name === Constants.STRATEGY_NAME) {
          return true;
        }
      }
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `queryGuardStrategies failed, errCode is ${error.code}, errMessage is ${error.message}`);
    }
    return false;
  }

  /**
   * start guard strategy: if the guard strategy exists, stop the strategy first, then update the strategy; if it does
   * not exist, add the strategy directly. Finally, start the guard strategy.
   *
   */
  private async startStrategiesControl(): Promise<void> {
    try {
      if (await this.isStrategyExist()) {
        await guardService.stopGuardStrategy(Constants.STRATEGY_NAME);
        await guardService.updateGuardStrategy(Constants.STRATEGY_NAME, this.getGuardStrategy());
        hilog.info(this.domainId, this.logTag, 'stopGuardStrategy and updateGuardStrategy success');
      } else {
        await guardService.addGuardStrategy(this.getGuardStrategy());
        hilog.info(this.domainId, this.logTag, 'addGuardStrategy success');
      }
      await guardService.startGuardStrategy(this.getGuardStrategyName());
      this.isStartControl = true;
      ToastUtils.showShortToastNormal($r('app.string.control_set_success_desc'));
      hilog.info(this.domainId, this.logTag, 'addGuardStrategy and startGuardStrategy success');
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `startStrategiesControl failed, errCode is ${error.code}, errMessage is ${error.message}`);
      Utils.dealAllError(error);
    }
  }

  /**
   * apply guard strategies based on the strategy mode
   *
   * @param strategyMode - indicate whether the strategy takes effect immediately or according to a configured policy.
   */
  public controlApps(strategyMode: ControlStrategyMode): void {
    switch (strategyMode) {
      case ControlStrategyMode.EFFECTED_IMMEDIATELY:
        this.restrictApps(guardService.RestrictionType.BLOCKLIST_TYPE);
        break;
      case ControlStrategyMode.USER_DEFINED_CONTROL_RULE:
        this.startStrategiesControl();
        break;
      default:
        hilog.error(this.domainId, this.logTag, `wrong strategyMode: ${strategyMode}`);
        break;
    }
  }

  /**
   * stop and remove guard strategy
   *
   */
  public async cancelControlApps(): Promise<void> {
    // Unrestrict app usage
    try {
      await guardService.releaseAppsRestriction(this.guardStrategy.appInfo,
        guardService.RestrictionType.BLOCKLIST_TYPE);
      ToastUtils.showShortToastNormal($r('app.string.control_cancel_success_desc'));
    } catch (error) {
      hilog.error(this.domainId, this.logTag,
        `releaseAppsRestriction failed, errCode is ${error.code}, errMessage is ${error.message}`);
      Utils.dealAllError(error);
    }

    // stop and remove guard strategy
    try {
      let guardStrategies: guardService.GuardStrategy[] = await this.getGuardStrategies();
      hilog.info(this.domainId, this.logTag, `queries strategies length: ${guardStrategies.length}`);
      for (let guardStrategy of guardStrategies) {
        if (guardStrategy.name !== Constants.STRATEGY_NAME) {
          continue;
        }
        await guardService.stopGuardStrategy(guardStrategy.name);
        await guardService.removeGuardStrategy(guardStrategy.name);
        ToastUtils.showShortToastNormal($r('app.string.control_cancel_success_desc'));
      }
    } catch (error) {
        hilog.error(this.domainId, this.logTag,
          `stop and remove GuardStrategy failed, errCode is ${error.code}, errMessage is ${error.message}`);
        Utils.dealAllError(error);
    }
    this.isStartControl = false;
  }
}