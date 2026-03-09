import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ScholarPaperRoute extends DiscourseRoute {
  @service router;

  model(params) {
    return ajax(`/scholar/paper/${encodeURIComponent(params.paperId)}.json`).catch(
      (error) => {
        if (error.jqXHR?.status === 404) {
          return this.router.replaceWith("/404");
        }

        return {
          load_error: true,
          error_message: error.jqXHR?.responseJSON?.errors?.[0],
        };
      }
    );
  }
}
