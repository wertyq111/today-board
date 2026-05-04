import { Want } from '@kit.AbilityKit';
import { FormExtensionAbility, formBindingData, formInfo, formProvider } from '@kit.FormKit';

import { CalendarService } from '../services/CalendarService';
import { TodayBoardSnapshotService } from '../services/TodayBoardSnapshotService';
import { WeatherService } from '../services/WeatherService';
import { SetupStore } from '../store/SetupStore';

export default class TodayBoardFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    TodayBoardSnapshotService.initialize();
    const formId = this.getFormId(want);
    if (formId.length > 0) {
      void this.refreshAndUpdate(formId);
    }
    return formBindingData.createFormBindingData(TodayBoardSnapshotService.createCardData());
  }

  onUpdateForm(formId: string): void {
    void this.refreshAndUpdate(formId);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    this.getFormId(want);
    return formInfo.FormState.READY;
  }

  private async refreshAndUpdate(formId: string): Promise<void> {
    TodayBoardSnapshotService.initialize();
    if (SetupStore.isSetupCompleted()) {
      await CalendarService.refresh(this.context, false);
      await WeatherService.refresh(this.context, false);
    }

    await formProvider.updateForm(
      formId,
      formBindingData.createFormBindingData(TodayBoardSnapshotService.createCardData())
    );
  }

  private getFormId(want: Want): string {
    const params = want.parameters;
    if (!params) {
      return '';
    }
    const formId = params[formInfo.FormParam.IDENTITY_KEY];
    return typeof formId === 'string' ? formId : '';
  }
}
