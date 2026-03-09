import { service } from "@ember/service";
import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ScholarAuthorRoute extends DiscourseRoute {
  @service router;

  model(params) {
    return ajax(`/scholar/author/${encodeURIComponent(params.authorId)}.json`).catch(
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
