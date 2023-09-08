import { Grid, GridOptions, IServerSideGetRowsParams } from 'ag-grid-enterprise';
import { modifier } from 'ember-modifier';
import Component from '@glimmer/component';

import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';

import productsFromJson from 'polaris-starter/products-data.json'

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
