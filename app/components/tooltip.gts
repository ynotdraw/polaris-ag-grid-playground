import Component from '@glimmer/component';

import type { ITooltipParams } from 'ag-grid-community';

interface Signature {
  Args: {
    params: ITooltipParams;
  }
  Element: HTMLButtonElement;
}
//eslint-disable-next-line ember/no-empty-glimmer-component-classes
export default class Tooltip extends Component<Signature> {
  <template>
    <div class="bg-slate-600 text-white rounded-md p-2">{{@params.data.description}}</div>
  </template>
}
