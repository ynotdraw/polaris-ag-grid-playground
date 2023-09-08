import Controller from "@ember/controller";

export default class ApplicationController extends Controller {
  get navigationOptions() {
    return [
      { name: "Nav1", href: "#" },
      { name: "Nav2", href: "#" },
      { name: "Nav3", href: "#" },
      { name: "Nav4", href: "#" },
    ];
  }
}
