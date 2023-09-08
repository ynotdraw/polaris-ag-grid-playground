import { action } from '@ember/object';
import { Grid } from 'ag-grid-community';
import { modifier } from 'ember-modifier';
import { on } from '@ember/modifier';
import Component from '@glimmer/component';

import 'ag-grid-community/styles/ag-grid.css';
import 'ag-grid-community/styles/ag-theme-alpine.css';

export interface TableSignature {};

export default class Table extends Component<TableSignature> {
  agGridElement?: HTMLElement;
  agGridInstance?: Grid;

  MountModifier = modifier<{ Element: HTMLElement }>(
    (element) => {
      const gridOptions = {
        columnDefs: [
          { headerName: 'Make', field: 'make' },
          { headerName: 'Model', field: 'model' },
          { headerName: 'Price', field: 'price' }
        ],
        rowData: [
          { make: 'Toyota', model: 'Celica', price: 35000 },
          { make: 'Ford', model: 'Mondeo', price: 32000 },
          { make: 'Porsche', model: 'Boxster', price: 72000 }
        ]
      };

      this.agGridInstance = new Grid(element, gridOptions);

      this.agGridElement = element;
    }
  );

  @action
  logGridElement() {
    console.log(this.agGridElement);
  }

  @action
  logGridInstance() {
    console.log(this.agGridInstance);
  }

  <template>
    <div id="myGrid" {{this.MountModifier}} class="ag-theme-alpine h-96 w-full max-w-7xl mx-auto p-4" />

    <p>Debugging buttons!</p>
    <button {{on 'click' this.logGridElement}}>element</button>
    <button {{on 'click' this.logGridInstance}}>instance</button>
  </template>
}
