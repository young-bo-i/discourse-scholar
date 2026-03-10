import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class ScholarSearchPage extends Component {
  @tracked yearFilter = null;
  @tracked minCitations = 0;
  @tracked openAccessOnly = false;

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

  get filteredPapers() {
    let papers = this.papers;

    if (this.yearFilter) {
      papers = papers.filter((p) => p.year && p.year >= this.yearFilter);
    }

    if (this.minCitations > 0) {
      papers = papers.filter(
        (p) => p.citation_count && p.citation_count >= this.minCitations
      );
    }

    if (this.openAccessOnly) {
      papers = papers.filter((p) => p.is_open_access);
    }

    return papers;
  }

  get isYearAll() {
    return this.yearFilter === null;
  }

  get isYear2026() {
    return this.yearFilter === 2026;
  }

  get isYear2025() {
    return this.yearFilter === 2025;
  }

  get isYear2022() {
    return this.yearFilter === 2022;
  }

  get isCitAll() {
    return this.minCitations === 0;
  }

  get isCit10() {
    return this.minCitations === 10;
  }

  get isCit50() {
    return this.minCitations === 50;
  }

  get isCit100() {
    return this.minCitations === 100;
  }

  get isCit500() {
    return this.minCitations === 500;
  }

  @action
  setYearFilter(value) {
    this.yearFilter = value;
  }

  @action
  setCitationFilter(value) {
    this.minCitations = value;
  }

  @action
  toggleOpenAccess() {
    this.openAccessOnly = !this.openAccessOnly;
  }

  @action
  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  <template>
    <div class="scholar-page scholar-search-page">
      {{#if this.results.load_error}}
        <div class="scholar-search-page__error-card">
          <h2>{{i18n "scholar.search.unavailable"}}</h2>
          <p>{{this.errorMessage}}</p>
        </div>
      {{else}}
        {{#if this.authors.length}}
          <section class="scholar-search-page__authors-bar">
            <div class="scholar-search-page__authors-scroll">
              {{#each this.authors as |author|}}
                <button
                  type="button"
                  class="scholar-search-page__author-card"
                  {{on "click" (fn this.navigateTo author.path)}}
                >
                  <div class="scholar-search-page__author-avatar">
                    {{icon "user"}}
                  </div>
                  <div class="scholar-search-page__author-info">
                    <span
                      class="scholar-search-page__author-name"
                    >{{author.name}}</span>
                    <span class="scholar-search-page__author-stats">
                      {{#if author.paper_count}}
                        {{number author.paper_count}}
                        {{i18n "scholar.author.metrics.papers"}}
                      {{/if}}
                      {{#if author.citation_count}}
                        · {{number author.citation_count}}
                        {{i18n "scholar.author.metrics.citations"}}
                      {{/if}}
                    </span>
                    {{#if author.affiliations.length}}
                      <span
                        class="scholar-search-page__author-field"
                      >{{author.affiliations}}</span>
                    {{/if}}
                  </div>
                </button>
              {{/each}}
            </div>
          </section>
        {{/if}}

        <div class="scholar-search-page__container">
          <aside class="scholar-search-page__sidebar">
            <div class="scholar-search-page__filter-group">
              <h3 class="scholar-search-page__filter-title">{{i18n
                  "scholar.search.filters.year_label"
                }}</h3>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isYearAll '-active'}}"
                {{on "click" (fn this.setYearFilter null)}}
              >{{i18n "scholar.search.filters.all_time"}}</button>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isYear2026 '-active'}}"
                {{on "click" (fn this.setYearFilter 2026)}}
              >{{i18n "scholar.search.filters.since_2026"}}</button>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isYear2025 '-active'}}"
                {{on "click" (fn this.setYearFilter 2025)}}
              >{{i18n "scholar.search.filters.since_2025"}}</button>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isYear2022 '-active'}}"
                {{on "click" (fn this.setYearFilter 2022)}}
              >{{i18n "scholar.search.filters.since_2022"}}</button>
            </div>

            <div class="scholar-search-page__filter-group">
              <h3 class="scholar-search-page__filter-title">{{i18n
                  "scholar.search.filters.citations_label"
                }}</h3>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isCitAll '-active'}}"
                {{on "click" (fn this.setCitationFilter 0)}}
              >{{i18n "scholar.search.filters.citations_all"}}</button>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isCit10 '-active'}}"
                {{on "click" (fn this.setCitationFilter 10)}}
              >{{i18n "scholar.search.filters.citations_10"}}</button>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isCit50 '-active'}}"
                {{on "click" (fn this.setCitationFilter 50)}}
              >{{i18n "scholar.search.filters.citations_50"}}</button>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isCit100 '-active'}}"
                {{on "click" (fn this.setCitationFilter 100)}}
              >{{i18n "scholar.search.filters.citations_100"}}</button>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.isCit500 '-active'}}"
                {{on "click" (fn this.setCitationFilter 500)}}
              >{{i18n "scholar.search.filters.citations_500"}}</button>
            </div>

            <div class="scholar-search-page__filter-group">
              <h3 class="scholar-search-page__filter-title">{{i18n
                  "scholar.search.filters.open_access_label"
                }}</h3>
              <button
                type="button"
                class="scholar-search-page__filter-item
                  {{if this.openAccessOnly '-active'}}"
                {{on "click" this.toggleOpenAccess}}
              >
                {{icon "lock-open"}}
                {{i18n "scholar.search.filters.open_access_only"}}
              </button>
            </div>
          </aside>

          <main class="scholar-search-page__main">
            <div class="scholar-search-page__result-header">
              <span class="scholar-search-page__result-count">
                {{i18n
                  "scholar.search.result_count"
                  count=this.filteredPapers.length
                }}
              </span>
            </div>

            {{#if this.filteredPapers.length}}
              <div class="scholar-search-page__paper-list">
                {{#each this.filteredPapers as |paper|}}
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
                    {{#if paper.fields_of_study.length}}
                      <div class="scholar-result-card__fields">
                        {{#each paper.fields_of_study as |field|}}
                          <span
                            class="scholar-result-card__field"
                          >{{field}}</span>
                        {{/each}}
                      </div>
                    {{/if}}
                    {{#if paper.abstract}}
                      <p
                        class="scholar-result-card__abstract"
                      >{{paper.abstract}}</p>
                    {{/if}}
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
          </main>
        </div>
      {{/if}}
    </div>
  </template>
}
