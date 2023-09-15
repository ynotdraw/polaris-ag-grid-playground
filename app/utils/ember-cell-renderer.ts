import { guidFor } from '@ember/object/internals';
import { tracked } from '@glimmer/tracking';

import type Component from '@glimmer/component';
import type { ICellRendererComp, ICellRendererParams } from 'ag-grid-community';

abstract class EmberCellRenderer<T = any> implements ICellRendererComp {
  private id = guidFor(this);
  abstract component?: typeof Component | string;

  target: HTMLDivElement;

  @tracked params?: ICellRendererParams<T>;

  constructor() {
    this.target = document.createElement('div');
    this.target.setAttribute('id', this.id);
  }

  // gets called once before the renderer is used
  init(params: ICellRendererParams<T>) {
    this.params = params;
  }

  getGui() {
    return this.target;
  }

  // gets called whenever the cell refreshes
  refresh(params: ICellRendererParams<T>) {
    this.params = params;
    return true;
  }

  // gets called when the cell is removed from the grid
  destroy() {
    // debugger;
    // Nothing to do ?
  }
}

export default EmberCellRenderer;
