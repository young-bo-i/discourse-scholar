import { click, currentURL, fillIn, settled, visit } from "@ember/test-helpers";
import { test } from "qunit";
import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("Discourse Scholar", function (needs) {
  needs.settings({
    discourse_scholar_enabled: true,
  });

  needs.pretender((server, helper) => {
    server.get("/scholar/paper/test-paper.json", () =>
      helper.response({
        id: "stc:test-paper",
        route_id: "test-paper",
        source: "stc",
        title: "Hybrid Interfaces for Academic Discovery",
        abstract: "A paper about balancing reading and metadata views.",
        year: 2026,
        publication_date: "2026-03-09",
        venue: "Proceedings of Academic UX",
        doi: "10.1000/test-paper",
        doi_url: "https://doi.org/10.1000/test-paper",
        citation_count: 17,
        reference_count: 8,
        is_open_access: true,
        url: "https://example.com/test-paper",
        pdf_url: "https://example.com/test-paper.pdf",
        fields_of_study: ["Computer Science", "Information Retrieval"],
        authors: [
          {
            path: "/scholar/author/author-1",
            name: "Ada Lovelace",
            affiliations: ["Analytical Engine Institute"],
          },
        ],
      })
    );

    server.get("/scholar/paper/missing-paper.json", () => helper.response(404, {}));
    server.get("/scholar/paper/unavailable-paper.json", () =>
      helper.response(503, { errors: ["Service unavailable"] })
    );

    server.get("/scholar/author/author-1.json", () =>
      helper.response({
        id: "stc:author-1",
        route_id: "author-1",
        name: "Ada Lovelace",
        affiliations: ["Analytical Engine Institute"],
        paper_count: 12,
        citation_count: 99,
        h_index: 10,
        papers: [
          {
            id: "stc:test-paper",
            route_id: "test-paper",
            title: "Hybrid Interfaces for Academic Discovery",
            year: 2026,
            path: "/scholar/paper/test-paper",
          },
        ],
      })
    );

    server.get("/scholar/author/missing-author.json", () => helper.response(404, {}));

    server.get("/scholar/search.json", (request) => {
      if (request.queryParams.q === "broken") {
        return helper.response(503, { errors: ["Search unavailable"] });
      }

      return helper.response({
        query: request.queryParams.q,
        papers: [
          {
            id: "stc:test-paper",
            route_id: "test-paper",
            title: "Hybrid Interfaces for Academic Discovery",
            authors: ["Ada Lovelace"],
            year: 2026,
            path: "/scholar/paper/test-paper",
          },
        ],
        authors: [
          {
            id: "stc:author-1",
            route_id: "author-1",
            name: "Ada Lovelace",
            affiliations: ["Analytical Engine Institute"],
            paper_count: 12,
            path: "/scholar/author/author-1",
          },
        ],
      });
    });

    server.get("/scholar/autocomplete.json", () =>
      helper.response({
        items: [
          {
            type: "paper",
            label: "Hybrid Interfaces for Academic Discovery",
            path: "/scholar/paper/test-paper",
          },
          {
            type: "author",
            label: "Ada Lovelace",
            subtext: "Analytical Engine Institute",
            path: "/scholar/author/author-1",
          },
        ],
      })
    );
  });

  test("renders a public paper detail page", async function (assert) {
    await visit("/scholar/paper/test-paper");

    assert.dom(".paper-detail-page__title").hasText(
      "Hybrid Interfaces for Academic Discovery"
    );
    assert.dom(".scholar-search-box__input").exists();
    assert
      .dom(".paper-detail-page__authors")
      .includesText("Ada Lovelace");
    assert
      .dom(".paper-detail-page__abstract")
      .includesText("balancing reading and metadata views");
    assert.dom(".paper-detail-page__tag").exists({ count: 2 });
    assert.dom(".paper-detail-page__meta").includesText("10.1000/test-paper");
  });

  test("navigates to the internal author page from a paper", async function (assert) {
    await visit("/scholar/paper/test-paper");
    await click(".paper-detail-page__author button");

    assert.strictEqual(currentURL(), "/scholar/author/author-1");
  });

  test("redirects to the 404 page when the paper request fails", async function (assert) {
    await visit("/scholar/paper/missing-paper");

    assert.strictEqual(currentURL(), "/404");
  });

  test("shows a recoverable error state for upstream failures", async function (assert) {
    await visit("/scholar/paper/unavailable-paper");

    assert.strictEqual(currentURL(), "/scholar/paper/unavailable-paper");
    assert.dom(".paper-detail-page__card").includesText("Service unavailable");
  });

  test("renders the author page", async function (assert) {
    await visit("/scholar/author/author-1");

    assert.dom(".scholar-page__title").hasText("Ada Lovelace");
    assert.dom(".scholar-page__result").includesText(
      "Hybrid Interfaces for Academic Discovery"
    );
  });

  test("redirects to the 404 page when the author request fails", async function (assert) {
    await visit("/scholar/author/missing-author");

    assert.strictEqual(currentURL(), "/404");
  });

  test("renders search results and autocomplete suggestions", async function (assert) {
    await visit("/scholar/search?q=hybrid");

    assert.dom(".scholar-page__result").exists({ count: 2 });

    await fillIn(".scholar-search-box__input", "ada");
    await settled();

    assert.dom(".scholar-search-box__suggestion").exists({ count: 2 });

    await click(".scholar-search-box__suggestion:last-child");

    assert.strictEqual(currentURL(), "/scholar/author/author-1");
  });

  test("shows a recoverable error state for search failures", async function (assert) {
    await visit("/scholar/search?q=broken");

    assert.strictEqual(currentURL(), "/scholar/search?q=broken");
    assert.dom(".scholar-page__card").includesText("Search unavailable");
  });
});
