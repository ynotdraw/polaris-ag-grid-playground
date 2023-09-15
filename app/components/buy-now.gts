import Component from '@glimmer/component';
import { on } from '@ember/modifier';
import { action } from '@ember/object';

import type { ICellRendererParams } from 'ag-grid-community';

interface Signature {
  Args: {
    params: ICellRendererParams;
  }
  Element: HTMLButtonElement;
}


export default class BuyNow extends Component<Signature> {
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

  <template>
    <button
      class="rounded bg-indigo-600 px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 flex items-center gap-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600"
      type="button"
      {{on "click" this.buy}}
    >
      <svg
        xmlns="http://www.w3.org/2000/svg"
        width="24"
        height="24"
        stroke="currentColor"
        viewBox="0 0 24 24"
        data-icon="SvgShoppingCart"
        aria-hidden="true"
        class="w-4 h-4"
      >
        <path
          d="M20.112 19.4a1.629 1.629 0 11-1.629-1.629 1.63 1.63 0 011.629 1.629zM9.941 17.768a1.629 1.629 0 101.628 1.632 1.629 1.629 0 00-1.628-1.632zM3 3.006h1.678a2.113 2.113 0 011.965 1.573l2.051 9.152a2.114 2.114 0 001.965 1.574h6.788a2.153 2.153 0 001.989-1.568L20.957 8.8a1.233 1.233 0 00-1.236-1.588L11.4 7.064"
          fill="none"
          strokeLinecap="round"
          strokeLinejoin="round"
          strokeWidth="2"
        ></path>
      </svg>
      <span>Buy now</span>
    </button>
  </template>
}
