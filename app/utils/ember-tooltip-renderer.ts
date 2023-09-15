import { tracked } from "@glimmer/tracking";
import { guidFor } from "@ember/object/internals";

import type Component from "@glimmer/component";
import type { ITooltipComp, ITooltipParams } from "ag-grid-community";

abstract class EmberTooltipRenderer<T = unknown> implements ITooltipComp {
  private id = guidFor(this);
  abstract component: typeof Component<{ params: ITooltipParams<T> }>;

  target: HTMLDivElement;

  @tracked declare params: ITooltipParams<T>;

  constructor() {
    this.target = document.createElement("div");
    this.target.setAttribute("id", this.id);
    this.target.setAttribute("data-ember-tooltip", "");
  }

  init(params: ITooltipParams<T>) {
    this.params = params;
    params.context.activeTooltipRender = this;
  }

  getGui() {
    return this.target;
  }
}

export default EmberTooltipRenderer;
