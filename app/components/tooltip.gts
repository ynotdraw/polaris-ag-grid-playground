import Component from '@glimmer/component';

export default class Tooltip extends Component<{}> {
  <template>
    <div class="bg-slate-600 text-white rounded-md p-2">{{@params.data.description}}</div>
  </template>
}
