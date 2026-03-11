import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";
import ScholarCiteModal from "./scholar-cite-modal";

export default class ScholarSearchPage extends Component {
  @tracked yearFilter = null;
  @tracked minCitations = 0;
  @tracked openAccessOnly = false;
  @tracked citingPaper = null;

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

  get currentSource() {
    return this.results.source || "stc";
  }

  get isSourceStc() {
    return this.currentSource === "stc";
  }

  get isSourceOlx() {
    return this.currentSource === "olx";
  }

  get errorMessage() {
    return this.results.error_message || i18n("scholar.search.unavailable");
  }

  get currentPage() {
    return this.results.page || 1;
  }

  get totalPages() {
    return this.results.total_pages || 1;
  }

  get totalPapers() {
    return this.results.total_papers || 0;
  }

  get showPagination() {
    return this.totalPages > 1;
  }

  get hasPrevPage() {
    return this.currentPage > 1;
  }

  get hasNextPage() {
    return this.currentPage < this.totalPages;
  }

  get prevPage() {
    return Math.max(1, this.currentPage - 1);
  }

  get nextPage() {
    return Math.min(this.totalPages, this.currentPage + 1);
  }

  get pageNumbers() {
    const current = this.currentPage;
    const total = this.totalPages;
    const pages = [];
    let start = Math.max(1, current - 2);
    let end = Math.min(total, current + 2);

    if (end - start < 4) {
      if (start === 1) {
        end = Math.min(total, start + 4);
      } else {
        start = Math.max(1, end - 4);
      }
    }

    for (let p = start; p <= end; p++) {
      pages.push({ num: p, active: p === current });
    }
    return pages;
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

  @action
  goToPage(pageNum) {
    const q = encodeURIComponent(this.query);
    const source = this.currentSource;
    DiscourseURL.routeTo(
      `/scholar/search?q=${q}&page=${pageNum}&source=${source}`
    );
  }

  @action
  switchSource(source) {
    if (source === this.currentSource) {
      return;
    }
    const q = encodeURIComponent(this.query);
    DiscourseURL.routeTo(`/scholar/search?q=${q}&source=${source}`);
  }

  @action
  openCite(paper) {
    this.citingPaper = paper;
  }

  @action
  closeCite() {
    this.citingPaper = null;
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

        <div class="scholar-search-page__source-tabs">
          <button
            type="button"
            class="scholar-search-page__source-tab
              {{if this.isSourceStc '-active'}}"
            {{on "click" (fn this.switchSource "stc")}}
          >{{i18n "scholar.search.sources.stc"}}</button>
          <button
            type="button"
            class="scholar-search-page__source-tab
              {{if this.isSourceOlx '-active'}}"
            {{on "click" (fn this.switchSource "olx")}}
          >{{i18n "scholar.search.sources.olx"}}</button>
        </div>

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
                  count=this.totalPapers
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

                    {{#if paper.authors.length}}
                      <div class="scholar-result-card__author-chips">
                        {{#each paper.authors as |author|}}
                          {{#if author.path}}
                            <button
                              type="button"
                              class="scholar-result-card__author-chip"
                              {{on "click" (fn this.navigateTo author.path)}}
                            >{{author.name}}</button>
                          {{else}}
                            <span
                              class="scholar-result-card__author-chip -plain"
                            >{{author.name}}</span>
                          {{/if}}
                        {{/each}}
                      </div>
                    {{/if}}

                    <div class="scholar-result-card__meta">
                      {{#if paper.fields_of_study.length}}
                        {{#each paper.fields_of_study as |field|}}
                          <span
                            class="scholar-result-card__field-inline"
                          >{{field}}</span>
                        {{/each}}
                      {{/if}}
                      {{#if paper.venue}}
                        <span
                          class="scholar-result-card__venue"
                        >{{paper.venue}}</span>
                      {{/if}}
                      {{#if paper.publication_date}}
                        <span
                          class="scholar-result-card__date"
                        >{{paper.publication_date}}</span>
                      {{else if paper.year}}
                        <span
                          class="scholar-result-card__date"
                        >{{paper.year}}</span>
                      {{/if}}
                    </div>

                    {{#if paper.abstract}}
                      <p
                        class="scholar-result-card__abstract"
                      >{{paper.abstract}}</p>
                    {{/if}}

                    <div class="scholar-result-card__actions">
                      {{#if paper.citation_count}}
                        <span class="scholar-result-card__citations">
                          {{icon "quote-left"}}
                          {{number paper.citation_count}}
                        </span>
                      {{/if}}
                      {{#if paper.url}}
                        <a
                          class="scholar-result-card__action-link"
                          href={{paper.url}}
                          target="_blank"
                          rel="noopener noreferrer"
                        >
                          {{icon "arrow-up-right-from-square"}}
                          {{i18n "scholar.search.actions.publisher"}}
                        </a>
                      {{/if}}
                      <button
                        type="button"
                        class="scholar-result-card__action-link"
                        {{on "click" (fn this.openCite paper)}}
                      >
                        {{icon "quote-left"}}
                        {{i18n "scholar.search.actions.cite"}}
                      </button>
                    </div>
                  </article>
                {{/each}}
              </div>

              {{#if this.showPagination}}
                <nav class="scholar-search-page__pagination">
                  <button
                    type="button"
                    class="scholar-search-page__page-btn -prev"
                    disabled={{unless this.hasPrevPage true}}
                    {{on "click" (fn this.goToPage this.prevPage)}}
                  >
                    {{icon "chevron-left"}}
                    {{i18n "scholar.search.pagination.prev"}}
                  </button>

                  {{#each this.pageNumbers as |pg|}}
                    <button
                      type="button"
                      class="scholar-search-page__page-btn -num
                        {{if pg.active '-active'}}"
                      {{on "click" (fn this.goToPage pg.num)}}
                    >{{pg.num}}</button>
                  {{/each}}

                  <button
                    type="button"
                    class="scholar-search-page__page-btn -next"
                    disabled={{unless this.hasNextPage true}}
                    {{on "click" (fn this.goToPage this.nextPage)}}
                  >
                    {{i18n "scholar.search.pagination.next"}}
                    {{icon "chevron-right"}}
                  </button>
                </nav>
              {{/if}}
            {{else}}
              <p class="scholar-search-page__empty">{{i18n
                  "scholar.search.empty_papers"
                }}</p>
            {{/if}}
          </main>
        </div>
      {{/if}}

      {{#if this.citingPaper}}
        <ScholarCiteModal
          @paper={{this.citingPaper}}
          @onClose={{this.closeCite}}
        />
      {{/if}}
    </div>
  </template>
}
