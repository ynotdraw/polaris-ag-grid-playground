import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';

import Component from '@glimmer/component';

import {
  Grid,
  GridApi
} from 'ag-grid-enterprise';
import { modifier } from 'ember-modifier';
import { tracked } from '@glimmer/tracking';
import { action } from '@ember/object';

import productsFromJson from 'polaris-starter/products-data.json';

import type {
  GridOptions,
  ICellRendererComp,
  ICellRendererParams,
  IServerSideGetRowsParams,
  ITooltipComp,
  ITooltipParams
} from 'ag-grid-enterprise';

import EmberCellRenderer from 'polaris-starter/utils/ember-cell-renderer';
import BuyNow from './buy-now'
class BuyButtonCellRenderer extends EmberCellRenderer<string> {
  component = BuyNow;
}

/**
 * Renders a custom tooltip for the Description column. I wanted to see how easy it was
 * to render custom tooltip components.
 */
class DescriptionTooltip implements ITooltipComp {
  eGui!: HTMLDivElement;

  init(params: ITooltipParams) {
    this.eGui = document.createElement('div');
    this.eGui.className = 'bg-slate-600 text-white rounded-md p-2';
    this.eGui.innerHTML = `${params.data?.description}`;
  }

  getGui() {
    return this.eGui;
  }
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
            // There's not "easy" way to retrieve Tooltip instances to render custom tooltip the same way we do with cell.
            // Could we use custom cell & implement our own tooltip ?
            tooltipComponent: DescriptionTooltip
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

  <template>
    <div class="h-96 w-full max-w-7xl mx-auto p-4">
      <div {{this.MountModifier}} class="ag-theme-alpine h-full w-full" />
    </div>

    {{!-- Render ember component from custom cell renderer --}}
    {{#each this.emberCellRenderers as |renderer|}}
      {{#in-element renderer.target}}
        <renderer.component @params={{renderer.params}} />
      {{/in-element}}
    {{/each}}
  </template>
}
