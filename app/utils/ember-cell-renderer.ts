import { tracked } from "@glimmer/tracking";
import { guidFor } from "@ember/object/internals";

import type Component from "@glimmer/component";
import type { ICellRendererComp, ICellRendererParams } from "ag-grid-community";

abstract class EmberCellRenderer<T = unknown> implements ICellRendererComp {
  private id = guidFor(this);

  /**
   * In case we want to be able to use template only component we could type this as Component<...> | string
   * + use {{component cellRender.component params=cellRender.params}}
   * instead of invoking the component directly in "Table" component template.
   */
  abstract component: typeof Component<{ params: ICellRendererParams<T> }>;

  target: HTMLDivElement;

  @tracked declare params: ICellRendererParams<T>;

  constructor() {
    this.target = document.createElement("div");
    this.target.setAttribute("id", this.id);
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
}

export default EmberCellRenderer;
