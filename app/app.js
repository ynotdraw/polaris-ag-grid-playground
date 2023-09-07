import Application from "@ember/application";

import loadInitializers from "ember-load-initializers";
import Resolver from "ember-resolver";
import config from "polaris-starter/config/environment";
import "polaris-starter/app.css";

export default class App extends Application {
  modulePrefix = config.modulePrefix;
  podModulePrefix = config.podModulePrefix;
  Resolver = Resolver;
}

loadInitializers(App, config.modulePrefix);
