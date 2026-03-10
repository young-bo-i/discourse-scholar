import Component from "@glimmer/component";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import icon from "discourse/helpers/d-icon";
import number from "discourse/helpers/number";
import DiscourseURL from "discourse/lib/url";
import { i18n } from "discourse-i18n";

export default class PaperDetailPage extends Component {
  get paper() {
    return this.args.paper || {};
  }

  get authors() {
    return this.paper.authors || [];
  }

  get fieldsOfStudy() {
    return this.paper.fields_of_study || [];
  }

  get sourceLabel() {
    return this.paper.source?.toUpperCase();
  }

  get errorMessage() {
    return this.paper.error_message || i18n("scholar.paper.states.unavailable");
  }

  navigateTo(path) {
    DiscourseURL.routeTo(path);
  }

  <template>
    <div class="scholar-page paper-detail-page">
      {{#if this.paper.load_error}}
        <section class="scholar-page__error">
          <article class="scholar-page__card">
            <h2>{{i18n "scholar.paper.states.unavailable"}}</h2>
            <p class="scholar-page__empty">
              {{this.errorMessage}}
            </p>
          </article>
        </section>
      {{else}}
        <section class="paper-detail-page__hero">
          <div class="paper-detail-page__hero-content">
            <div class="paper-detail-page__eyebrow">
              {{#if this.sourceLabel}}
                <span class="paper-detail-page__badge">{{this.sourceLabel}}</span>
              {{/if}}
              {{#if this.paper.is_open_access}}
                <span class="paper-detail-page__badge -success">
                  {{icon "lock-open"}}
                  {{i18n "scholar.paper.metrics.open_access"}}
                </span>
              {{/if}}
            </div>

            <div class="paper-detail-page__id-badges">
              {{#if this.paper.doi}}
                <span class="paper-detail-page__id-badge">
                  DOI:
                  <code>{{this.paper.doi}}</code>
                </span>
              {{/if}}
              {{#if this.paper.id}}
                <span class="paper-detail-page__id-badge">
                  ID:
                  <code>{{this.paper.id}}</code>
                </span>
              {{/if}}
            </div>

            <h1 class="paper-detail-page__title">{{this.paper.title}}</h1>

            <div class="paper-detail-page__authors">
              {{#if this.authors.length}}
                {{#each this.authors as |author|}}
                  <span class="paper-detail-page__author">
                    {{#if author.path}}
                      <button
                        type="button"
                        class="paper-detail-page__author-link"
                        {{on "click" (fn this.navigateTo author.path)}}
                      >{{author.name}}</button>
                    {{else if author.url}}
                      <a
                        href={{author.url}}
                        target="_blank"
                        rel="noopener noreferrer"
                      >{{author.name}}</a>
                    {{else}}
                      {{author.name}}
                    {{/if}}
                  </span>
                {{/each}}
              {{else}}
                <span>{{i18n "scholar.paper.states.no_authors"}}</span>
              {{/if}}
            </div>

            <div class="paper-detail-page__summary-line">
              {{#if this.paper.venue}}
                <span>{{this.paper.venue}}</span>
              {{/if}}
              {{#if this.paper.year}}
                <span>{{this.paper.year}}</span>
              {{/if}}
              {{#if this.paper.publication_date}}
                <span>{{this.paper.publication_date}}</span>
              {{/if}}
            </div>
          </div>
        </section>

        <section class="paper-detail-page__layout">
          <main class="paper-detail-page__main">
            <article class="paper-detail-page__card -abstract">
              <h2>{{i18n "scholar.paper.sections.abstract"}}</h2>
              {{#if this.paper.abstract}}
                <p class="paper-detail-page__abstract">{{this.paper.abstract}}</p>
              {{else}}
                <p class="paper-detail-page__empty">
                  {{i18n "scholar.paper.states.no_abstract"}}
                </p>
              {{/if}}
            </article>

            <article class="paper-detail-page__card">
              <h2>{{i18n "scholar.paper.sections.fields_of_study"}}</h2>
              {{#if this.fieldsOfStudy.length}}
                <div class="paper-detail-page__tags">
                  {{#each this.fieldsOfStudy as |field|}}
                    <span class="paper-detail-page__tag">{{field}}</span>
                  {{/each}}
                </div>
              {{else}}
                <p class="paper-detail-page__empty">
                  {{i18n "scholar.paper.states.no_fields"}}
                </p>
              {{/if}}
            </article>
          </main>

          <aside class="paper-detail-page__sidebar">
            <article class="paper-detail-page__card">
              <h2>{{i18n "scholar.paper.sections.metrics"}}</h2>
              <div class="paper-detail-page__metrics-grid">
                <div class="paper-detail-page__metric">
                  <span class="paper-detail-page__metric-value">{{number
                      this.paper.citation_count
                    }}</span>
                  <span class="paper-detail-page__metric-label">{{i18n
                      "scholar.paper.metrics.citations"
                    }}</span>
                </div>
                <div class="paper-detail-page__metric">
                  <span class="paper-detail-page__metric-value">{{number
                      this.paper.reference_count
                    }}</span>
                  <span class="paper-detail-page__metric-label">{{i18n
                      "scholar.paper.metrics.references"
                    }}</span>
                </div>
              </div>
            </article>

            <article class="paper-detail-page__card">
              <h2>{{i18n "scholar.paper.sections.links"}}</h2>
              <div class="paper-detail-page__action-list">
                {{#if this.paper.url}}
                  <a
                    href={{this.paper.url}}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="paper-detail-page__action-link"
                  >
                    {{icon "arrow-up-right-from-square"}}
                    {{i18n "scholar.paper.actions.view_source"}}
                  </a>
                {{/if}}
                {{#if this.paper.pdf_url}}
                  <a
                    href={{this.paper.pdf_url}}
                    target="_blank"
                    rel="noopener noreferrer"
                    class="paper-detail-page__action-link -primary"
                  >
                    {{icon "file-pdf"}}
                    {{i18n "scholar.paper.actions.open_pdf"}}
                  </a>
                {{/if}}
              </div>
            </article>

            <article class="paper-detail-page__card">
              <h2>{{i18n "scholar.paper.sections.details"}}</h2>
              <div class="paper-detail-page__meta-list">
                {{#if this.paper.venue}}
                  <div class="paper-detail-page__meta-item">
                    <span class="paper-detail-page__meta-label">{{i18n
                        "scholar.paper.meta.venue"
                      }}</span>
                    <span class="paper-detail-page__meta-value">{{this.paper.venue}}</span>
                  </div>
                {{/if}}
                {{#if this.paper.year}}
                  <div class="paper-detail-page__meta-item">
                    <span class="paper-detail-page__meta-label">{{i18n
                        "scholar.paper.meta.year"
                      }}</span>
                    <span class="paper-detail-page__meta-value">{{this.paper.year}}</span>
                  </div>
                {{/if}}
                {{#if this.paper.publication_date}}
                  <div class="paper-detail-page__meta-item">
                    <span class="paper-detail-page__meta-label">{{i18n
                        "scholar.paper.meta.publication_date"
                      }}</span>
                    <span class="paper-detail-page__meta-value">{{this.paper.publication_date}}</span>
                  </div>
                {{/if}}
                {{#if this.paper.doi}}
                  <div class="paper-detail-page__meta-item">
                    <span class="paper-detail-page__meta-label">{{i18n
                        "scholar.paper.meta.doi"
                      }}</span>
                    <span class="paper-detail-page__meta-value">
                      <a
                        href={{this.paper.doi_url}}
                        target="_blank"
                        rel="noopener noreferrer"
                      >{{this.paper.doi}}</a>
                    </span>
                  </div>
                {{/if}}
              </div>
            </article>
          </aside>
        </section>
      {{/if}}
    </div>
  </template>
}
