import "@glint/environment-ember-loose";
import "@glint/environment-ember-loose/native-integration";

import type { HelperLike } from "@glint/template";
// import type { ComponentLike, HelperLike, ModifierLike } from "@glint/template";
import type BuyNow from "polaris-starter/components/buy-now";
import type Table from "polaris-starter/components/table";
import type Tooltip from "polaris-starter/components/tooltip";

declare module "@glint/environment-ember-loose/registry" {
  export default interface Registry {
    // Examples
    // state: HelperLike<{ Args: {}, Return: State }>;
    // attachShadow: ModifierLike<{ Args: { Positional: [State['update']]}}>;
    BuyNow: typeof BuyNow;
    Table: typeof Table;
    Tooltip: typeof Tooltip;

    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    "page-title": HelperLike<{ Args: { Positional: any[] }; Return: string }>;
  }
}
