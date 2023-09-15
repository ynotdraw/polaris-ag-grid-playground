import Component from '@glimmer/component';
import { action } from '@ember/object';
import type { ICellRendererParams } from 'ag-grid-community';


type Args = {
  params: ICellRendererParams
}

export default class BuyNow extends Component<Args> {
  @action
  buy() {
    alert(
      `You selected "${
        this.args.params.data?.title
      }" to purchase for ${Intl.NumberFormat("us", {
        style: "currency",
        currency: "USD",
      }).format(this.args.params.data?.price)}`
    )
  }
}
