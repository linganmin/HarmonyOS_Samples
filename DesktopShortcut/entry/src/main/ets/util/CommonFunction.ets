import { Want } from "@kit.AbilityKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { hilog } from "@kit.PerformanceAnalysisKit";
import { UIContext } from "@kit.ArkUI";

export function goToSpecifyPage(context: UIContext, want?: Want) {
  let shortCutKey = want?.parameters?.shortCutKey;

  if (shortCutKey && shortCutKey === 'CompanyPage') {
    context.getRouter().pushUrl({
      url: 'pages/GoCompany'
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `Failed to push url. Code is ${err.code},message is ${err.message}`);
    });
  }
  if (shortCutKey && shortCutKey === 'HousePage') {
    context.getRouter().pushUrl({
      url: 'pages/GoHouse'
    }).catch((err: BusinessError) => {
      hilog.error(0x0000, 'testTag', `Failed to push url. Code is ${err.code},message is ${err.message}`);
    });
  }
}