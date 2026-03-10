import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import ScholarSearchBox from "./scholar-search-box";

export default class ScholarSearchPage extends Component {
  get results() {
    return this.args.results || {};
  }

  get papers() {
    return this.results.papers || [];
  }

  get authors() {
    return this.results.authors || [];
  }

  get query() {
    return this.results.query || "";
  }

  get errorMessage() {
    return this.results.error_message || i18n("scholar.search.unavailable");
  }

  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  <template>
    <div class="scholar-page scholar-search-page">
      <ScholarSearchBox @initialQuery={{this.query}} />

      {{#if this.results.load_error}}
        <section class="scholar-page__error">
          <article class="scholar-page__card">
            <h2>{{i18n "scholar.search.unavailable"}}</h2>
            <p class="scholar-page__empty">{{this.errorMessage}}</p>
          </article>
        </section>
      {{else}}
        <section class="scholar-page__layout">
          <main class="scholar-page__main">
            <article class="scholar-page__card">
              <h2>{{i18n "scholar.search.sections.papers"}}</h2>
              {{#if this.papers.length}}
                <div class="scholar-page__result-list">
                  {{#each this.papers as |paper|}}
                    <button
                      type="button"
                      class="scholar-page__result"
                      {{on "click" (fn this.navigateTo paper.path)}}
                    >
                      <span class="scholar-page__result-title">{{paper.title}}</span>
                      <span class="scholar-page__result-meta">
                        {{#if paper.authors.length}}
                          {{paper.authors}}
                        {{/if}}
                        {{#if paper.year}}
                          <span class="scholar-page__result-meta-pill">{{paper.year}}</span>
                        {{/if}}
                        {{#if paper.venue}}
                          <span class="scholar-page__result-meta-pill">{{paper.venue}}</span>
                        {{/if}}
                        {{#if paper.citation_count}}
                          <span class="scholar-page__result-meta-pill">
                            {{number paper.citation_count}}
                            {{i18n "scholar.paper.metrics.citations"}}
                          </span>
                        {{/if}}
                      </span>
                    </button>
                  {{/each}}
                </div>
              {{else}}
                <p class="scholar-page__empty">{{i18n
                    "scholar.search.empty_papers"
                  }}</p>
              {{/if}}
            </article>

            <article class="scholar-page__card">
              <h2>{{i18n "scholar.search.sections.authors"}}</h2>
              {{#if this.authors.length}}
                <div class="scholar-page__result-list">
                  {{#each this.authors as |author|}}
                    <button
                      type="button"
                      class="scholar-page__result"
                      {{on "click" (fn this.navigateTo author.path)}}
                    >
                      <span class="scholar-page__result-title">{{author.name}}</span>
                      <span class="scholar-page__result-meta">
                        {{#if author.affiliations.length}}
                          {{author.affiliations}}
                        {{/if}}
                        {{#if author.paper_count}}
                          <span class="scholar-page__result-meta-pill">
                            {{number author.paper_count}}
                            {{i18n "scholar.author.metrics.papers"}}
                          </span>
                        {{/if}}
                        {{#if author.citation_count}}
                          <span class="scholar-page__result-meta-pill">
                            {{number author.citation_count}}
                            {{i18n "scholar.author.metrics.citations"}}
                          </span>
                        {{/if}}
                      </span>
                    </button>
                  {{/each}}
                </div>
              {{else}}
                <p class="scholar-page__empty">{{i18n
                    "scholar.search.empty_authors"
                  }}</p>
              {{/if}}
            </article>
          </main>
        </section>
      {{/if}}
    </div>
  </template>
}
