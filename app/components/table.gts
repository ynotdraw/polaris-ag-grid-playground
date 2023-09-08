import {
  Grid,
  GridOptions,
  ICellRendererComp,
  ICellRendererParams,
  IServerSideGetRowsParams
} from 'ag-grid-enterprise';
import { modifier } from 'ember-modifier';
import Component from '@glimmer/component';

import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';

import productsFromJson from 'polaris-starter/products-data.json';

/**
 * Renders a "Buy now" button in  the last column. This is mostly testing how easy it is to
 * add a custom cell renderer with AG Grid. Due to not having an Ember library for AG Grid,
 * these components must be built using JavaScript and handle their own event handlers.
 */
class BuyNowCell implements ICellRendererComp {
  eGui!: HTMLButtonElement;
  eValue: any;
  cellValue: any;
  eventListener!: () => void;

  // gets called once before the renderer is used
  init(params: ICellRendererParams) {
    this.eGui = document.createElement('button');
    this.eGui.className = 'rounded bg-indigo-600 px-2 py-1 text-sm font-semibold text-white shadow-sm hover:bg-indigo-500 focus-visible:outline focus-visible:outline-2 flex items-center gap-2 focus-visible:outline-offset-2 focus-visible:outline-indigo-600';

    this.eGui.innerHTML = `
      <svg
          xmlns="http://www.w3.org/2000/svg"
          width="24"
          height="24"
          stroke="currentColor"
          viewBox="0 0 24 24"
          data-icon="SvgShoppingCart"
          aria-hidden="true"
          className="w-4 h-4"
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
    `;

    this.eventListener = () => alert(
          `You selected "${
            params.data?.title
          }" to purchase for ${Intl.NumberFormat("us", {
            style: "currency",
            currency: "USD",
          }).format(params.data?.price)}`
        );
    this.eGui.addEventListener('click', this.eventListener);
  }

  // Mandatory - Return the DOM element of the component, this is what the grid puts into the cell
  getGui() {
    return this.eGui;
  }

  // Optional - Gets called once by grid after rendering is finished - if your renderer needs to do any cleanup,
  // do it here
  destroy() {
    if (this.eGui) {
      this.eGui.removeEventListener('click', this.eventListener);
    }
  }

  // Mandatory - Get the cell to refresh. Return true if the refresh succeeded, otherwise return false.
  // If you return false, the grid will remove the component from the DOM and create
  // a new component in its place with the new values.
  refresh(params: ICellRendererParams) {
    // set value into cell again
    this.cellValue = this.getValueToDisplay(params);
    this.eValue.innerHTML = this.cellValue;

    // return true to tell the grid we refreshed successfully
    return true;
  }

  getValueToDisplay(params: ICellRendererParams) {
    return params.valueFormatted ? params.valueFormatted : params.value;
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

export interface TableSignature {};

export default class Table extends Component<TableSignature> {
  agGridElement?: HTMLElement;
  agGridInstance?: Grid;

  MountModifier = modifier<{ Element: HTMLElement }>(
    (element) => {
      const gridOptions: GridOptions = {
        columnDefs: [
          { field: "id", headerName: "ID", width: 100, sortable: true, sort: "asc" },
          { field: "title", sortable: true },
          {
            field: "description",
            resizable: true,
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
            cellRenderer: BuyNowCell,
            width: 150
          }
        ],
        rowModelType: 'serverSide',
        serverSideDatasource: {
          getRows: async (params: IServerSideGetRowsParams) => {
            // For now, let's only sort by one column
            const sortDirection = params?.request?.sortModel?.[0]?.sort;
            const sortColumn = params?.request?.sortModel?.[0]?.colId;

            // Uncomment this back out when ready to re-add data fetching!
            // const response = await fetch("https://dummyjson.com/products");

            // if (!response.ok) {
            //   console.error('The API request failed.')
            //   return;
            // }

            // const results: ProductsResponse = await response.json();

            // params.success({ rowData: results.products });

            // Add an artifical sleep to simulate the backend doing any sorting
            await new Promise(r => setTimeout(r, 500));

            const sorted = sortDirection && sortColumn
              ? sortProducts({
                  products: productsFromJson.products,
                  key: (sortColumn as keyof Product),
                  direction: sortDirection
                })
              : productsFromJson.products;

            params.success({ rowData: sorted });
          }
        }
      };

      this.agGridInstance = new Grid(element, gridOptions);

      this.agGridElement = element;
    }
  );

  <template>
    <div class="h-96 w-full max-w-7xl mx-auto p-4">
      <div {{this.MountModifier}} class="ag-theme-alpine h-full w-full" />
    </div>
  </template>
}
