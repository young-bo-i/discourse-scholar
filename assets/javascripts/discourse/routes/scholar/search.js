import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ScholarSearchRoute extends DiscourseRoute {
  queryParams = {
    q: {
      refreshModel: true,
    },
  };

  model(params) {
    if (!params.q?.trim()) {
      return {
        query: "",
        papers: [],
        authors: [],
      };
    }

    return ajax(`/scholar/search.json?q=${encodeURIComponent(params.q)}`).catch(
      (error) => ({
        query: params.q,
        papers: [],
        authors: [],
        load_error: true,
        error_message: error.jqXHR?.responseJSON?.errors?.[0],
      })
    );
  }
}
