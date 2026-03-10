import DiscourseRoute from "discourse/routes/discourse";

export default class ScholarRoute extends DiscourseRoute {
  activate() {
    super.activate(...arguments);
    document.body.classList.add("scholar-active");
  }

  deactivate() {
    super.deactivate(...arguments);
    document.body.classList.remove("scholar-active");
  }
}
