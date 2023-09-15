import {
  Grid,
  GridOptions,
  ICellRendererComp,
  ICellRendererParams,
  IServerSideGetRowsParams,
  ITooltipComp,
  ITooltipParams,
  TooltipShowEvent
} from 'ag-grid-enterprise';

import { modifier } from 'ember-modifier';
import Component from '@glimmer/component';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';

import productsFromJson from 'polaris-starter/products-data.json';

import {
  GridApi
} from 'ag-grid-enterprise';

import EmberCellRenderer from 'polaris-starter/utils/ember-cell-renderer';
import BuyNow from './buy-now'
class BuyButtonCellRenderer extends EmberCellRenderer {
  component = BuyNow;
}

import EmberTooltipRenderer from 'polaris-starter/utils/ember-tooltip-renderer';
import Tooltip from './tooltip'
class TooltipRenderer extends EmberTooltipRenderer {
  component = Tooltip;
}


/**
 * Custom sort function.  Normally the backend would do this for us,
 * but we'll simulate that here.
 */
const sortProducts = ({ products, key, direction }: {
  products: ProductsResponse['products'],
  key: keyof Product,
  direction: 'asc' | 'desc'
}) => {
  if (direction === 'asc') {
    return [...products].sort((a, b) => (a[key] > b[key] ? 1 : -1))
  }

  return [...products].sort((a, b) => (a[key] > b[key] ? -1 : 1))
}

interface Product {
  id: number;
  title: string;
  description: string;
  price: number;
  discountPercentage: number;
  rating: number;
  stock: number;
  brand: string;
  category: string;
  thumbnail: string;
  images: Array<string>;
}

interface ProductsResponse {
  products: Array<Product>;
}

export default class Table extends Component<{}> {
  agGridElement?: HTMLElement;
  agGridInstance?: Grid;

  // Instances of "ember cell" to render (visible in viewport or in buffer)
  @tracked emberCellRenderers: EmberCellRenderer[] = [];

  // There's no easy way to get TooltipRenderer instance when a custom tooltip is shown (like we do through `getCellRendererInstances` for custom cells)
  // This is a workarround allowing a custom tooltip to "register itself" before there are actually rendered.
  // It allows table component to properly render ember component as tooltip
  //
  // This workarround (+ usage of "data-ember-tooltip" attribute) could get away if :
  // - `onTooltipShow` event could include the TooltipComponent instance
  // or
  // - a kind of "getTooltipRendererInstance" method is added to Grid API
  readonly context = {
    activeTooltipRender: undefined,
  };
  // Current"ember tooltip" to render
  @tracked emberTooltipRenderer: EmberTooltipRenderer | undefined;

  MountModifier = modifier<{ Element: HTMLElement }>(
    (element) => {
      const gridOptions: GridOptions = {
        columnDefs: [
          { field: "id", headerName: "ID", width: 100, sortable: true, sort: "asc" },
          { field: "title", sortable: true },
          {
            field: "description",
            resizable: true,
            tooltipField: 'description',
            tooltipComponent: TooltipRenderer
          },
          { field: "price", sortable: true },
          { field: "discountPercentage" },
          { field: "rating", sortable: true },
          { field: "stock", sortable: true },
          { field: "brand", sortable: true },
          { field: "category", sortable: true },
          { field: "thumbnail", resizable: true },
          { field: "images", resizable: true },
          {
            field: 'buyNow',
            cellRenderer: BuyButtonCellRenderer,
            cellClass: "py-2"
          }
        ],
        rowModelType: 'serverSide',
        serverSideDatasource: {
          getRows: async (params: IServerSideGetRowsParams) => {
            // For now, let's only sort by one column
            const sortDirection = params?.request?.sortModel?.[0]?.sort;
            const sortColumn = params?.request?.sortModel?.[0]?.colId;

            // NOTE: This could stop working at any moment, so we shouldn't be
            //       **too** reliant on it.  Check out `products-data.json`
            //       if this stops working.
            //       Could also use https://www.ag-grid.com/example-assets/small-olympic-winners.json instead
            const response = await fetch("https://dummyjson.com/products");

            const results: ProductsResponse = response.ok
              ? await response.json()
              : productsFromJson;

            // Add an artifical sleep to simulate the backend doing any sorting
            await new Promise((r) => setTimeout(r, 500));

            const sorted =
              sortDirection && sortColumn
                ? sortProducts({
                    products: results.products,
                    key: sortColumn as keyof Product,
                    direction: sortDirection,
                  })
                : results.products;

            params.success({ rowData: sorted });
          }
        },

        // All events bellow are need to get ember cells rendered correctly
        onViewportChanged: this.updateCustomCellRendering,
        onFirstDataRendered: this.updateCustomCellRendering,
        onVirtualColumnsChanged: this.updateCustomCellRendering,

        // Custom ember tooltip rendering
        onTooltipShow: this.updateCustomTooltipRendering,
        tooltipHide: () => { this.context.emberTooltipRenderer = undefined },
        context: this.context,
      };

      this.agGridInstance = new Grid(element, gridOptions);

      this.agGridElement = element;
    }
  );

  @action
  updateCustomCellRendering({ api }: { api: GridApi } ) {
    const cellRenderers = api.getCellRendererInstances();
    if (!cellRenderers) {
      return;
    }

    const emberCellRenderers: EmberCellRenderer[] = [];
    for (const renderer of cellRenderers) {
      if (renderer instanceof EmberCellRenderer) {
        emberCellRenderers.push(renderer);
      }
    }
    this.emberCellRenderers = emberCellRenderers;
  }

  @action
  updateCustomTooltipRendering(e: TooltipShowEvent) {
    if (e.tooltipGui.hasAttribute('data-ember-tooltip') ){
      this.emberTooltipRenderer = this.context.activeTooltipRender
    }
  }

  <template>
    <div class="h-96 w-full max-w-7xl mx-auto p-4">
      <div {{this.MountModifier}} class="ag-theme-alpine h-full w-full" />
    </div>

    {{!-- Render ember component from custom cell renderers --}}
    {{#each this.emberCellRenderers as |renderer|}}
      {{#in-element renderer.target}}
        <renderer.component @params={{renderer.params}} />
      {{/in-element}}
    {{/each}}

    {{!-- Render ember component from custom tooltip renderer --}}
    {{#if this.emberTooltipRenderer}}
      {{#in-element this.emberTooltipRenderer.target}}
        <this.emberTooltipRenderer.component @params={{this.emberTooltipRenderer.params}} />
      {{/in-element}}
    {{/if}}
  </template>
}
