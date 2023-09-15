import { guidFor } from '@ember/object/internals';
import { tracked } from '@glimmer/tracking';

import type Component from '@glimmer/component';
import type { ITooltipComp, ITooltipParams, TooltipShowEvent } from 'ag-grid-community';


abstract class EmberTooltipRenderer<T = any> implements ITooltipComp {
  private id = guidFor(this); 
  abstract component?: typeof Component | string;

  target: HTMLDivElement;
  
  @tracked params?: ITooltipParams<T>;

  constructor() {
    this.target = document.createElement('div');
    this.target.setAttribute('id', this.id);
    this.target.setAttribute('data-ember-tooltip', '');
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
