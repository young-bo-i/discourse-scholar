import { ajax } from "discourse/lib/ajax";
import DiscourseRoute from "discourse/routes/discourse";

export default class ScholarSearchRoute extends DiscourseRoute {
  queryParams = {
    q: {
      refreshModel: true,
    },
    page: {
      refreshModel: true,
    },
    source: {
      refreshModel: true,
    },
  };

  model(params) {
    const source = params.source || "stc";

    if (!params.q?.trim()) {
      return {
        query: "",
        papers: [],
        authors: [],
        page: 1,
        total_papers: 0,
        total_pages: 1,
        source,
      };
    }

    const page = Math.max(parseInt(params.page, 10) || 1, 1);
    const qs = `q=${encodeURIComponent(params.q)}&page=${page}&source=${source}`;

    return ajax(`/scholar/search.json?${qs}`)
      .then((result) => ({ ...result, source }))
      .catch((error) => ({
        query: params.q,
        papers: [],
        authors: [],
        page,
        total_papers: 0,
        total_pages: 1,
        source,
        load_error: true,
        error_message: error.jqXHR?.responseJSON?.errors?.[0],
      }));
  }
}
