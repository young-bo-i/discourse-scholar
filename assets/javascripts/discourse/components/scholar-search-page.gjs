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
        <div class="scholar-search-page__error-card">
          <h2>{{i18n "scholar.search.unavailable"}}</h2>
          <p>{{this.errorMessage}}</p>
        </div>
      {{else}}
        <div class="scholar-search-page__results">
          <section class="scholar-search-page__section">
            <h2 class="scholar-search-page__section-title">{{i18n
                "scholar.search.sections.papers"
              }}</h2>
            {{#if this.papers.length}}
              <div class="scholar-search-page__list">
                {{#each this.papers as |paper|}}
                  <article class="scholar-result-card">
                    <button
                      type="button"
                      class="scholar-result-card__link"
                      {{on "click" (fn this.navigateTo paper.path)}}
                    >
                      <h3
                        class="scholar-result-card__title"
                      >{{paper.title}}</h3>
                    </button>
                    <div class="scholar-result-card__meta">
                      {{#if paper.authors.length}}
                        <span
                          class="scholar-result-card__authors"
                        >{{paper.authors}}</span>
                      {{/if}}
                      {{#if paper.venue}}
                        <span
                          class="scholar-result-card__venue"
                        >{{paper.venue}}</span>
                      {{/if}}
                      {{#if paper.year}}
                        <span
                          class="scholar-result-card__year"
                        >{{paper.year}}</span>
                      {{/if}}
                    </div>
                    {{#if paper.citation_count}}
                      <span class="scholar-result-card__citations">
                        {{number paper.citation_count}}
                        {{i18n "scholar.paper.metrics.citations"}}
                      </span>
                    {{/if}}
                  </article>
                {{/each}}
              </div>
            {{else}}
              <p class="scholar-search-page__empty">{{i18n
                  "scholar.search.empty_papers"
                }}</p>
            {{/if}}
          </section>

          <section class="scholar-search-page__section">
            <h2 class="scholar-search-page__section-title">{{i18n
                "scholar.search.sections.authors"
              }}</h2>
            {{#if this.authors.length}}
              <div class="scholar-search-page__list">
                {{#each this.authors as |author|}}
                  <article class="scholar-result-card">
                    <button
                      type="button"
                      class="scholar-result-card__link"
                      {{on "click" (fn this.navigateTo author.path)}}
                    >
                      <h3
                        class="scholar-result-card__title"
                      >{{author.name}}</h3>
                    </button>
                    <div class="scholar-result-card__meta">
                      {{#if author.affiliations.length}}
                        <span>{{author.affiliations}}</span>
                      {{/if}}
                      {{#if author.paper_count}}
                        <span>{{number author.paper_count}}
                          {{i18n "scholar.author.metrics.papers"}}</span>
                      {{/if}}
                      {{#if author.citation_count}}
                        <span>{{number author.citation_count}}
                          {{i18n "scholar.author.metrics.citations"}}</span>
                      {{/if}}
                    </div>
                  </article>
                {{/each}}
              </div>
            {{else}}
              <p class="scholar-search-page__empty">{{i18n
                  "scholar.search.empty_authors"
                }}</p>
            {{/if}}
          </section>
        </div>
      {{/if}}
    </div>
  </template>
}
